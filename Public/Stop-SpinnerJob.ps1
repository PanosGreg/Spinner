function Stop-SpinnerJob {
<#

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ThreadJob.ThreadJob]$Job
)

$Job.ProgressStatus.IsDone = 'True'
}