function Wait-ScriptBlock {
<#
.SYNOPSIS
    It waits for a scriptblock to return TRUE
.DESCRIPTION
    The scriptblock must return a boolean.
    The idea here is that first you are going to run something that takes a while.
    And then you need to wait for that until it finishes.
    So this function waits until the scriptblock returns TRUE or until the timeout expires.
.EXAMPLE
    Stop-Service MSSQLSERVER -NoWait
    $block = {(Get-Service MSSQLSERVER).Status -eq 'Stopped'}
    Wait-Scriptblock $block -TimeoutSec 180  # <-- 3 mins
.EXAMPLE
    # make sure you don't have notepad running
    $block = {(Get-Process | where name -eq notepad) -as [bool]}
    Wait-Scriptblock $block -TimeoutSec 120 -Verbose
    # just wait 30-40 seconds and then run notepad
    # at that stage the wait function will exit
.EXAMPLE
    $job = Start-Job {choco install nodejs-lts -y}
    $block = {$job.State -eq 'Completed'}
    Wait-Scriptblock $block -TimeoutSec 180 -CheckEverySec 5 -Context NodeJS -Verbose
#>
[CmdletBinding()]
[OutputType([bool])]
param (
    [Parameter(Mandatory)]
    [Alias('Block')]
    [scriptblock]$ScriptBlock,       # <-- must return a bool
    [int]$TimeoutSec         = 300,  # <-- wait up to 5 minutes by default
    [int]$CheckEverySec      = 1,    # <-- check every 1 second
    [UInt16]$VerboseAfterSec = 0,    # <-- dont show any verbose before X sec
    [ValidateLength(1,40)]
    [string]$Context                 # <-- optional context for verbose messages
)

function Get-DurationText {
param (
    [System.TimeSpan]$Elapsed,
    [ValidateSet('min:sec','minsec')]
    [string]$TimeFormat = 'minsec'
)
if     ($Elapsed.TotalHours   -ge 1) {$fmt1 = 'hh\:mm\:ss' ; $fmt2 = 'h\hm\ms\s'}
elseif ($Elapsed.TotalMinutes -ge 1) {$fmt1 = 'mm\:ss'     ; $fmt2 = 'm\ms\s'}
else                                 {$fmt1 = 'mm\:ss'     ; $fmt2 = 's\s'}

switch ($TimeFormat) {
    'min:sec'  {$out = $Elapsed.ToString($fmt1) ; break}  # ex. 02:12
    'minsec'   {$out = $Elapsed.ToString($fmt2) ; break}  # ex. 2m12s
    default    {$out = $Elapsed.ToString()}               # ex. 00:02:12.0708419
}
Write-Output $out  # <-- [string]
}

$HasCtx  = $PSBoundParameters.ContainsKey('Context')
$Ctx     = if ($HasCtx) {"[$Context] "} else {$null}
$Index   = 0
$Every   = (5,15,30,60,120,300,600,900,1200,1800,2700,3600,5400,7200,10800,18000,36000)  # <-- exponential back-off
$Timer   = [Diagnostics.StopWatch]::StartNew()
$Expired = $false
$IsDone  = $false

while (-not $IsDone -and -not $Expired) {

    $IsDone = $ScriptBlock.Invoke()
    $IsBool = $IsDone.ForEach({$_.GetType()}).FullName -eq 'System.Boolean'
    if (-not $IsBool) {throw 'The scriptblock did not return a boolean'}

    if (-not $IsDone) {
        Start-Sleep -Seconds $CheckEverySec

        $Elapsed  = $Timer.Elapsed.TotalSeconds
        $Duration = Get-DurationText $Timer.Elapsed
        if ($Elapsed -ge $Every[$Index]) {
            if ($Index -lt $Every.Count-1) {$Index++}
            if ($Elapsed -ge $VerboseAfterSec) {
                Write-Verbose "${Ctx}Waiting... [$Duration elapsed]"
            }
        }
    }
    if ($Elapsed -ge $TimeoutSec) {
        Write-Warning "${Ctx}The timeout ($TimeoutSec sec) has expired"
        $Expired = $true
    }
} #while
$Timer.Stop()
$Duration = Get-DurationText $Timer.Elapsed
if ($IsDone) {
    if ($Elapsed -ge $VerboseAfterSec) {
        Write-Verbose "${Ctx}Completed successfully [$Duration elapsed]"
    }
}
else {Write-Warning "${Ctx}Did not complete successfully"}

Write-Output $IsDone    # <-- [bool]

}