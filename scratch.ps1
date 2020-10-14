function bck-i-search
{
    $Action = {

        Unregister-Event -SourceIdentifier PaneChanged
        
        # $psISE.CurrentPowerShellTab.ConsolePane
        if (-not $SearchString)
        {
            $Pane = $args[0]
            $PaneType = $Pane.GetType()
            $Field = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')
            $InputTextBeforeExecution = $Field.GetValue($Pane)
            $SearchString = $InputTextBeforeExecution
        }
        
        $Pane.InputText = (Get-History).CommandLine -like "*$SearchString*" | Select -Last 1
        #Write-host ((Get-History).CommandLine -like "*$SearchString*" | Select -Last 1) -ForegroundColor Green
    }

    $null = Register-ObjectEvent -InputObject $psISE.CurrentPowerShellTab.ConsolePane -EventName PropertyChanged -Action $Action -MaxTriggerCount 1 -SourceIdentifier PaneChanged

}
