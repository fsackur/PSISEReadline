$Script:Action = {

    Unregister-Event -SourceIdentifier PaneChanged -ErrorAction Ignore


    # $psISE.CurrentPowerShellTab.ConsolePane
    $Pane = $args[0]
    $PaneType = $Pane.GetType()
    $Field = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')
    # Input buffer before user hit the shortcut
    $Buffer = $Field.GetValue($Pane)


    # Persist search criteria between PropertyChanged events
    $MyModule = Get-Module PSISEReadline | Select-Object -First 1
    (
        $SearchString,
        $LastFoundCommand,
        [int]$Count,
        $Action,
        $LastBuffer,
        $LastHistoryId

    ) = & $MyModule {

        $Script:SearchString,
        $Script:LastFoundCommand,
        $Script:Count,
        $Script:Action,
        $Script:LastBuffer,
        $Script:LastHistoryId
    }


    $null = $Global:Log.Add([pscustomobject]@{
        SearchString = $SearchString
        LastFoundCommand = $LastFoundCommand
        Count = $Count
        Buffer = $Buffer
        LastBuffer = $LastBuffer
        LastHistoryId = $LastHistoryId
    })
    
    #sleep -Milliseconds 10
    #if ((Get-History -Count 1).Id -gt $LastHistoryId) {return}
    if ($Count -gt 1 -and -not $LastBuffer) {Write-Host "Buffer was cleared"; $Pane.InputText = ''; return}

    # Emergency bailout
    $Count++
    if ($Count -gt 10) {Write-Host "bailing out"; return}


    if (-not $SearchString)
    {
        $SearchString = $Buffer
    }

    
    $Commands = Get-History | 
        sort CommandLine -Unique |
        sort Id
        
    $FoundCommand = $Commands |
        ? CommandLine -like "*$SearchString*" | 
        Select -Last 1

    
    $TextHasChanged = $LastBuffer -ne $Buffer
    $CommandHasChanged = $LastFoundCommand -ne $FoundCommand

    # Write-Host $SearchString -ForegroundColor Yellow
    # Write-Host $FoundCommand.CommandLine -ForegroundColor Yellow


    
    & $MyModule {

        (
            $Script:SearchString,
            $Script:LastFoundCommand,
            $Script:Count,
            $Script:LastBuffer,
            $Script:LastHistoryId
        
        ) = $args
    
    } $SearchString $FoundCommand $Count $Buffer $LastHistoryId


    if ($Buffer -ne $FoundCommand.CommandLine)
    {}
    $Pane.InputText = $FoundCommand.CommandLine
    


    if ($TextHasChanged)
    {}
        
    $null = Register-ObjectEvent -InputObject $Pane -EventName PropertyChanged -Action $Script:Action -MaxTriggerCount 1 -SourceIdentifier PaneChanged
    
}


function bck-i-search
{
    #if (-not $Global:Log) {
    $Global:Log = [System.Collections.ArrayList]::new()

    (
        $Script:SearchString,
        $Script:LastFoundCommand,
        $Script:Count,
        $Script:LastBuffer,
        $Script:LastHistoryId
        
    ) = $null
    
    $Script:LastHistoryId = (Get-History -Count 1).Id + 1

    Unregister-Event -SourceIdentifier PaneChanged -ErrorAction Ignore
    Remove-Event -SourceIdentifier PaneChanged -ErrorAction Ignore
   
    $null = Register-ObjectEvent -InputObject $psISE.CurrentPowerShellTab.ConsolePane -EventName PropertyChanged -Action $Script:Action -MaxTriggerCount 1 -SourceIdentifier PaneChanged
}
