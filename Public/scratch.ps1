return

$Script:Action = {

    # Persist search criteria between PropertyChanged events
    $MyModule = Get-Module PSISEReadline | Select-Object -First 1

    (
        $Log,
        $LogProps,
        $Commands,
        $LastHistoryId,
        $EventSplat

    ) = & $MyModule {

        $Script:Log,
        $Script:LogProps,
        $Script:Commands,
        $Script:LastHistoryId
        $Script:EventSplat
    }


    $LastRun = $Log[-1]
    $ThisRun = 1 | select $LogProps
    $null    = $Log.Add($ThisRun)


    Unregister-Event -SourceIdentifier $EventSplat.SourceIdentifier -ErrorAction Ignore


    $ConsolePane    = $EventSplat.InputObject
    $PaneType       = $ConsolePane.GetType()
    $Field          = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')

    # Input buffer before user hit the shortcut
    $ThisRun.Buffer = $Field.GetValue($ConsolePane)


    if ($LastRun -and -not $LastRun.Buffer)
    {
        Write-Host "completed" -ForegroundColor Green
        $ConsolePane.InputText = ''
        return
    }

    # Emergency bailout
    if ($Log.Count -gt 10) {return}


    $ThisRun.SearchString = $LastRun.SearchString
    if (-not $ThisRun.SearchString)
    {
        $ThisRun.SearchString = $ThisRun.Buffer
    }


    $ThisRun.FoundCommand = if ($ThisRun.SearchString)
    {
        $Commands -like "*$($ThisRun.SearchString)*" |
            Select -Last 1
    }


    if ($ThisRun.FoundCommand)
    {
        Write-Host "here" -ForegroundColor Green
        $ConsolePane.InputText = $ThisRun.FoundCommand.CommandLine
    }


    $null = Register-ObjectEvent @EventSplat
}


function bck-i-search
{
    $Script:EventSplat = @{
        InputObject = $psISE.CurrentPowerShellTab.ConsolePane
        EventName = 'PropertyChanged'
        Action = $Script:Action
        MaxTriggerCount = 1
        SourceIdentifier = 'PaneChanged'
    }

    $Script:Log = [System.Collections.ArrayList]::new()
    $Global:Log = $Script:Log
    $Script:LogProps = (
        'SearchString',
        'FoundCommand',
        #'Count',
        'Buffer'
        #'LastBuffer',
        #'LastHistoryId',
        #'BufferHasBeenPopulated',
        #'BufferHasBeenCleared'
    )

    $Script:Commands = Get-History |
        where CommandLine -notmatch 'bck-i-search' |
        sort CommandLine -Unique |
        sort Id

    $Script:LastHistoryId = (Get-History -Count 1).Id + 1

    Unregister-Event -SourceIdentifier $EventSplat.SourceIdentifier -ErrorAction Ignore
    Remove-Event -SourceIdentifier $EventSplat.SourceIdentifier -ErrorAction Ignore


    $null = Register-ObjectEvent @EventSplat
}
