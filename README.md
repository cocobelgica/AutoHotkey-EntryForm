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

```javascript
Title'window-title-here'       - the window's caption

Icon'icon-source, icon-number' - small(caption) and large(Alt+Tab, taskbar) icon

Font'font-options, font-name'  - global font, similar to "Gui, Font"

Tn                             - timeout, where "n" is the amount in milliseconds

Xn, Yn, Wn                     - window position, similar to "Gui, Show"
```

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

```javascript
Prompt'prompt-text'         - similar to "Prompt" parameter of InputBox

Default'default-text'       - similar to "Default" parameter of InputBox

/* Font:
 * pfo = prompt-font-options, pfn = prompt-font-name
 * ifo = input-font-options,  ifn = input-font-name
 */
Font'pfo,pfn ; ifo,ifn'     - a semicolon separates the options for the prompt and
                              the options for the input field

Cue'edit-field-cue-banner'  - textual cue, or tip, that is displayed by the edit control

Tip'tooltip-text'           - a tooltip is shown when the mouse hovers on the edit control

UpDown'updown-ctrl-options' - attaches an UpDown control to the input field. UpDown control
                              options are the same as in "Gui, Add, UpDown"

File'fileselectfile-args'   - a button is placed to the right of the input field. When
                              pressed, a "FileSelectFile" dialog is shown

Dir'fileselectfolder-args'  - same as "File" above, but works like "FileSelectFolder"

Others                      - options that apply to Edit controls should work.
                              e.g.: "R1 -Wrap HScroll"
```


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