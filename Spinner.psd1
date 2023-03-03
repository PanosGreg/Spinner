# Module manifest for module 'Spinner'
# Generated by: Panos Grigoriadis
# Generated on: 20/02/2023

@{
RootModule        = 'Spinner.psm1'
ModuleVersion     = '1.5.0'
GUID              = '0b242b1e-b061-49a0-914d-dc9daa4f4617'
Author            = 'Panos Grigoriadis'
CompanyName       = 'No Company'
Copyright         = '(c) 2023 Panos Grigoriadis. All rights reserved.'
Description       = 'Functions for progress bars.'
PowerShellVersion = '7.3'
RequiredModules   = @('ThreadJob')
FunctionsToExport = 'Start-Spinner','Show-Spinner','Stop-SpinnerJob','Update-SpinnerJob',
                    'Wait-Scriptblock'
#CmdletsToExport   = @()                     
AliasesToExport   = ''
PrivateData       = @{
    PSData = @{
        Tags         = 'PowerShell', 'ProgressBar'
        ProjectUri   = 'https://github.com/...'
        ReleaseNotes = 'This module contains helper functions for progress bars.'
        LastUpdate   = '03 Mar 2023'
    }
    DataFolder = '\Data'
}
}

