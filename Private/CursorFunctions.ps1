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
    [ValidateScript({$_ -ge 1 -and $_ -le [System.Console]::WindowWidth})]
    [int]$PosX,

    [Alias('CursorPositionY','Vertical')]
    [ValidateScript({$_ -ge 1 -and $_ -le [System.Console]::WindowHeight})]
    [int]$PosY
)
$out = [char]27 + "[${PosY};${PosX}H"
Write-Output $out
}

function Get-CursorPosition {
<#
.SYNOPSIS
    This gets the cursor position. The advantage of doing so by using
    the ESC[6n sequence is that it gives back the window coordinates
    and not the buffer coordinates. Although [console]::GetCursorPosition()
    (or even $Host.UI.RawUI.CursorPosition) works fine in Windows Terminal,
    unfortunately it does not in the regular console (ex. cmd.exe).
    Hence why we need this function.
#>
    $isOnColumn = $false
    $line       = [System.Collections.Generic.List[char]]::new()
    $column     = [System.Collections.Generic.List[char]]::new()

    [System.Console]::Write("$([char]27)[6n")
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.KeyChar -in [char]27, [char]'[') {
            continue
        }

        if ($isOnColumn) {
            if ($key.KeyChar -eq 'R') {
                break
            }

            $column.Add($key.KeyChar)
            continue
        }

        if ($key.KeyChar -eq ';') {
            $isOnColumn = $true
            continue
        }

        $line.Add($key.KeyChar)
    }

    $line   = [int]::Parse([string]::new($line.ToArray()))
    $column = [int]::Parse([string]::new($column.ToArray()))
    $out    = [System.Management.Automation.Host.Coordinates]::new($column,$line)
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
    [ValidateScript({$_ -ge 1 -and $_ -le [System.Console]::WindowHeight})]
    [int]$Top,

    [ValidateScript({$_ -ge 1 -and $_ -le [System.Console]::WindowHeight})]
    [int]$Bottom
)
if ($Bottom -gt $Top) {throw "Top ($Top) must be greater or equal to Bottom ($Bottom)"}
$out = [char]27 + "[${Top};${Bottom}r"
Write-Output $out
}
