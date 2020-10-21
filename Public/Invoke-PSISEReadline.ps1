function Invoke-PSISEReadline
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [AllowNull()]
        $SearchString,

        [Parameter(DontShow, ValueFromRemainingArguments)]
        $Remainder
    )


    # $psISE.CurrentPowerShellTab.ConsolePane.InputText


    # If user hit shortcut with test in the buffer, capture it
    $ConsolePane = $psISE.CurrentPowerShellTab.ConsolePane
    $PaneType = $ConsolePane.GetType()
    $Field = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')
    $InputTextBeforeExecution = $Field.GetValue($ConsolePane)
    $SearchString = $InputTextBeforeExecution



    break
}
