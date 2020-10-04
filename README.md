# PSISEReadline

[PSReadLine](https://github.com/PowerShell/PSReadLine) is a major advance for me. I use bck-i-search very frequently to search and invoke commands from my history (Ctrl-R in any modern powershell console).

However, it is not supported, and will not import, in ISE. (See: https://github.com/PowerShell/PSReadLine/issues/401)

I still use ISE because it's great for debugging and quick edits, so: this is my approximate implementation of bck-i-search for ISE.

# Usage

Run this command, e.g. in your profile:

``` powershell
Register-PSISEReadlineShortcut
```

This adds `Ctrl-E` as a keyboard shortcut. (`Ctrl-R` is taken already.)

Hitting `Ctrl-E` will start bck-i-search. You can enter a substring and use tab-completion to search back in your command history. When you press `Enter`, the commandline will be invoked.
