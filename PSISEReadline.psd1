@{
    Description          = 'A lightweight implementation of PSReadLine for ISE. Provides bck-i-search functionality.'
    ModuleVersion        = '0.1.0'
    HelpInfoURI          = 'https://github.com/fsackur/PSISEReadline'


    Author               = 'Freddie Sackur'
    CompanyName          = 'DustyFox'
    Copyright            = '(c) 2020 Freddie Sackur. All rights reserved.'


    CompatiblePSEditions = @('Desktop')
    PowerShellHostName   = 'Windows PowerShell ISE Host'
    PowerShellVersion    = '4.0'


    GUID                 = '96cab1e7-8645-4d9e-bb73-601c2555b08e'
    RootModule           = 'PSISEReadline.psm1'


    FunctionsToExport    = @(
        'Register-PSISEReadlineShortcut',
        'Invoke-PSISEReadline'      # Use the alias, though
    )
    AliasesToExport = @(
        'bck-i-search'
    )


    PrivateData          = @{
        PSData = @{
            LicenseUri = 'https://raw.githubusercontent.com/fsackur/PSISEReadline/main/LICENSE'
            ProjectUri = 'https://github.com/fsackur/PSISEReadline'
            Tags       = @(
                'Readline',
                'PSReadline',
                'bck-i-search',
                'Console',
                'History'
            )
        }
    }
}

