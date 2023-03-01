function Show-SpinnerLoop {
<#
.SYNOPSIS
    This is just a quick proof-of-concept for a spinner loop in the console
.EXAMPLE
    Show-Spinner -Duration 3 -Color Blue -Speed Fast -Type BoxOneLine
.EXAMPLE
    Show-Spinner -Duration 3 -Color Orange -Speed VeryFast -Type TriangleTwoLines
#>
param (
    [uint]$Duration = 5, # <-- in seconds
    
    [ValidateSet('Default','Blue','Green','Orange','Yellow','Red')]
    [string]$Color = 'Default',

    [ValidateSet('VerySlow','Slow','MediumSlow','Medium','MediumFast','Fast','VeryFast')]
    [string]$Speed = 'Medium',

    [ValidateSet('BoxOneLine','BoxTwoLines','TriangleOneLine','TriangleTwoLines')]
    [string]$Type = 'BoxOneLine'
)

switch ($Speed) {
    'VerySlow'   {$Interval = 320}
    'Slow'       {$Interval = 240}
    'MediumSlow' {$Interval = 200}
    'Medium'     {$Interval = 160}
    'MediumFast' {$Interval = 120}
    'Fast'       {$Interval = 80}
    'VeryFast'   {$Interval = 40}
}

switch ($Color) {
    'Default' {$Col = "`e[0m"}
    'Blue'    {$Col = "`e[38;2;{0};{1};{2}m" -f  61, 148, 243}
    'Green'   {$Col = "`e[38;2;{0};{1};{2}m" -f 146, 208,  80}
    'Orange'  {$Col = "`e[38;2;{0};{1};{2}m" -f 255, 126,   0}
    'Yellow'  {$Col = "`e[38;2;{0};{1};{2}m" -f 240, 230, 140}
    'Red'     {$Col = "`e[38;2;{0};{1};{2}m" -f 231,  72,  86}
}
$HideCursor = "`e[?25l"
$ShowCursor = "`e[?25h"
$NoColor    = "`e[m"

$PosY = $Host.UI.RawUI.CursorPosition.Y
if     ($Type -like  '*OneLine') {
    $Start      = "`e[$($PosY+1);5H"
    $ScrollDown = "`e[1S"
}
elseif ($Type -like '*TwoLines') {
    $StartLn1   = "`e[$($PosY+0);5H"
    $StartLn2   = "`e[$($PosY+1);5H"
    $ScrollDown = "`e[2S"
}

if ($Type -eq 'BoxOneLine') {
    $Icons = '▘  ','▀  ','▝▘ ',' ▀ ',' ▝▘','  ▀','  ▝','  ▐','  ▗','  ▄',' ▗▖',' ▄ ','▗▖ ','▖  ','▌  '
}
elseif ($Type -eq 'BoxTwoLines') { 
    $IconsLine1 = '▘   ','▀   ','▝▘  ',' ▀  ',' ▝▘ ','  ▀ ','  ▝▘','   ▀','   ▝','   ▐','   ▗','    ','    ','    ','    ','    ','    ','    ','    ','    ','    ','▖   ','▌   '
    $IconsLine2 = '    ','    ','    ','    ','    ','    ','    ','    ','    ','    ','   ▝','   ▐','   ▗','   ▄','  ▗▖','  ▄ ',' ▗▖ ',' ▄  ','▗▖  ','▖   ','▌   ','▘   ','    '
}
elseif ($Type -eq 'TriangleOneLine') {
    $Icons = '▷▷▷▷▷▷▷▷','▶▷▷▷▷▷▷▷','▶▶▷▷▷▷▷▷','▶▶▶▷▷▷▷▷','▶▶▶▶▷▷▷▷','▶▶▶▶▷▷▷▷','▷▶▶▶▶▷▷▷','▷▷▶▶▶▶▷▷','▷▷▷▶▶▶▶▷','▷▷▷▷▶▶▶▶','▷▷▷▷▷▶▶▶','▷▷▷▷▷▷▶▶','▷▷▷▷▷▷▷▶'
}
elseif ($Type -eq 'TriangleTwoLines') {
    $IconsLine1 = '▷▷▷▷▷▷▷▷▽','▶▷▷▷▷▷▷▷▽','▶▶▷▷▷▷▷▷▽','▶▶▶▷▷▷▷▷▽','▶▶▶▶▷▷▷▷▽','▷▶▶▶▶▷▷▷▽','▷▷▶▶▶▶▷▷▽','▷▷▷▶▶▶▶▷▽','▷▷▷▷▶▶▶▶▽','▷▷▷▷▷▶▶▶▼','▷▷▷▷▷▷▶▶▼','▷▷▷▷▷▷▷▶▼','▷▷▷▷▷▷▷▷▼','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽','▷▷▷▷▷▷▷▷▽'
    $IconsLine2 = '◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▼','◁◁◁◁◁◁◁◀▼','◁◁◁◁◁◁◀◀▼','◁◁◁◁◁◀◀◀▼','◁◁◁◁◀◀◀◀▽','◁◁◁◀◀◀◀◁▽','◁◁◀◀◀◀◁◁▽','◁◀◀◀◀◁◁◁▽','◀◀◀◀◁◁◁◁▽','◀◀◀◁◁◁◁◁▽','◀◀◁◁◁◁◁◁▽','◀◁◁◁◁◁◁◁▽','◁◁◁◁◁◁◁◁▽'
}

if ($Duration -eq 0) {[long]$Timeout = [uint]::MaxValue}
else                 {[long]$Timeout = $Duration * 1000}
$i  = 0
$SB = [System.Text.StringBuilder]::new()  # <-- use a stringbuilder to keep memory usage low
                                          #     otherwise you'll fill up the memory with strings, cause they are immutable
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host $HideCursor -NoNewline
Write-Host $ScrollDown -NoNewline
while ($Timer.ElapsedMilliseconds -le $Timeout) {
    if ($Type -like '*OneLine') {
        [void]$SB.Append(($Col + 
            $Start + '[ ' + $Icons[$i % $Icons.Length] + ' ]'
        ))
    } #if OneLine
    elseif ($Type -like '*TwoLines') {
        [void]$SB.Append(($Col +
            $StartLn1 + '║' + $IconsLine1[$i % $IconsLine1.Length] + '║' +
            $StartLn2 + '║' + $IconsLine2[$i % $IconsLine2.Length] + '║'
        ))
    } #if TwoLines
    Write-Host $SB.ToString() -NoNewline
    [void]$SB.Clear()
    $i++
    Start-Sleep -Milliseconds $Interval
}
Write-Host ($ShowCursor + $NoColor) -NoNewline
$Timer.Stop()
}
