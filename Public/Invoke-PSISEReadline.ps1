function Invoke-PSISEReadline
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
        # $Command | Write-Host -ForegroundColor Green
    }
    else
    {
        'bck-i-search: No match found.' | Write-Host -ForegroundColor Red

        # Stop the pipeline
        break
    }


    # Do the thing!
    $Command | Invoke-Expression


    # Stop the pipeline, in case you're retrieving a commandline containing a pipe.
    # In that case, the commandline parser will treat it as a literal pipeline
    break
}
