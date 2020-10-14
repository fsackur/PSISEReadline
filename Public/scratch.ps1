$Script:Action = {

    $ChangedProperty = $args[1].PropertyName
    $null = $CP.Add($ChangedProperty)
    if ($ChangedProperty -eq 'CaretLine')
    {
        # Unregister-Event -SourceIdentifier PaneChanged
    }

    # $psISE.CurrentPowerShellTab.ConsolePane
    $Pane = $args[0]
    $PaneType = $Pane.GetType()
    $Field = $PaneType.GetField('inputTextBeforeExecution', 'nonpublic,instance')

    # Input buffer before user hit the shortcut
    $InputTextBeforeExecution = $Field.GetValue($Pane)

    # Store search criteria
    $MyModule = Get-Module PSISEReadline | Select-Object -First 1

    $SearchString = & $MyModule {$Script:SearchString}
    if (-not $SearchString)
    {
        $SearchString = $InputTextBeforeExecution
        & $MyModule {$Script:SearchString = $args[0]} $SearchString
    }

    Write-Host $SearchString -ForegroundColor Yellow

    $FoundCommand = Get-History | ? CommandLine -like "*$SearchString*" | Select -Last 1

    Write-Host $FoundCommand.CommandLine -ForegroundColor Yellow

    & $MyModule {$Script:FoundCommand = $args[0]} $FoundCommand

    $Pane.InputText = $FoundCommand.CommandLine
}


function bck-i-search
{
    Unregister-Event -SourceIdentifier PaneChanged -ErrorAction Ignore
    $Global:CP = [System.Collections.ArrayList]::new()

    $MyModule = $MyInvocation.MyCommand.Module
    & $MyModule {$Script:SearchString = $Script:FoundCommand = $null}

    $null = Register-ObjectEvent -InputObject $psISE.CurrentPowerShellTab.ConsolePane -EventName PropertyChanged -Action $Script:Action -MaxTriggerCount 1 -SourceIdentifier PaneChanged
}
