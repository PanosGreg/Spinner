function Get-ColorSet {
<#
.SYNOPSIS
    Get a VT100 escape sequence of a specific color
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [Spinner.ColorSet]$ColorSet
)

$esc = [char]27

if ($ColorSet -eq 'Default') {
    $NormCol = $esc + '[m'
    $LiteCol = $esc + '[m'
    $DarkCol = $esc + '[m'
}
else {
    $Set  = $ColorSet.ToString()
    $Data = Get-ModuleData Colors
    $Norm = $Data.$Set
    $Lite = $Data."Lite$Set"
    $Dark = $Data."Dark$Set"
    
    $NormCol = '{0}[38;2;{1};{2};{3}m' -f $esc,$Norm.R,$Norm.G,$Norm.B
    $LiteCol = '{0}[38;2;{1};{2};{3}m' -f $esc,$Lite.R,$Lite.G,$Lite.B
    $DarkCol = '{0}[38;2;{1};{2};{3}m' -f $esc,$Dark.R,$Dark.G,$Dark.B
}

$out = @{
    Norm  = $NormCol
    Lite  = $LiteCol
    Dark  = $DarkCol
    None  = $esc + '[m'
}

Write-Output $out

}