EntryForm(form, fields*) {
	;// assume static mode for GUI controls variable(s)
	static
	
	;// During script's exit, __Delete is invoked to release resources used
	;   by the function such as image list(s), etc.
	static ef := { "__Delete": Func("EntryForm") }
	     , _  := new ef ;// static vars are released alphabetically
	
	static is_v2 := A_AhkVersion >= "2"
	     , is_xp := ( is_v2 ? (A_OSVersion < "6") : (A_OSVersion == "WIN_XP") )
	
	;// Object built-in functions (v1.1 and v2.0-a049 compatibility)
	static del  := Func( is_v2 ? "ObjRemoveAt" : "ObjRemove" )
	     , push := Func( is_v2 ? "ObjPush"     : "ObjInsert" )
	
	;// RegEx needles to extract options
	static ndl  := ( is_v2 ? "i)" : "Oi)" ) . "(title|icon|font|"
	            .  "prompt|default|cue|file|dir|tip|updown)'(.*?[^\\])'"
	     , ndlb := ( is_v2 ? "i)" : "Oi)" ) . "(?<=^|,)\s*\K.*?(?=(?<!\\),|$)"
	
	;// for DllCall()
	static ExtractIconEx := "shell32\ExtractIconEx" . (A_IsUnicode ? "W" : "A")
	     , GetWindowLong := A_Is64bitOS ? "GetWindowLongPtr" : "GetWindowLong"
	
	;// Constants for TOOLINFO & OPENFILENAME structs
	static TTM_ADDTOOL     := A_IsUnicode ? 0x0432 : 0x0404
	     , sizeof_TOOLINFO := 24 + (A_PtrSize * 6)
	     , sizeof_OFN      := 36 + (13 * A_PtrSize)
	
	static btn_size, himl
	
	;// local variables (main body)
	local sform, i, m, s_form, tok, hForm, hIconL := hIconS := 0, RECT, width
	    , idx, field, sfield, font, is_input, ftype, hPrompt, hInput, is_multi
	    , input_pos, j, btn, hBtn, vBtn, BTN_IMGLIST, btns := {}, k, dhw
	    , flds := [], ret
	
	;// local variables for EF_SelectFile subroutine(local label)
	local options, flags, root_dir, prompt, filter, lpstrFile, lpstrFilter
	    , ext, flen1, flen2, OPENFILENAME, selected
	
	;// local variables for EF_SelectDir subroutine(local label)
	local shell, folder ;// ,options -> declared above

	;// local variables for EF_SetToolTip subroutine(local label)
	local tt := {}, hTip, tt_tmp
	
	
	;// __Delete - This routine is called during script script's exit
	if (form.base == ef)
	{
		if himl
			IL_Destroy(himl.file), IL_Destroy(himl.dir)
		return
	}
	
	if !IsObject(form)
	{
		sform := form, form := {}, i := 1
		while (i := RegExMatch(sform, ndl, m, i))
		{
			form[m[1]] := m[2]
			sform := SubStr(sform, 1, i-1) . SubStr(sform, i+m.Len)
		}
		s_form := is_v2 ? sform : "sform"
		Loop Parse, %s_form%, % " ", `t`r`n
		{
			if InStr( " tf", tok := SubStr(A_LoopField, 1, 1) )-1
				form[tok = "t" ? "timeout" : "func"] := SubStr(A_LoopField, 2)
			else
				form.pos .= " " A_LoopField
		}
	}
	
	;// Create EntryForm window
	Gui New, +HwndhForm +LabelEF_
	
	;// Initialize font, InputBox uses 's10, MS Shell Dlg 2' on OS >= WIN_7??
	form.font := form.HasKey("font") ? StrSplit(form.font, ",", " `t`r`n")
	                                 : ["s10", "MS Shell Dlg 2"]
	Gui Font, % form.font[1], % form.font[2]
	Gui Margin, 10, 10
	
	;// Initialize GUI position
	if !InStr(form.pos, "w")
		form.pos .= " w375" ;// default width, same as InputBox
	if !(form.pos ~= "i)[xy](\d+|Center)")
		form.pos .= " Center"
	else if !InStr(form.pos, "x")
		form.pos .= " xCenter"
	else if !InStr(form.pos, "y")
		form.pos .= " yCenter"
	
	;// Show hidden
	Gui Show, % "Hide " form.pos

	;// Set window icon if specified
	;   Small icon for the caption | large icon for Alt+Tab and taskbar
	if form.HasKey("icon")
	{
		form.icon := StrSplit(form.icon, ",", " `t`r`n")
		DllCall(
		(Join Q C
			ExtractIconEx,
			"Str",   form.icon[1],
			"Int",   form.icon[2] + 0,
			"UIntP", hIconL,
			"UIntP", hIconS,
			"UInt",  2
		))
		;// WM_SETICON = 0x0080
		DllCall("SendMessage", "Ptr", hForm, "Int", 0x0080, "Ptr", 0, "Ptr", hIconS)
		DllCall("SendMessage", "Ptr", hForm, "Int", 0x0080, "Ptr", 1, "Ptr", hIconL)
	}
	
	;// Get GUI width-left+right margin, controls are confined within this width
	VarSetCapacity(RECT, 16, 0)
	, DllCall("GetClientRect", "Ptr", hForm, "Ptr", &RECT)
	, width := NumGet(RECT, 8, "UInt")-20
	
	for idx, field in fields
	{
		if !IsObject(field)
		{
			sfield := field, field := {}, i := 1
			while (i := RegExMatch(sfield, ndl, m, i))
			{
				field[m[1]] := m[2]
				sfield := SubStr(sfield, 1, i-1) . SubStr(sfield, i+m.Len)
			}
			
			field.options := Trim(sfield, " `t`r`n")
		}

		;// Set font
		if field.HasKey("font")
		{
			field.font := StrSplit(field.font, ";", " `t`r`n")
			if ( (font := %del%(field.font, 1)) != "" )
				field.font.prompt := StrSplit(font, ",", " `t`r`n")
			if ( (font := %del%(field.font, 1)) != "" )
				field.font.input := StrSplit(font, ",", " `t`r`n")
		}

		for is_input, ftype in { 0: "prompt", 1: "input" }
		{
			if ( font := field.font[ftype] ) {
				Gui Font
				Gui Font, % font[1], % font[2]
			}

			Gui Add, % is_input ? "Edit" : "Text"
			       , % "xm w" width " Hwndh" ftype . ( is_input
			         ? " y+5 " field.options
			         : " Wrap y" ( idx == 1 ? 10 : input_posY+input_posH+10 ) )
			       , % field[ is_input ? "default" : "prompt" ]
			
			if !font
				continue
			
			Gui Font
			Gui Font, % form.font[1], % form.font[2]
		}

		flds[idx] := hInput
		GuiControlGet input_pos, Pos, %hInput%
		;// ES_MULTILINE := 0x0004
		is_multi := DllCall(GetWindowLong, "Ptr", hInput, "Int", -16, "Ptr") & 0x0004

		;// ToolTip
		if field.HasKey("tip")
		{
			tt.ctrl := hInput, tt.text := field.tip
			gosub EF_SetToolTip
		}

		;// Cue banner | EM_SETCUEBANNER = 0x1501
		if field.HasKey("cue")
			SendMessage 0x1501, 0, % ObjGetAddress(field, "cue"),, ahk_id %hInput%
		
		;// Buddy UpDown control
		if field.HasKey("updown")
			Gui Add, Updown, % field.updown

		;// Add browse file AND/OR folder buttons if specified
		j := 0
		for i, btn in ["file", "dir"]
		{
			if !field.HasKey(btn)
				continue

			;// Get default button size based on system's default font
			if !btn_size
			{
				Gui New
				; Gui Font, s10, MS Shell Dlg 2 ;// Used by InputBox??
				Gui Add, Button, r1
				GuiControlGet, btn_size, Pos, Button1
				Gui Destroy
				btn_size := btn_sizeH
				Gui %hForm%:Default
			}

			j += 1
			GuiControl, Move, %hInput%, % "w" width - ( (btn_size + 3) * (is_multi? 1 : j) )
			GuiControlGet input_pos, Pos, %hInput%
			if (j > 1)
				GuiControl Move, %hBtn%, % "x" input_posW + 13 ;// margin + padding
			Gui Add, Button, % "w" btn_size " h" btn_size
			                 . " y" ( j > 1 && is_multi ? "+3" : "p" )
			                 . " xm+" width - btn_size
			                 . " HwndhBtn gEF_Select" btn
			GuiControl % "+v" ( vBtn := "ef_btn_" . hBtn ), %hBtn%
			
			/*
			Create BUTTON_IMAGELIST structure -> http://goo.gl/RVQsnM
			typedef struct {
			    HIMAGELIST himl;
			    RECT       margin;
			    UINT       uAlign;
			} BUTTON_IMAGELIST, *PBUTTON_IMAGELIST;
			sizeof BUTTON_IMAGELIST = Ptr(A_PtrSize) + RECT(16) + UInt(4)
			*/
			VarSetCapacity(BTN_IMGLIST, A_PtrSize + 20, 0)

			;// Image list for select file/folder buttons
			if !himl
			{
				himl := { "file": IL_Create(1, 5), "dir": IL_Create(1, 5) }
				, IL_Add(himl.file, "shell32.dll", 56)  ;// 56 = 1-based index
				, IL_Add(himl.dir, "imageres.dll", 205) ;// 205 = 1-based index
			}

			;// Set himl member of struct
			NumPut(himl[btn], BTN_IMGLIST, 0, "Ptr")
			
			;// Set margin member | 1px??
			Loop 4
				NumPut(1, BTN_IMGLIST, A_PtrSize+A_Index*4-4, "UInt")
			
			;// Set uAlign member | BUTTON_IMAGELIST_ALIGN_CENTER := 4
			NumPut(4, BTN_IMGLIST, A_PtrSize+16, "UInt")
			
			;// BCM_SETIMAGELIST = 0x1602
			SendMessage 0x1602, 0, % &BTN_IMGLIST,, ahk_id %hBtn%

			btns[vBtn] := { "input": hInput, "options": [] }
			k := 1
			while ( k := RegExMatch(field[btn], ndlb, m, k) )
				btns[vBtn].options[A_Index] := m.Value(), k += m.Len()

			tt.ctrl := hBtn, tt.text := "Browse " . (btn != "file" ? "folder" : btn)
			gosub EF_SetToolTip
		}

	}

	;// Add OK and Cancel buttons
	Gui Add, Button, % "w100 r1 gEF_OK xm+" (width/2)-110
	                 . " y" input_posY + input_posH + 20
	               , OK
	Gui Add, Button, x+20 yp wp hp gEF_Cancel, Cancel
	
	Gui Show, % "AutoSize " form.pos, % form.title
	dhw := A_DetectHiddenWindows
	DetectHiddenWindows On
	WinWaitClose ahk_id %hForm%,, % form.timeout/1000
	if ErrorLevel
		gosub EF_Timeout
	DetectHiddenWindows %dhw%
	if hIconL
		DllCall("DestroyIcon", "Ptr", hIconL)
	if hIconS
		DllCall("DestroyIcon", "Ptr", hIconS)
	return ret

EF_OK:
EF_Cancel:
EF_Close:
EF_Escape:
EF_Timeout:
	ret := { "event": SubStr(A_ThisLabel, 4), "output": [] }
	for i, hInput in flds
	{
		GuiControlGet text,, %hInput%
		ret.output[A_Index] := text
	}
	if ( NumGet( &(ret.output) + 4 * A_PtrSize ) <= 1 )
		ret.output := ret.output[1]
	
	;// Destroy tooltip
	if hTip
		DllCall("DestroyWindow", "Ptr", hTip)
	Gui Destroy
	return

EF_SelectFile: ;// FileSelectFile(v1.1) / FileSelect(v2.0-a) workaround
	hInput     := btns[A_GuiControl].input
	, options  := btns[A_GuiControl].options
	; , flags    := fld.options[1]
	, root_dir := options[2]
	, prompt   := options[3]
	, filter   := options[4]

	;// Output goes here
	VarSetCapacity(lpstrFile, 0xffff)

	;// Flags member -> OFN_EXPLORER|OFN_FILEMUSTEXIST|OFN_HIDEREADONLY
	flags := 0x80000|0x1000|0x4

	;// Setup lpstrFilter member of OPENFILENAME struct
	VarSetCapacity( lpstrFilter, 2*StrLen(filter) * (A_IsUnicode ? 2 : 1), 0 )
	, ext := SubStr(filter, InStr( filter,"(" )+1, -1)
	, flen1 := (StrLen(filter) + 1) * (A_IsUnicode ? 2 : 1)
	, flen2 := (StrLen(ext) + 1) * (A_IsUnicode ? 2 : 1)
	, StrPut(filter, &lpstrFilter + 0, flen1)
	, StrPut(ext, &lpstrFilter + flen1, flen2)
	, NumPut(0, lpstrFilter, flen1 + flen2, A_IsUnicode ? "UShort" : "UChar")

	;// Create OPENFILENAME struct
	VarSetCapacity(OPENFILENAME, sizeof_OFN, 0)
	, NumPut(sizeof_OFN, OPENFILENAME, 0, "UInt")                ;// lStructSize
	, NumPut(A_Gui, OPENFILENAME, 4, "Ptr")                      ;// hwndOwner
	, NumPut(&lpstrFilter, OPENFILENAME, 4 + 2*A_PtrSize, "Ptr") ;// lpstrFilter
	, NumPut(1, OPENFILENAME, 8 + 4*A_PtrSize, "UInt")           ;// nFilterIndex
	, NumPut(&lpstrFile, OPENFILENAME, 12 + 4*A_PtrSize, "Ptr")  ;// lpstrFile
	, NumPut(0xffff, OPENFILENAME, 12 + 5*A_PtrSize, "UInt")     ;// nMaxFile
	, NumPut(&root_dir, OPENFILENAME, 20 + 6*A_PtrSize, "Ptr")   ;// lpstrInitialDir
	, NumPut(&prompt, OPENFILENAME, 20 + 7*A_PtrSize, "Ptr")     ;// lpstrTitle
	, NumPut(flags, OPENFILENAME, 20 + 8*A_PtrSize, "UInt")      ;// Flags

	if !DllCall("comdlg32\GetOpenFileName", "Ptr", &OPENFILENAME)
		return
	
	;// selected := DllCall("MulDiv", "Int", &lpstrFile, "Int", 1, "Int", 1, "Str")
	selected := StrGet( &lpstrFile )
	if ( StrLen(selected) != 3 )
		selected .= "\"
	GuiControl,, %hInput%, % SubStr(selected, 1, -1)
	return

EF_SelectDir: ;// FileSelectFolder / DirSelect workaround
	hInput    := btns[A_GuiControl].input
	, options := btns[A_GuiControl].options
	, shell   := ComObjCreate("Shell.Application")
	
	if !( folder := shell.BrowseForFolder(
	(Join Q C
		0,
		"Select a folder:",
		0x1|0x40|0x4000,
		A_MyDocuments
	)) )
		return
	
	GuiControl,, %hInput%, % folder.self.Path
	return

EF_SetToolTip:
	if !NumGet( &tt + 4 * A_PtrSize ) ;// no arguments
		return
	
	if !hTip
	{
		hTip := DllCall(
		(Join Q C
			"CreateWindowEx",
			"UInt", 0x00000008, ;// WS_EX_TOPMOST:=0x8
			"Str",  "tooltips_class32",
			"Ptr",  0,
			"UInt", 0x80000002, ;// WS_POPUP:=0x80000000|TTS_NOPREFIX:=0x02
			"Int",  0x80000000,
			"Int",  0x80000000,
			"Int",  0x80000000,
			"Int",  0x80000000, ;// CW_USEDEFAULT:=0x80000000
			"Ptr",  hForm,
			"Ptr",  0,
			"Ptr",  0,
			"Ptr",  0,
			"Ptr"
		))
		;// TTM_SETMAXTIPWIDTH:=0x0418
		DllCall("SendMessage", "Ptr", hTip, "Int", 0x0418, "Ptr", 0, "Ptr", 0)
		;// for Windows XP
		if is_xp
		{
			tt_tmp := tt, tt := { "ctrl": hForm, "text": "" }
			gosub EF_SetToolTip ;// attach empty tip to GUI
			tt := tt_tmp, tt_tmp := ""
		}
	}

	;// Create TOOLINFO struct and set members
	VarSetCapacity(TOOLINFO, sizeof_TOOLINFO, 0)
	, NumPut(sizeof_TOOLINFO, TOOLINFO, 0, "UInt")
	, NumPut(0x11, TOOLINFO, 4, "UInt") ;// TTF_IDISHWND:=0x0001|TTF_SUBCLASS:=0x0010
	, NumPut(hForm, TOOLINFO, 8, "Ptr")
	, NumPut(tt.ctrl, TOOLINFO, 8 + A_PtrSize, "Ptr")
	, NumPut(ObjGetAddress(tt, "text"), TOOLINFO, 24 + (3 * A_PtrSize), "Ptr")

	;// TTM_ADDTOOL := A_IsUnicode ? 0x0432 : 0x0404
	DllCall("SendMessage", "Ptr", hTip, "Int", TTM_ADDTOOL, "Ptr", 0, "Ptr", &TOOLINFO)
	tt := {}
	return
}