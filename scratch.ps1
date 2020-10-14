function bck-i-search
{
    $Action = {

        Unregister-Event -SourceIdentifier PaneChanged
        
        # $psISE.CurrentPowerShellTab.ConsolePane
        $Pane = $args[0]
        $PaneType = $Pane.GetType()
        $Field = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')
        $InputTextBeforeExecution = $Field.GetValue($Pane)
        
        #$Pane.InputText = ((Get-History).CommandLine -like "*$inputTextBeforeExecution*" | Select -Last 1) #-join "`r`n"
        Write-host ((Get-History).CommandLine -like "*$inputTextBeforeExecution*" | Select -Last 1) -ForegroundColor Green
    }

    $null = Register-ObjectEvent -InputObject $psISE.CurrentPowerShellTab.ConsolePane -EventName PropertyChanged -Action $Action -MaxTriggerCount 1 -SourceIdentifier PaneChanged

}
