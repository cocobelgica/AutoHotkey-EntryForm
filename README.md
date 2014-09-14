# EntryForm
### InputBox alternative for [AutoHotkey](http://www.ahkscript.org/)

Requires AutoHotkey _v1.1+_ OR _v2.0-a049+_

License: [WTFPL](http://wtfpl.net/)

- - -

### Syntax:
```javascript
output := EntryForm( form, fields* )
```

### Return Value:
```javascript
out := {
    "event":  [ OK, Cancel, Close, Escape, Timeout ], // [string] either of these
    "output": [ field1, field2, ... ] // array containing the output of each input field
}
```

**Remarks:**

  * If the EntryForm has only one(1) field, ``.output`` will contain a string, the value itself


### Parameters:

```
form               [in] - string OR associative array specifying EntryForm window's options
fields*  [in, variadic] - string OR associative array specifying each field's options
```


##### Form ``[in]``:

```javascript
form [-cap | -c <caption>] [-fnt | -f <fontspec>] [-ico | -i <iconspec>] [-t <timeout>]
     [-pos | -p <position>] [-opt | -o <options>]
```

A space-delimited string containing one or more of the following below. Options are passed in _command line-like_ syntax. _**Note:** if an argument contains a **space**, it must be enclosed in **single** quotes. Multiple arguments are delimited by a **comma**_:

Option = Argument(s) |  Description
----------------|------------
``-cap OR -c <caption>`` | window caption / title
``-fnt OR -f <options,name>`` | Gui font, argument(s) is the same as in [Gui, Font](http://ahkscript.org/docs/commands/Gui.htm#Font)
``-ico OR -i <icon,icon-no>`` | window icon, *icon* can be a _file_, _exe_ or _dll_
``-t <timeout>``<br>``Tn`` | timeout in milliseconds. ``-t <timeout>`` syntax can<br> simply be written as ``Tn``, where *n* is the amount in ms.
``-F <function>``<br>``Ffunction`` | callback function. Output is passed as 1st parameter.<br>_-F_ is case sensitive when using dash ``-`` syntax
``-pos OR -p <Xn Yn Wn>``<br>``Xn Yn Wn`` |Window position, same as in [Gui, Show](http://ahkscript.org/docs/commands/Gui.htm#Show). Default is<br>``xCenter yCenter w375`` 
``-opt OR -o <options>``<br>``[ options ... ]`` | standard Gui [options](http://ahkscript.org/docs/commands/Gui.htm#Options) ``e.g.: +ToolWindow etc.``

**Remarks:**

 * Window height must not be specified - it is calculated automatically based on the total number of input fields
 * For _-ico_, the same icon will be used for the window caption (small) and the Alt+Tab switcher (large)
 * If a callback function is defined (via _-F_ option), the function will return immediately instead of waiting for the window to close. Function must require atleast one(1) parameter. However, if a _-t_ (timeout) is defined, callback function is ignored
 
**Example:**

```javascript
/* If window position is not specified, it is shown in the center
 * The '-fnt' option applies to fields(controls) whose '-fnt' option is not specified
 */
form := "-c 'Test Form' -ico 'cmd.exe,0' -fnt 's10 cBlue,Consolas' T5000 w500 +ToolWindow"
/* Optional syntax for timeout, pos and options
 * form := "-t 5000 -pos 'x0 w500' -o '+ToolWindow -Caption'"
 */
output := EntryForm(form, ...)
```
<br>

##### Fields ``[in, variadic]``:

```
field (-p <prompt>) [-d <default>] [-fnt <fontspec>] [-cb <cuebanner>] [-tt <tooltip>]
      [-ud <updown>] [-fs <fileselect>] [-ds <dirselect>] [-opt | -o <options>]
```

A space-delimited string containing one or more of the following below. Options are passed in _command line-like_ syntax. _**Note:** if an argument contains a **space**, it must be enclosed in **single** quotes. Multiple arguments are delimited by a **comma**_:

Option = Argument(s) | Description
----------------|------------
``-p <prompt>`` | similar to _Prompt_ parameter of [InputBox](http://ahkscript.org/docs/commands/InputBox.htm). This<br> option is **required**.
``-d <default-text>`` | similar to _Default_ parameter of [InputBox](http://ahkscript.org/docs/commands/InputBox.htm)
``-fnt <options,name;options,name>`` | a semicolon separates the arguments for the prompt<br>and the arguments for the input field
``-cb <cuebanner>`` | textual cue, or tip, that is displayed by the<br>_Edit_ control
``-tt <tooltip>`` | tooltip for the input field, shown when mouse<br>cursor is over the _Edit_ control
``-ud <updown-ctrl-options>`` | attaches an UpDown control to the input field.<br>``updown-ctrl-options`` are the same as in<br>[Gui, Add, UpDown](http://ahkscript.org/docs/commands/GuiControls.htm#UpDown)
``-fs <fileselectfile-args>`` | a button is placed to the right of the input field.<br>When pressed, a [FileSelectFile](http://ahkscript.org/docs/commands/FileSelectFile.htm) dialog is shown.<br>``fileselectfile-args`` is the same as in<br>_FileSelectFile_ command.
``-ds <fileselectfolder-args>`` | same as _File_ above, but works like [FileSelectFolder](http://ahkscript.org/docs/commands/FileSelectFolder.htm)
``-opt OR -o <options>``<br>``[ options ... ]`` | standard [options](http://ahkscript.org/docs/commands/GuiControls.htm#Edit_Options) that apply to _Edit_ controls<br>should work e.g.: ``R1 -Wrap +HScroll``

**Remarks:**

 * For _-fs_ and _-ds_, order of the arguments is the same as in their counterpart AHK commands
 * Input field width must not be specified, it is calculated automatically based on the EntryForm window width as specified in _form_ parameter
 * For _-fs_ and _-ds_, if the button's associated _Edit_ control is **NOT** empty, a [SplitPath](http://ahkscript.org/docs/commands/SplitPath.htm) will be performed on the text(contents), _OutDir_ will be used as the initial directory and _OutFileName_ will be used as the initial file name (latter applies to _-fs_) when the dialog is shown.

**Example:**

```javascript
/* For options which require arguments to be enclosed in single quotes, to specify a literal
 * single quote, escape it with a backslash '\'
 */
field1 := "-p 'Enter your password:' -fnt 'Italic,Segoe UI' -cb 'Password here' R1 Password"

/* For '-fs' option, separate each argument with a comma, order of arguments is the same as
 * FileSelectFile command: [ Options, RootDir\Filename, Prompt, Filter ]
 */
field2 := "-p 'File to upload:' -fs '1,C:\Dir,Select a file,Text Document (*.txt; *.tex)'"

out := EntryForm(form, field1, field2)
```

<br>

### Remarks:

 * Behavior is similar to that of the _InputBox_ command, that is the script will  be in a _waiting state_ while the _EntryForm_ window is shown. To bypass this, the caller can use a [timer](http://ahkscript.org/docs/commands/SetTimer.htm) or define a callback function using the _-F_ option - see _Form_ options above.