function Get-ModuleData {
param (
    [Parameter(Mandatory)]
    [ValidateSet('Colors','Cursors','Spinners','Quotes')]
    [string]$Type
)

$DataFolder = $MyInvocation.MyCommand.Module.PrivateData.DataFolder
$RootFolder = $MyInvocation.MyCommand.Module.ModuleBase
$FolderPath = Join-Path $RootFolder $DataFolder

Import-LocalizedData -BaseDirectory $FolderPath -FileName "$Type.psd1"
}