function Get-RandomQuote {
<#
.SYNOPSIS
    Get a random quote
#>
[CmdletBinding()]
param (
    [switch]$OnlyVerb
)

$Data = Get-ModuleData Quotes

$Verb = $Data.Verb | Get-Random
$Noun = $Data.Noun | Get-Random

if ($OnlyVerb) {Write-Output "$Verb..."}
else           {Write-Output "$Verb $Noun"}

}