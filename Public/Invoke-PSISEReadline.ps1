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
    $Global:_BCK_I_SEARCH = $InputTextBeforeExecution

    $Action = {
        # https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.keyeventargs?view=netcore-3.1
        $KeyData = $EventArgs.KeyData

        if ($Global:Debug)
        {
            $EventArgs | ft | Out-string | Write-Host -ForegroundColor Yellow -NoNewline
        }

        
        $Char = $ShouldExit = $ShouldInvoke = $null
        switch ($KeyData)
        {
            'C, Control' {$ShouldExit = $true; break}
            'Escape' {$ShouldExit = $true; break}
            'Return' {$ShouldExit = $true; $ShouldInvoke = $true; break}
            'left'   {$ShouldExit = $true; break}
            'right' {$ShouldExit = $true; break}
            'up'     {$ShouldExit = $true; break}
            'down'    {$ShouldExit = $true; break}
            'back'  {$Global:_BCK_I_SEARCH = $Global:_BCK_I_SEARCH.Substring(0, ($Global:_BCK_I_SEARCH-1)); break}
            Default {$Global:_BCK_I_SEARCH += $Char = $_.ToString().ToLower()}
        }

        if ($ShouldExit)
        {
            $psISE.CurrentPowerShellTab.ConsolePane.InputText = ""
            Unregister-Event -SourceIdentifier 'bck-i-search' -ErrorAction SilentlyContinue
            $prompt
        }
        else
        {
            $psISE.CurrentPowerShellTab.ConsolePane.InputText = "bck-i-search: $Global:_BCK_I_SEARCH"
        }
        # $Char | Write-Host -ForegroundColor Green -NoNewline
    }

    
    Unregister-Event -SourceIdentifier 'bck-i-search' -ErrorAction SilentlyContinue
    $null = Register-ObjectEvent -InputObject $HOOK -EventName KeyDown -SourceIdentifier 'bck-i-search' -MaxTriggerCount 6 -Action $Action
    $HOOK.StartCapturing()
}
