# PowerShell Infinite Progress Bar with Spinners

## Description

This module has the `Start-Spinner` function, which can be used to show an indefinite progress bar.
This is usually handy when you don't know when a task will finish and thus you don't have any indication of its progress.


## How to use it

The idea here is that a function will have either an object as its normal output, and perhaps some verbose output, which tells to the end-user what is happening.
So on that basis, all you need to do is redirect that verbose and/or the warning output to the `Start-Spinner` function. 

And then the spinner with show up showing those verbose messages. The end effect is that the verbose output won't take multiple lines, but instead will be refreshed on that indefinite progress bar. Once your task completes, the spinner will stop.

Also as a best practice, it's good to say what is the main activity, so that it will be shown along with the spinner.

## Example #1

```PowerShell
function Write-Something {
    [cmdletbinding()]
    param ()
    Write-Verbose 'vvv' ; sleep 1 ; Write-Output 'aaa' ; sleep 1
    Write-Verbose 'VVV' ; sleep 1 ; Write-Output 'bbb' ; sleep 1
}

Write-Something -Verbose *>&1 | Start-Spinner -Activity 'Doing Stuff'

```

Other examples could be the installation of an application.
Since installs take a bit of time, this spinner will be handy to show that the process is not stuck.
Just make sure your install runs on the background so that it won't block the pipeline.

