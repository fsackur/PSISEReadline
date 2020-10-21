

try
{
    $Global:HOOK = [Open.WinKeyboardHook.KeyboardInterceptor]::new()
}
catch
{
    if ($_.FullyQualifiedErrorId -ne 'TypeNotFound')
    {
        throw
    }

    $Package = Get-Package Open.WinKeyboardHook
    if (-not $Package)
    {
        throw "Required package 'Open.WinKeyboardHook' is missing. To install, run 'Install-Package Open.WinKeyboardHook'."
    }

    $DllPath = $Package.Source |
        Split-Path |
        Join-Path -ChildPath lib |
        Join-Path -ChildPath net40 |
        Join-Path -ChildPath Open.WinKeyboardHook.dll

    Add-Type -Path $DllPath
}


Get-ChildItem $PSScriptRoot\Private\*.ps1 | ForEach-Object {. $_.FullName}
Get-ChildItem $PSScriptRoot\Public\*.ps1  | ForEach-Object {. $_.FullName}

Set-Alias bck-i-search Invoke-PSISEReadline

# Register-PSISEReadlineSearchCompleter
