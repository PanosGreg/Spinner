function Get-CursorCode {
<#
.SYNOPSIS
    Get a VT100 escape sequence for cursor formatting
#>
param (
    [Alias('CursorAction')]
    [Spinner.CursorAction]$Action
)
$Data = Get-ModuleData Cursors

if ($Action) {$out = $Data.($Action.ToString())}
else         {$out = $Data}
Write-Output $out
}

function Set-CursorPosition {
<#
.SYNOPSIS
    Get a VT100 escape sequence for cursor positioning
#>
[CmdletBinding()]
[Alias('Place-Cursor')]
param (
    [Alias('CursorPositionX','Horizontal')]
    [ValidateScript({$_ -ge 1 -and $_ -le [System.Console]::BufferWidth})]
    [int]$PosX,

    [Alias('CursorPositionY','Vertical')]
    [ValidateScript({$_ -ge 1 -and $_ -le [System.Console]::BufferHeight})]
    [int]$PosY
)
$out = [char]27 + "[${PosY};${PosX}H"
Write-Output $out
}

function Set-CursorArea {
<#
.SYNOPSIS
    Set the scroll margin area
#>
[CmdletBinding()]
[Alias('Set-ScrollMargin','Define-Margin')]
param (
    [ValidateScript({$_ -ge 1 -and $_ -le [System.Console]::BufferHeight})]
    [int]$Top,

    [ValidateScript({$_ -ge 1 -and $_ -le [System.Console]::BufferHeight})]
    [int]$Bottom
)
if ($Bottom -gt $Top) {throw "Top ($Top) must be greater or equal to Bottom ($Bottom)"}
$out = [char]27 + "[${Top};${Bottom}r"
Write-Output $out
}
