$Script:var = 2
<#
$EventSplat = @{
    InputObject = $psISE.CurrentPowerShellTab.ConsolePane
    EventName = 'PropertyChanged' 
    Action = {handlePropertyChanged $args[0] $args[1]}
    MaxTriggerCount = 1 
    SourceIdentifier = 'PaneChanged'
}
Register-ObjectEvent @EventSplat
#>

function handlePropertyChanged
{
    param
    (
        $Sender,
        $EventArgs
    )
    Write-Host $MyInvocation.MyCommand.Module.Name
    Write-Host $EventArgs
    Write-Host $Var
}
