
# how to use the spinner

Remove-Module Spinner -EA 0
Import-Module .\Spinner.psd1

# just a helper function to demonstrate the functionality of the spinner
function Write-Something {
    [CmdletBinding()]
    param ()
    function Wait {Start-Sleep -Milliseconds 500}
    Write-Verbose 'vvv' ; wait ; Write-Warning 'www' ; wait ; Write-Information 'iii' ; wait
    Write-Verbose 'VVV' ; wait ; Write-Warning 'WWW' ; wait ; Write-Information 'III' ; wait
    $out = 1..3 | foreach {
        [PSCustomObject] @{
            Name = 'aa','bb','cc','dd','ee' | Get-Random
            Size = 10,20,30,40,50 | Get-Random
        }
    }
    Write-Output $out
}

# showcase the indefinite progress bar (as-in the spinner)
# with a function that takes a while and gives some verbose/warning/info messages
$obj = Write-Something -Verbose *>&1 | Start-Spinner -ActivityTitle 'Doing Stuff'

# and we can even keep the actual function output
$obj

# this one is just to showcase the spinner itself
Show-Spinner -Duration 3

# Another example is when using the Wait-Scriptblock function
    # the following assumes that you don't have cmd currently running
    $block = {(Get-Process | where Name -eq cmd) -as [bool]}
    Wait-ScriptBlock -ScriptBlock $block -Verbose 4>&1 | Start-Spinner -ActivityTitle 'Run CMD' | Out-Null

    # so now you can just wait a 10-20 seconds, to see the status messages that refresh in the spinner

    # and then finally just run cmd to end the wait and thus the spinner as well.  
