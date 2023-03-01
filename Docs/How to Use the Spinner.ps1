
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
# apart from the actual output (which is an array of objects)
$obj = Write-Something -Verbose *>&1 | Start-Spinner -ActivityTitle 'Doing Stuff'

# and we even kept the actual output from the function
$obj

# this one is just to showcase the spinner itself
Show-Spinner -Duration 3
