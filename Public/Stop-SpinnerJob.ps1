function Stop-SpinnerJob {
<#

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateScript({
        # make sure this is our "custom" job type
        # which has the extra 'ProgressStatus' NoteProperty
        $_.psobject.Properties.Name -contains 'ProgressStatus'
    })]
    [ThreadJob.ThreadJob]$Job
)

# this will break out the endless while loop
$Job.ProgressStatus.IsDone = 'True'
}