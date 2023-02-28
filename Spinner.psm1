
#Get public and private functions
    $Public  = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
    $Private = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
    $params     = @{
        Filter      = '*.ps1'
        Recurse     = $true
        File        = $true
        ErrorAction = 'SilentlyContinue'
    }
    $PublicFiles  = @(Get-ChildItem $Public  @params)
    $PrivateFiles = @(Get-ChildItem $Private @params) # | Where PSPath -NotLike '*Something*')
    $CSharpFiles  = Get-ChildItem -Path $Private -Filter '*.cs' -File


# Load the Classes & Enumerations       # <-- this needs to be before the functions
    Foreach ($file in $CSharpFiles) {
        Try {
            Add-Type -Path $file.FullName -ErrorAction Stop
        }
        Catch {
            Write-Error -Message "Failed to import types from $($file.FullName):`n$_"
        }

    }


# Load the functions
    Foreach($import in @($PublicFiles+$PrivateFiles)) {
        Try {
            . $import.FullName
        }
        Catch {
            Write-Error -Message "Failed to import function $($import.fullname):`n$_"
        }
    }


#Load any dependent module(s)
    #$ModuleFile = Join-Path $PSScriptRoot -ChildPath 'Dependency\PowerShellLogging\PowerShellLogging.psd1'
    #Import-Module $ModuleFile -Verbose:$false


# Run any required functions for this module
    #New-GlobalVariables