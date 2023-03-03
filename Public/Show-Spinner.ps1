function Show-Spinner {
<#
.SYNOPSIS
    It shows a spinner
.EXAMPLE
    Show-Spinner -Duration 3 -Color Blue -Speed MediumFast -Type BounceBoxSmall
#>
param (
    [string]$Activity = (Get-RandomQuote),

    [System.Collections.Concurrent.ConcurrentDictionary[string,string]]$Status,

    [uint]$Duration = 5, # <-- in seconds
    
    [Spinner.ColorSet]$Color = ([enum]::GetNames([Spinner.ColorSet]) | Get-Random),

    [Spinner.Speed]$Speed    = 'MediumFast',

    [Spinner.IconSet]$Type   = ([enum]::GetNames([Spinner.IconSet]) | Get-Random),

    [switch]$AsJob,

    [switch]$ShowDone
)
$PSDefaultParameterValues.'Write-Host:NoNewLine' = $true

$HasStatus = $PSBoundParameters.ContainsKey('Status')
if (-not $HasStatus) {
    $Status         = [System.Collections.Concurrent.ConcurrentDictionary[string,string]]::new()
    $Status.Message = Get-RandomQuote -OnlyVerb
    $Status.IsDone  = [bool]::FalseString
    $Status.Type    = 'NONE'
    [void]$PSBoundParameters.Add('Status',$Status)
}

if ($AsJob) {
    # Remove the -AsJob parameter, leave everything else as-is
    [void]$PSBoundParameters.Remove('AsJob')

    $params = @{
        CommandName    = $MyInvocation.MyCommand.Name
        ParameterTable = $PSBoundParameters
        InitialStatus  = $Status
    }
    return (Start-FunctionJob @params)
} #if AsJob

$Col  = Get-ColorSet $Color  # <-- $Col.Norm , $Col.Lite , $Col.Dark, $Col.None
$Gray = Get-ColorSet Gray
$Yell = Get-ColorSet Yellow
$Blue = Get-ColorSet Blue
$Cur  = Get-CursorCode       # <-- all VT100 cursor escape sequences
$PosY = (Get-CursorPosition).Y
$PosX = $Activity.Length+1
$Iset = Get-IconSet $Type
if ($Type -like '*Small') {
    $ActivPos   = Set-CursorPosition 1     $PosY   # <-- the cursor position of the start of the Activity string
    $StartLn1   = Set-CursorPosition $PosX $PosY
    $Icons      = $Iset.Line1
}
elseif ($Type -like '*Large') {
    if ($PosY -ge ($Host.UI.RawUI.WindowSize.Height - 0)) {
        Write-Host $Cur.ScrollUp
        $ActivPos = Set-CursorPosition 1      $PosY
        $StartLn1 = Set-CursorPosition $PosX ($PosY-1)
        $StartLn2 = Set-CursorPosition $PosX  $PosY
    }
    else {
        $ActivPos = Set-CursorPosition 1     ($PosY+1)
        $StartLn1 = Set-CursorPosition $PosX  $PosY
        $StartLn2 = Set-CursorPosition $PosX ($PosY+1)
    }
    $IconsLine1 = $Iset.Line1
    $IconsLine2 = $Iset.Line2
}
$Fill   = $Col.Dark + ($Iset.Fill)*$Iset.Line1[0].Length
$Done   = $Col.Lite + $Cur.Italic + 'D O N E' + $Cur.NoItalic + $Col.None
$Activ  = $ActivPos + $Cur.Underline + $Activity + $Cur.NoUnderline
$OpenTB = $Gray.Norm + '[' + $Col.None   # <-- Open Type Bracket
$ClosTB = $Gray.Norm + '] ' + $Col.None  # <-- Close Type Bracket

if ($Duration -eq 0) {[long]$Timeout = [uint]::MaxValue}
else                 {[long]$Timeout = $Duration * 1000}

$i = 0 ; $SB = [System.Text.StringBuilder]::new()
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
#region ---- The Loop
Write-Host ($Cur.Hide + $Activ)
while ($Timer.ElapsedMilliseconds -le $Timeout) {
    if     ($Status.Type -eq 'NONE') {[void]$SB.Clear()}
    elseif ($Status.Type -eq 'VERB') {[void]$SB.Append($OpenTB + $Blue.Lite + $Status.Type + $ClosTB)}
    elseif ($Status.Type -eq 'WARN') {[void]$SB.Append($OpenTB + $Yell.Lite + $Status.Type + $ClosTB)}
    elseif ($Status.Type -eq 'INFO') {[void]$SB.Append($OpenTB + $Gray.Lite + $Status.Type + $ClosTB)}

    if ($Type -like '*Small') {
        Write-Host ($Col.Norm +
            $StartLn1 + ' [' + $Icons[$i % $Icons.Length] + '] ' + $SB.ToString() +
            $Col.Norm + $Cur.Italic + $Status.Message + $Cur.NoItalic + $Cur.DeleteEnd
        )
    }
    elseif ($Type -like '*Large') {
        Write-Host ($Col.Norm +
            $StartLn1 + ' ║' + $IconsLine1[$i % $IconsLine1.Length] + '║ ' +
            $StartLn2 + ' ║' + $IconsLine2[$i % $IconsLine2.Length] + '║ ' + $SB.ToString() + 
            $Col.Norm + $Cur.Italic + $Status.Message + $Cur.NoItalic + $Cur.DeleteEnd
        )
    }
    $i++
    [void]$SB.Clear()
    Start-Sleep -Milliseconds $Speed.value__   # <-- the Interval
    if ($Status.IsDone -eq 'True') {break}
}
#endregion

#region ---- After the loop
if ($Type -like '*Small') {
    Write-Host ($StartLn1 + $Col.Lite + ' [' + $Fill + $Col.Lite + '] ')
}
elseif ($Type -like '*Large') {
    Write-Host (
        $StartLn1 + $Col.Lite + ' ║' + $Fill + $Col.Lite + '║ ' +
        $StartLn2 + $Col.Lite + ' ║' + $Fill + $Col.Lite + '║ '
    )
}
if ($ShowDone) {$Done + $Cur.DeleteEnd}
#endregion

Write-Host ($Cur.Show + $Col.None)
$Timer.Stop()
$PSDefaultParameterValues.Remove('Write-Host:NoNewLine')

}