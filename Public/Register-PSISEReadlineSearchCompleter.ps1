function Register-PSISEReadlineSearchCompleter
{
    Register-ArgumentCompleter -CommandName bck-i-search -ParameterName SearchString -ScriptBlock {
        param
        (
            $commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters
        )

        [string[]]$History = Get-History |
            sort Id -Descending |
            select -ExpandProperty CommandLine -First 1000

        # exclude self
        $History = $History -notmatch '^bck-i-search'

        # Deduplicate - this relies on HashSet.Add returning False when item already in set
        [System.Collections.Generic.HashSet[string]]$UniqueHistory = @()
        $History = $History | where {$UniqueHistory.Add($_)}

        # return matching
        $History -like "*$wordToComplete*"
    }
}
