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
out := {
    "event":  [ OK, Cancel, Close, Escape, Timeout ], // [string] either of these
    "output": [ field1, field2, ... ] // array containing the output of each input field
}
```

#### Parameters:
```
form               [in] - string OR associative array specifying EntryForm window's options
fields*  [in, variadic] - string OR associative array specifying each field's options
```


##### Form Options:

A space-delimited string containing one or more of the following below. _Note: some argument(s) following the option name must be surrounded with single quotes ``'``_:

Option / Syntax | Description
----------------|------------
``Title'window-title'`` | Window caption, surround _window-title_ with single quotes
``Icon'icon,icon-number'`` | _icon_ can be an icon file, exe or dll. _icon-number_ is optional
``Font'options,name'`` | Global font, usage is the same as in _[Gui, Font](http://ahkscript.org/docs/commands/Gui.htm#Font)_
``Tn`` | Timeout, where _n_ is the amount in milliseconds
``Xn, Yn, Wn`` | Window position, same as in _[Gui, Show](http://ahkscript.org/docs/commands/Gui.htm#Show)_

**Remarks:**

 * Window height must not be specified - it is calculated automatically based on the total number of input fields
 * For _Icon_, the same icon will be used for the window caption (small) and the Alt+Tab switcher (large) 
 
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


##### Fields Options:

A space-delimited string containing one or more of the following below. _Note: some argument(s) following the option name must be surrounded with single quotes ``'``_:

Option / Syntax | Description
----------------|------------
``Prompt'prompt-text'`` | similar to _Prompt_ parameter of _[InputBox](http://ahkscript.org/docs/commands/InputBox.htm)_
``Default'default-text'`` | similar to _Default_ parameter of _[InputBox](http://ahkscript.org/docs/commands/InputBox.htm)_
``Font'options,name;options,name'`` | a semicolon separates the options for the prompt and the options for the input field
``Cue'cue-banner'`` | textual cue, or tip, that is displayed by the _Edit_ control
``Tip'tooltip-text'`` | tooltip for the input field, shown when mouse cursor is over the _Edit_ control
``UpDown'options'`` | attaches an UpDown control to the input field. UpDown control _options_ are the same as in _[Gui, Add, UpDown](http://ahkscript.org/docs/commands/GuiControls.htm#UpDown)_
``File'fileselect-args'`` | a button is placed to the right of the input field. When pressed, a _[FileSelectFile](http://ahkscript.org/docs/commands/FileSelectFile.htm)_ dialog is shown.
``Dir'dirselect-args'`` | same as _File_ above, but works like _[FileSelectFolder](http://ahkscript.org/docs/commands/FileSelectFolder.htm)_
``Others`` | common options that apply to _Edit_ controls should work e.g.: ``R1 -Wrap HScroll``

**Remarks:**

 * For _File_ and _Dir_, order of arguments is the same is in their counterpart AHK commands
 * Input field width must not be specified - it is calculated automatically based on the EntryForm window width

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