function Write-MessageType {
<#

#>
[cmdletbinding()]
param (
    [ValidateSet('VERB','WARN','INFO','NONE')]
    [Parameter(Mandatory)]
    [string]$MessageType
)

$Gray = Get-ColorSet Gray
$Yell = Get-ColorSet Yellow
$Blue = Get-ColorSet Blue
$Open = $Gray.Norm + '['  + $Col.None   # <--  Open Bracket
$Clos = $Gray.Norm + '] ' + $Col.None   # <-- Close Bracket

if     ($Status.Type -eq 'NONE') {$out = [string]::Empty}
elseif ($Status.Type -eq 'VERB') {$out = $Open + $Blue.Lite + $MessageType + $Clos}
elseif ($Status.Type -eq 'WARN') {$out = $Open + $Yell.Lite + $MessageType + $Clos}
elseif ($Status.Type -eq 'INFO') {$out = $Open + $Gray.Lite + $MessageType + $Clos}

Write-Output $out

}