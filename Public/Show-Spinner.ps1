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
    
    [Spinner.ColorSet]$Color = 'Default',

    [Spinner.Speed]$Speed = 'Medium',

    [Spinner.IconSet]$Type = 'BoxSmall',

    [switch]$AsJob
)
$PSDefaultParameterValues.'Write-Host:NoNewLine' = $true

## Large icon sets work properly in Windows Terminal only
if ($Type -like '*Large' -and -not [bool]$env:WT_SESSION) {
    Write-Warning 'Unfortunately the large icon sets only work properly in Windows Terminal'
    return
}

$HasStatus = $PSBoundParameters.ContainsKey('Status')
if (-not $HasStatus) {
    $Status         = [System.Collections.Concurrent.ConcurrentDictionary[string,string]]::new()
    $Status.Message = Get-RandomQuote -OnlyVerb
    $Status.IsDone  = [bool]::FalseString
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

$Col   = Get-ColorSet $Color  # <-- $Col.Norm , $Col.Lite , $Col.Dark, $Col.None
$Cur   = Get-CursorCode       # <-- all VT100 cursor escape sequences
$PosY  = $Host.UI.RawUI.CursorPosition.Y         # <-- that's the next line after the execution of this function
$PosX  = $Activity.Length+1
$Iset  = Get-IconSet $Type
if ($Type -like '*Small') {
    $ActivPos   = Set-CursorPosition 1     ($PosY+1)   # <-- the cursor position of the start of the Activity string
    $StartLn1   = Set-CursorPosition $PosX ($PosY+1)
    $Icons      = $Iset.Line1
}
elseif ($Type -like '*Large') {
    if ($PosY -ge ($Host.UI.RawUI.WindowSize.Height - 1)) {
        Write-Host $Cur.ScrollUp
        $ActivPos = Set-CursorPosition 1     ($PosY+1)
        $StartLn1 = Set-CursorPosition $PosX ($PosY+0)
        $StartLn2 = Set-CursorPosition $PosX ($PosY+1)
    }
    else {
        $ActivPos = Set-CursorPosition 1     ($PosY+2)
        $StartLn1 = Set-CursorPosition $PosX ($PosY+1)
        $StartLn2 = Set-CursorPosition $PosX ($PosY+2)
    }
    $IconsLine1 = $Iset.Line1
    $IconsLine2 = $Iset.Line2
}
$Fill  = $Col.Dark + ($Iset.Fill)*$Iset.Line1[0].Length
$Done  = $Col.Lite + $Cur.Italic + 'D O N E' + $Cur.NoItalic + $Col.None
$Activ = $ActivPos + $Cur.Underline + $Activity + $Cur.NoUnderline

if ($Duration -eq 0) {[long]$Timeout = [uint]::MaxValue}
else                 {[long]$Timeout = $Duration * 1000}

$i = 0
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
#region ---- The Loop
Write-Host ($Cur.Hide + $Activ)
while ($Timer.ElapsedMilliseconds -le $Timeout) {
    if ($Type -like '*Small') {
        Write-Host ($Col.Norm + 
            $StartLn1 + ' [' + $Icons[$i % $Icons.Length] + '] ' +
            $Cur.Italic + $Status.Message + $Cur.NoItalic + $Cur.DeleteEnd
        )
    }
    elseif ($Type -like '*Large') {
        Write-Host ($Col.Norm +
            $StartLn1 + ' ║' + $IconsLine1[$i % $IconsLine1.Length] + '║ ' +
            $StartLn2 + ' ║' + $IconsLine2[$i % $IconsLine2.Length] + '║ ' +
            $Cur.Italic + $Status.Message + $Cur.NoItalic + $Cur.DeleteEnd
        )
    }
    $i++
    Start-Sleep -Milliseconds $Speed.value__   # <-- the Interval
    if ($Status.IsDone -eq 'True') {break}
}
#endregion

#region ---- After the loop
if ($Type -like '*Small') {
    Write-Host ($StartLn1 + $Col.Lite + ' [' + $Fill + $Col.Lite + '] ' + $Done + $Cur.DeleteEnd)
}
elseif ($Type -like '*Large') {
    Write-Host (
        $StartLn1 + $Col.Lite + ' ║' + $Fill + $Col.Lite + '║ ' +
        $StartLn2 + $Col.Lite + ' ║' + $Fill + $Col.Lite + '║ ' + $Done + $Cur.DeleteEnd
    )
}
#endregion

Write-Host ($Cur.Show + $Col.None)
$Timer.Stop()
$PSDefaultParameterValues.Remove('Write-Host:NoNewLine')

}