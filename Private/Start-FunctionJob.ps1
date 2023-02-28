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
        #[string]$FunctionCode,       # <-- this is used if it's a function not module
        [System.Collections.IDictionary]$ArgTable,
        [string]$ModulePath
    )

    Import-Module $ModulePath

    & $FunctionName @ArgTable

    #$cmd = [scriptblock]::Create($FunctionCode)  # <-- this is used if it's a function not module
    #& $cmd @ArgTable                             # <-- same as above
}

#$CmdDef = (Get-Command -Name $CommandName).Definition
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