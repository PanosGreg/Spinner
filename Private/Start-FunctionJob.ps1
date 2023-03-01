function Start-FunctionJob {
[CmdletBinding()]
param (
    [string]$CommandName,
    [System.Collections.Hashtable]$ParameterTable,
    [System.Collections.Concurrent.ConcurrentDictionary[string,string]]$InitialStatus
)

# Start new job that executes a copy of this function against the remaining parameter arguments
$block = {
    param(
        [string]$FunctionName,
        [System.Collections.IDictionary]$ArgTable,
        [string]$ModulePath
    )

    Import-Module $ModulePath

    & $FunctionName @ArgTable
}

$Path   = $MyInvocation.MyCommand.Module.ModuleBase
$params = @{
    ScriptBlock   = $block
    ArgumentList  = $CommandName,$ParameterTable,$Path
    StreamingHost = $Host
}
$job = Start-ThreadJob @params
$job | Add-Member -NotePropertyName ProgressStatus -NotePropertyValue $InitialStatus

Write-Output $job
}