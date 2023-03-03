function Update-SpinnerJob {
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
    [ThreadJob.ThreadJob]$Job,

    [string]$Message = (Get-RandomQuote -OnlyVerb)
)

# this will update the Message property in the concurrent dictionary
# that the while loop reads on each iteration
$Job.ProgressStatus.Message = $Message

}