function Invoke-PSISEReadline
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [AllowNull()]
        $SearchString,

        [Parameter(DontShow, ValueFromRemainingArguments)]
        $Remainder
    )

    <#
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
    #>

    # $psISE.CurrentPowerShellTab.ConsolePane.InputText

    <#
    $ConsolePane = $psISE.CurrentPowerShellTab.ConsolePane
    $PaneType = $ConsolePane.GetType()
    $Field = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')
    $InputTextBeforeExecution = $Field.GetValue($ConsolePane)
    $Global:i = $InputTextBeforeExecution
    # THis doesn't work; inputtextbefore is empty. Presumably it is only populated by ISE's favoured children.
    #>
    #$MyInvocation | Out-String | Write-Host -ForegroundColor Green
    
    
    $Action = {
        #$args | Out-string | Write-Host -ForegroundColor Green
        # $eventargs | Out-string | Write-Host -ForegroundColor Green
        #'foo' | Out-string | Write-Host -ForegroundColor Green
        Rename-Item Function:\_prompt prompt -Force
    }
    $null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        # Rename-Item Function:\_prompt prompt -Force
        Set-Item function:\global:prompt
        $psISE.CurrentPowerShellTab.ConsolePane.InputText = 'foo'
    }
    Copy-Item Function:\prompt Function:\_prompt
    function Global:prompt {"`b`b`b`b"}
    # function prompt {"PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "}


    #$Global:i = $MyInvocation
    break

    $Invocation = $MyInvocation.InvocationName
    $CommandLine = (Get-History $MyInvocation.HistoryId).CommandLine
    $Global:i = $CommandLine -replace "^$([regex]::Escape($Invocation)) +"

    break
}
