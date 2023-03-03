function Start-Spinner {
<#
.DESCRIPTION
    This function is meant to be used via the pipeline exclusively.
    Pass the status message parameter through the pipeline only.
.EXAMPLE
    # function that takes sometime to finish, while showing some info along the way
    function Write-Something {
        [cmdletbinding()]
        param ()
        Write-Verbose 'vvv' ; sleep 1 ; Write-Warning 'www' ; sleep 1 ; Write-Host 'nnn' ; Start-Sleep 1
        Write-Verbose 'VVV' ; sleep 1 ; Write-Warning 'WWW' ; sleep 1 ; Write-Host 'NNN' ; Start-Sleep 1
        $out = [PSCustomObject] @{ Name='abcdef' ; Size = 10}
        Write-Output $out
    }
    Write-Something -Verbose *>&1 | Start-Spinner -Color Blue -Type BounceBoxSmall -Speed Fast
#>
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline)]
    $CurrentStatus,
    [string]$ActivityTitle = (Get-RandomQuote),
    
    [ValidateSet('VerboseOnly','WarningOnly','VerboseAndWarning','InfoOnly','Any')]
    [string]$MessageType = 'Any',

    [Spinner.ColorSet]$Color = ([enum]::GetNames([Spinner.ColorSet]) | Get-Random),
    [Spinner.Speed]$Speed    = 'MediumFast',
    [Spinner.IconSet]$Type   = ([enum]::GetNames([Spinner.IconSet]) | Get-Random),

    [switch]$CollectErrors,
    [switch]$HideType
)

Begin {
    . ([scriptblock]::Create('using namespace System.Management.Automation'))
    $params = @{
        Duration      = 0
        Color         = $Color
        Speed         = $Speed
        Type          = $Type
        AsJob         = $true
        Activity      = $ActivityTitle
        ShowDone      = $false
    }
    $Job = Show-Spinner @params
    $All = [System.Collections.Generic.List[Object]]::new()
}

Process {
    $FromPipe = $MyInvocation.ExpectingInput
    if (-not $FromPipe) {
        Write-Warning 'Please use the pipeline to pass input for the status parameter'
        return
    }
    $IsVerb  = $PSItem -is [VerboseRecord]
    $IsWarn  = $PSItem -is [WarningRecord]
    $IsInfo  = $PSItem -is [InformationRecord]
    $IsError = $PSItem -is [ErrorRecord] -or $PSItem -is [System.Exception]
    if (
        ($MessageType -eq 'VerboseOnly' -and $IsVerb) -or
        ($MessageType -eq 'WarningOnly' -and $IsWarn) -or
        ($MessageType -eq 'InfoOnly'    -and $IsInfo) -or
        ($MessageType -eq 'VerboseAndWarning' -and ($IsVerb -or $IsWarn)) -or
        ($MessageType -eq 'Any' -and ($IsVerb -or $IsWarn -or $IsInfo))
    ) {
        $Msg = $PSItem.ToString()
    }
    if ($Msg.Length -gt 60) {$Msg = '{0}…' -f  $Msg.SubString(0,59)}

    if (-not $IsVerb -and -not $IsWarn -and -not $IsInfo) {
        if (-not $CollectErrors -and $IsError) {
            Write-Error -ErrorRecord $PSItem
        }
        else {$CurrentStatus | ForEach {$All.Add($PSItem)}} 
    }
    if     ($IsVerb) {$MsgType = 'VERB'}
    elseif ($IsWarn) {$MsgType = 'WARN'}
    elseif ($IsInfo) {$MsgType = 'INFO'}

    # finally update the status on the spinner
    $Job.ProgressStatus.Message = $Msg
    if ($HideType) {$Job.ProgressStatus.Type = 'NONE'}
    else           {$Job.ProgressStatus.Type = $MsgType}
}

End {
    $Job.ProgressStatus.IsDone = 'True'
    $Job | Wait-Job | Remove-Job

    # and pass any normal output
    if ($All.Count -gt 0) {
        Write-Output $All -NoEnumerate | ForEach {$_}
    }
}
}