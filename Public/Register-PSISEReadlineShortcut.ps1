function Register-PSISEReadlineShortcut
{
    $Shortcut = "Ctrl+E"
    $MenuItemName = "bck-i-search"

    # place text in the input buffer, ready for tab-completion
    #$Action = {bck-i-search}
    $Action = {$psISE.CurrentPowerShellTab.ConsolePane.InputText = "bck-i-search "}


    # Clear existing entries of our command
    $SubMenus = $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus
    [void]$SubMenus.Where({$_.DisplayName -eq $MenuItemName}).ForEach({$SubMenus.Remove($_)})


    # We need a menu entry to bind a shortcut
    try
    {
        [void]$Submenus.Add($MenuItemName, $Action, $Shortcut)
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
}
