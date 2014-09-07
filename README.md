# EntryForm
### InputBox alternative for [AutoHotkey](http://www.ahkscript.org/)

Tested on AHK **v1.1.15.04** and **v2.0-a049**

License: **[WTFPL](http://wtfpl.net/)**

- - -

#### Syntax:
```javascript
output := EntryForm( form, fields* )
```

#### Return Value:
```javascript
out := { "event": [ OK, Cancel, Close, Escape, Timeout ] , "output": [ field1, field2, ... ] }
```

#### Parameters:
```
form               [in] - string OR associative array specifying EntryForm window's options
fields*  [in, variadic] - string OR associative array specifying each field's options
```

##### Form _(argument passed as string)_

A space-delimited string containing one or more of the following option(s):

* Title**'**_window-title-here_**'** - the window's caption
* Icon**'**_icon-source **,** icon-number_**'** - small_(caption)_ and large_(Alt+Tab, taskbar)_ icon
* Font**'**_font-options **,** font-name_**'** - global font, similar to _[Gui, Font](http://ahkscript.org/docs/commands/Gui.htm#Font)_
* Tn - timeout, where **n** is the amount in milliseconds
* Xn, Yn, Wn - window position, similar to _[Gui, Show](http://ahkscript.org/docs/commands/Gui.htm#Show)_, _(height is automatically calculated)_

**Example:**
```javascript
/* If window position is not specified, it is shown in the center
 * The 'Font' option applies to fields(controls) whose 'Font' is not specified
 * Take note that the arguments for 'Title', 'Icon' and 'Font' are enclosed in
 * single quotes.
 */
form := "Title'Test EntryForm' Icon'cmd.exe,0' Font's10 cBlue,Consolas' T5000"
output := EntryForm(form, ...)
```

##### Fields _(argument(s) passed as string)_

A space-delimited string containing one or more of the following option(s):

 * Prompt**'**_prompt-here_**'** - similar to _prompt_ parameter of InputBox
 * Default**'**_default-text_**'** - similar to _default_ parameter of InputBox
 * Font**'**_prompt-font-options **,** prompt-font-name **;** input-font-options **,** input-font-name_**'** - arguments for prompt and input field are separated by a semicolon
 * Cue**'**_edit-field-cue-banner_**'** - textual cue, or tip, that is displayed by the edit control to prompt the user for information
 * Tip**'**_tooltip-text_**'** - if specified, a tooltip is shown when the mouse hovers on the input field_(Edit control)_
 * UpDown**'**_updown-control-options_**'** - attaches an UpDown control to the input field, options is the sames _[Gui Add, UpDown](http://ahkscript.org/docs/commands/GuiControls.htm#UpDown)_
 * File**'**_fileselectfile-args-here_**'** - if specified, a button is placed to the right of the input field to allow user(s) to browse for file(s). Similar to _[FileSelectFile](http://ahkscript.org/docs/commands/FileSelectFile.htm)_
 * Dir**'**_fileselectfolder-args-here_**'** - if specified, a button is placed to the right of the input field to allow user(s) to browse for a folder. Similar to _[FileSelectFolder](http://ahkscript.org/docs/commands/FileSelectFolder.htm)_
 * Others - options that apply to Edit controls should work. _(e.g.: R1 HScroll -Wrap etc..)_

**Example:**
```javascript
/* For options which require arguments to be enclosed in single quotes, to specify a literal
 * single quote, escape it with a backslash '\'
 */
field1 := "Prompt'Please enter your password:' Font'Italic,Segoe UI' Cue'Password here' R1 Password"

/* For 'File' option, separate each argument with a comma, order of arguments is the same as
 * FileSelectFile: [ Options, RootDir\Filename, Prompt, Filter ]
 */
field2 := "Prompt'File to upload:' File'1,C:\Users\user_name,Select a file,Text Document (*.txt; *.tex)'"

out := EntryForm(form, field1, field2)
```