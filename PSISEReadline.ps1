function bck-i-search
{

}


try
{
    # We need a menu entry to bind a shortcut
    [void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
        "bck-i-search",
        {
            # Action: place text in the input buffer, ready for tab-completion
            $psISE.CurrentPowerShellTab.ConsolePane.InputText = 'bck-i-search '
        },
        "Ctrl+E"
    )
}
catch
{
    if ($_ -notmatch "uses shortcut '.*', which is already in use")
    {
        throw
    }
}
