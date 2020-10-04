function bck-i-search
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        $Command,

        # This is not looked at - its existence allows otherwise-syntactically-invalid input
        [Parameter(DontShow, ValueFromRemainingArguments)]
        $Remainder
    )
}


#region Bind ISE shortcut
$Shortcut = "Ctrl+E"
$MenuItemName = "bck-i-search"
# place text in the input buffer, ready for tab-completion
$Action = {
    $psISE.CurrentPowerShellTab.ConsolePane.InputText = "bck-i-search "
}


# Clear existing entries of our command
$SubMenus = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus
[void]$SubMenus.Where({$_.DisplayName -eq $MenuItemName}).ForEach({$SubMenus.Remove($_)})


# We need a menu entry to bind a shortcut
try
{
    [void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
        $MenuItemName,
        $Action,
        $Shortcut
    )
}
catch
{
    if ($_ -match "uses shortcut '.*', which is already in use")
    {
        Write-Warning "Failed to bind '$Shortcut' to bck-i-search; already in use."
    }
    else
    {
        throw
    }
}

# Cleanup, since we're expecting to be dot-sourced
Remove-Variable Action, Shortcut, MenuItemName, SubMenus

#endregion Bind ISE shortcut
