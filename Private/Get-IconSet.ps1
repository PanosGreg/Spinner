function Get-IconSet {
<#
.SYNOPSIS
    Get an array with a list of all the icons of a specific set
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [Spinner.IconSet]$IconSet = 'BounceBoxSmall'
)

$Data = Get-ModuleData Spinners

Write-Output $Data.($IconSet.ToString())

}