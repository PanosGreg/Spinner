function Update-SpinnerJob {
<#

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ThreadJob.ThreadJob]$Job,
    [string]$Message
)

$Job.ProgressStatus.Message = $Message


}