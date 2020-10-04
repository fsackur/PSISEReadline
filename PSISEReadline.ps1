function bck-i-search
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        $SearchString,

        [Parameter(DontShow, ValueFromRemainingArguments)]
        $Remainder
    )

    # There's a noticeable lag if your session has a lot of text
    # We want to allow multi-line commandlines, and that makes the regex slower
    $MaxCommandLength = 1000
    $ConsoleText = $psISE.CurrentPowerShellTab.ConsolePane.Text
    if ($ConsoleText.Length -gt $MaxCommandLength)
    {
        $ConsoleText = $ConsoleText.SubString(($ConsoleText.Length - $MaxCommandLength))
    }

    # regex ref: https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference
    $Pattern = @(
        '(?s)' +                    # singleline mode - newline chars are included
        '(?<=bck-i-search )' +      # Get all text after the string 'bck-i-search '
        '(?!.*bck-i-search )' +     # ... that does not also contain the string 'bck-i-search ' (negative lookahead)
        '.*$'                       # get it all
    )

    # After you press Enter, get the history from the console - if we use the parameters, we have
    # major headaches for commandlines including, e.g., pipes and assignments.
    if ($ConsoleText -match $Pattern)
    {
        $Command = $Matches[0]
        $Command | Write-Host -ForegroundColor Green
    }
    else
    {
        'bck-i-search: No match found.' | Write-Host -ForegroundColor Red

        # Stop the pipeline
        break
    }


    # Stop the pipeline, in case you're retrieving a commandline containing a pipe.
    # In that case, the commandline parser will treat it as a literal pipeline
    break
}


#region Tab-complete from history
Register-ArgumentCompleter -CommandName bck-i-search -ParameterName SearchString -ScriptBlock {
    param
    (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    [string[]]$History = Get-History |
        sort Id -Descending |
        select -ExpandProperty CommandLine -First 1000

    # exclude self
    $History = $History -notmatch '^bck-i-search'

    # Deduplicate - this relies on HashSet.Add returning False when item already in set
    [System.Collections.Generic.HashSet[string]]$UniqueHistory = @()
    $History = $History | where {$UniqueHistory.Add($_)}

    # return matching
    $History -like "*$wordToComplete*"
}
#endregion Tab-complete from history



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
