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
            $null = $Global:KeyHistory.Add($EventArgs)
        }


        $Char = $ShouldExit = $ShouldInvoke = $null
        switch ($KeyData)
        {
            $null           {break}
            'C, Control'    {$ShouldExit = $true; break}
            'Escape'        {$ShouldExit = $true; break}
            'Return'        {$ShouldExit = $true; $ShouldInvoke = $true; break}
            'left'          {$ShouldExit = $true; break}
            'right'         {$ShouldExit = $true; break}
            'up'            {$ShouldExit = $true; break}
            'down'          {$ShouldExit = $true; break}
            'space'         {$Global:_BCK_I_SEARCH += ' '; break}
            'back'
            {
                if (-not $Global:_BCK_I_SEARCH) {break}
                $Global:_BCK_I_SEARCH = $Global:_BCK_I_SEARCH.Substring(0, ($Global:_BCK_I_SEARCH.Length-1))
                break
            }
            Default
            {
                if ($_.ToString().Length -gt 1) {break}
                $Global:_BCK_I_SEARCH += $Char = $_.ToString().ToLower()
            }
        }

        $FoundCommand = $Global:History -like "*$Global:_BCK_I_SEARCH*" | select -First 1

        if ($ShouldExit)
        {
            if ($ShouldInvoke)
            {
                $psISE.CurrentPowerShellTab.ConsolePane.InputText = $FoundCommand
            }
            else
            {
                $psISE.CurrentPowerShellTab.ConsolePane.InputText = ""
            }

            Unregister-Event -SourceIdentifier 'bck-i-search' -ErrorAction SilentlyContinue
            & (gmo PSISEReadline | select -First 1) {$HOOK.StopCapturing()}
        }
        else
        {
            $psISE.CurrentPowerShellTab.ConsolePane.InputText = "`r`n$FoundCommand`r`nbck-i-search: $Global:_BCK_I_SEARCH"
        }
    }


    [string[]]$Global:History = Get-History |
        sort Id -Descending |
        select -ExpandProperty CommandLine -First 1000


    # Deduplicate - this relies on HashSet.Add returning False when item already in set
    [System.Collections.Generic.HashSet[string]]$UniqueHistory = @()
    $Global:History = $Global:History -notmatch '^bck-i-search' |
        where {$UniqueHistory.Add($_)}


    if ($Global:Debug)
    {
        $Global:KeyHistory = [System.Collections.ArrayList]::new()
    }

    Unregister-Event -SourceIdentifier 'bck-i-search' -ErrorAction SilentlyContinue
    $null = Register-ObjectEvent -InputObject $HOOK -EventName KeyDown -SourceIdentifier 'bck-i-search' -Action $Action
    $HOOK.StartCapturing()

    & $Action
}
