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
        Write-Verbose 'vvv' ; sleep 1 ; Write-Warning 'www' ; sleep 1
        Write-Verbose 'VVV' ; sleep 1 ; Write-Warning 'WWW' ; sleep 1
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
    
    [ValidateSet('VerboseOnly','WarningOnly','VerboseAndWarning')]
    [string]$MessageType = 'VerboseAndWarning',

    [Spinner.ColorSet]$Color = 'Default',
    [Spinner.Speed]$Speed    = 'Medium',
    [Spinner.IconSet]$Type   = 'BoxSmall'
)

Begin {
    # Large icon sets work properly in Windows Terminal only
    if ($Type -like '*Large' -and -not [bool]$env:WT_SESSION) {
        Write-Warning 'Unfortunately the large icon sets only work properly in Windows Terminal'
        $Stop = $true
        $All  = [System.Collections.Generic.List[Object]]::new()
        return  # <-- this will skip the Begin block and will take you to the Process block
    }
    else {$Stop = $false}

    . ([scriptblock]::Create('using namespace System.Management.Automation'))
    $params = @{
        Duration  = 0
        Color     = $Color
        Speed     = $Speed
        Type      = $Type
        AsJob     = $true
        Activity  = $ActivityTitle
    }
    $Job = Show-Spinner @params
    $All = [System.Collections.Generic.List[Object]]::new()
}

Process {
    if ($Stop) {
        $CurrentStatus | ForEach {$All.Add($PSItem)}
        return # <-- this will skip the Process block and take you to the End block
    }
    $FromPipe = $MyInvocation.ExpectingInput
    if (-not $FromPipe) {
        Write-Warning 'Please use the pipeline to pass input for the status parameter'
        return
    }
    $IsVerb = $PSItem -is [VerboseRecord]
    $IsWarn = $PSItem -is [WarningRecord]
    if (
        ($MessageType -eq 'VerboseOnly' -and $IsVerb) -or
        ($MessageType -eq 'WarningOnly' -and $IsWarn) -or
        ($MessageType -eq 'VerboseAndWarning' -and ($IsVerb -or $IsWarn))
    ) {
        $Msg = $PSItem.Message
    }
    if ($Msg.Length -gt 60) {$Msg = '{0}…' -f  $Msg.SubString(0,59)}

    if (-not $IsVerb -and -not $IsWarn) {
        $CurrentStatus | ForEach {$All.Add($PSItem)}
    }
    
    # finally update the status on the spinner
    $Job.ProgressStatus.Message = $Msg
}

End {
    if ($Stop) {
        Write-Output $All -NoEnumerate | ForEach {$_}
        return
    }
    $Job.ProgressStatus.IsDone = 'True'
    $Job | Wait-Job | Remove-Job

    # and pass any normal output
    if ($All.Count -gt 0) {
        $NewOut = Write-Output $All -NoEnumerate | ForEach {$_}
        Write-Output $NewOut
    }
}
}