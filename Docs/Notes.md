# General notes and findings

These are some various things that I found along the way when I was writing this module.
Small gotchas and solutions to problems related to what this module is trying to do.

<br><br>

---
### **How to break out from the Begin block**
There are 2 ways to do this.  
The 1st one is to `throw` an error, and that will exit the whole script, but will do so with a terminating error.  
But there is another way, if you want to exit the begin block but still go to the end block then you need to use **3 times the return statement**, one for each block (Begin,Process and End) based on a boolean that you are going to set.
```PowerShell
Begin {
    if ($MyCondition) {
        $Stop = $true
        return   # <-- this will skip the begin block and take you to the process block
    }
    else {$Stop = $false}
}

Process {
    if ($Stop) {return}  # <-- this will skip the process block and take you the end block
}

End {
    if ($Stop) {return}  # <-- this will exit the current function, you can ommit this one if you want
}
```
<br><br>

---
### **How to add the `-AsJob` parameter into a function**
You can add the `-AsJob` switch like so:
```PowerShell
if ($AsJob) {
    # Remove the -AsJob parameter, leave everything else as-is
    [void]$PSBoundParameters.Remove('AsJob')

    # Start new job that executes a copy of this function against the remaining parameter arguments
    $block = {
        param(
            [string]$ThisFunction,
            [System.Collections.IDictionary]$ArgTable
        )

        $cmd = [scriptblock]::Create($ThisFunction)

        & $cmd @ArgTable
    }

    $CmdDef = $MyInvocation.MyCommand.Definition
    $params = @{
        ScriptBlock   = $block
        ArgumentList  = $CmdDef,$PSBoundParameters
        StreamingHost = $Host
    }
    return Start-ThreadJob @params
}
```

But if doing so on a module and thus on a function that is part of it, then the above snippet is a bit different.
In the following way the function can use any private functions from that module, or any classes,enums, etc.

```PowerShell
if ($AsJob) {
    # Remove the -AsJob parameter, leave everything else as-is
    [void]$PSBoundParameters.Remove('AsJob')

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
    return Start-ThreadJob @params
}
```
<br><br>

---
### **How to have the using statement anywhere and also make it dynamic with variables
Normally the using statement must be placed at the very top of your code.  
But you can overcome this limitation with the following syntax.
```PowerShell
. ([scriptblock]::Create('using namespace System.Management.Automation'))
# this example uses the System.Management.Automation namespace as an example
```
Essentially you are dot sourcing a scriptblock and you can do so anywhere in your code.  
Moreover we can even put a variable into that scriptblock to make the using statemet dynamic.
```PowerShell
$NameSpace = 'System.Management.Automation'
. ([scriptblock]::Create("using namespace $NameSpace"))
```
<br><br>

---
### **How to validate the concurrent dictionary has the expected properties**
This is needed in order to pass the appropriate object to the `Start-Spinner` function.
The concurrent dictionaty is used to pass data into the job which runs on a different thread.

```PowerShell
    [ValidateScript({
        $HasMessage  = $_.ContainsKey('Message')
        $IsEmpty     = [string]::IsNullOrWhiteSpace($_.Message)
        $HasDone     = $_.ContainsKey('IsDone')
        $IsBool      = $_.IsDone -match 'True|False'
        if (-not $HasMessage -or $IsEmpty) {
            Write-Warning 'Please provide a Status object that has a property called "Message" with a non-null value'
            return $false
        }
        elseif (-not $HasDone -or -not $IsBool) {
            Write-Warning 'Please provide a Status object that has a property called "IsDone" with value "True" or "False"'
            return $false
        }
        else {return $true}
    })]
    [System.Collections.Concurrent.ConcurrentDictionary[string,string]]$Status
```
<br><br>

---
### **How to set a default value to the Status object**
If you do have parameter validation on the concurrent dictionary, then you also need the following.  
if you want to give a default value to that concurrent dict, while you also have parameter validation, then you need this:
```PowerShell
$HasStatus = $PSBoundParameters.ContainsKey('Status')
if (-not $HasStatus) {
    $NewDict         = [System.Collections.Concurrent.ConcurrentDictionary[string,string]]::new()
    $NewDict.Message = 'Loading...'
    $NewDict.IsDone  = [bool]::FalseString
    $Status          = $NewDict
    # NOTE: I have to 1st create a var and set its properties and then assign it to $Status,
    #       else it wont work due to the param validation on $Status.
}
```
Alternatively another way is to create the variable with `New-Variable` and use the`-Force` parameter, like so:
```PowerShell
$params = @{
    Name  = 'Status'
    Value = [System.Collections.Concurrent.ConcurrentDictionary[string,string]]::new()
    Force = $true
}
New-Variable @params
$Status.Message = 'Loading...'
$Status.IsDone  = [bool]::FalseString
```
<br><br>

---
### **The \`e was added to PS 6+, it's not working on PS 5, hence in PS 5 you need `[char]27`**
For all those VT100 escape character sequences, in PS 6+ you could do them like so:
```PowerShell
$reset = "`e[m"  # <-- this resets any formatting on the text, like colors, underline, italics
```
But in PS 5.1, this (\`e) does not exist, hence we need to:
```PowerShell
$esc   = [char]27 
$reset = $esc + '[m'
```
<br><br>

---
### **The ANSI escape sequence can get a number of parameters**
`ESC [ <n> m`  = the \<n\> position can accept between 0 and 16 parameters separated by semicolons.  
for ex. to set the foreground color to RGB, we use 5 parameters, like so
`ESC [ 38 ; 2 ; <r> ; <g> ; <b>`  
When no parameters are specified, it is treated the same as a single 0 parameter. Which means   `ESC [ m`   is the same as   `ESC [ 0 m`

<br><br>

---
### **To show some symbols using the `Out-GridView`**
```PowerShell
9000..10000 | foreach {[pscustomobject]@{ID=$_;Char=[char]$_}} | ogv
```
Note: you can press `Ctrl+Plus` in OutGridView window to increase the size
<br><br>

---
### **Some links**
- [VT100 Escape Sequences](https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences)
- [Unicode Table](https://unicode-table.com/en/)
- [Text Color Fader](https://patorjk.com/text-color-fader/)
- [Text to ASCII-Art Generator](https://patorjk.com/software/taag/)

<br><br>

---
### **When you run the spinner in a background job but you also need the user to have interactivity with the console**
Every time we move the cursor with a `Write-Host`, we need to first Save the current cursor position and then after the movement, restore back the position.  
The reason why is that you don't know what is happening to the console while this background job runs.  
As-in, may be there are things getting written to the console, and thus I need to put the cursor back to where it is,otherwise those things will be misplaced.  
Also all these applications of save/restore positions are better done on the same line, to avoid any possible issues with the console showing something fast (for ex. fast multiple verbose outputs).  
So it's better to do: (Save-Position + Move-Cursor + Write-Something + Restore-Position) all in a single `Write-Host`, as opposed to do that with many `Write-Host` commands.  
In that regard something like this helper function can be handy:
```PowerShell
function wr([string]$Msg) {
   # encapsulate a message with save/restore cursor at the start/end
   Write-Host ([char]27+'[s' + $Msg + [char]27+'[u') -NoNewline
}
```
<br><br>

---
### **The progress-bar area where the spinner will be can be frozen so that no scrolling happens there**
We can lock that area by defining our scroll margin area which will not include the progress-bar lines.
As-in for example freeze the bottom 3 lines, that area will be our progress-bar area, which will limit the actual scroll margin area.  
for ex. scroll margin: from 1 to 42, inclusive (on 45 row console)  
And then we can also add a line border to designate the progress-bar area, so that it's visible by the end-user

### **The dots are from 10240 till 10495 (256 icons total)**
```PowerShell
10240..10495 | foreach {[pscustomobject]@{ID=$_;Char=[char]$_}} | ogv
```
<br><br>

---
### **General process overview**
The normal output will be saved in the $results variable, the verbose output will be sent to the spinner status.  
Once the function finishes, then the status will be changed to DONE and the spinner job will end.
```PowerShell
$results = Install-MyCustomApp -Verbose 3>&1 | Start-Spinner
```
<br><br>

---
### **Get the vertical cursor position in CMD/console**
When trying to get the cursor position in CMD, then the usual ways like `[System.Console]::GetCursorPosition()` or `$Host.UI.RawUI.CursorPosition` do not give out the cursor on the window, but rather on the buffer.  
So if the buffer for example is 9000 lines long, and you're already a few pages down in your console, then the vertical position could be 100+.  
Which means you can not find where the cursor is in CMD. As such the only valid way I found is to use the `ESC[6n` sequence.  
But the problem with that sequence is that it returns an escape sequence itself and most importantly it gives back the position, only if you actually run that `ESC[6n`.  
So it was tricky to get the result back from that particular sequence. Thankfully I found a GitHub issue that this is answered.  
[GitHub issue in PowerShell repo](https://github.com/PowerShell/PSReadLine/issues/799#issuecomment-436990981)  
On the contrary in *Windows Terminal* the regular ways worked without issue, as-in the result was actually the position of the cursor within the window and not within the buffer.  
In any case, once I found the solution, I made a function specifically for that (`Get-CursorPosition`).  
This gives us the benefit to be able to know if the cursor is at the bottom of the screen while in CMD.  
Cause then I need to move the whole buffer one line up in order to show the spinners that take up 2 lines in height.  
Again as I mentioned, this was working in WT and thus I could find if the cursor was currently at the bottom while using the\[console\] class, but was not working in CMD.
<br><br>

---
### **Do not store string variables inside the while loop**
The string datatype is immutable (which is a well known fact). Thus every time we create a new variable for a string, it gets stored in a different address memory. Now imagine if you have a while loop that loops every 40 milliseconds (that is the VeryFast option in the Speed parameter of Start-Spinner). That means it runs 25 times per second. And then assume that your task will take let's say 20 minutes. So there will be hundreds of loops till it finishes. Now imagine that you create 4 string variables on each loop which take up a few bytes. Lets say for the sake of this argument, its 25 characters per variable, and since these are unicode, then so a total of 400 bytes (4 variables x 25 characters x 4 bytes per character). Now, each time the loop starts over those bytes get added since strings are immutable. Which means if you run this lets say 30.000 times (for ex. each loop takes 40 milliseconds so that is 25 times per second, and the whole task takes 20 minutes, which results in 30.000 loops). So the total memory that those strings will take is 400 bytes x 30.000 times = 12MB for just that run of the spinner. So as you can imagine we do not want to take up so much memory space just to use our spinner.  
Now what we can do, is run a Garbage Collection every so often, inside the while loop, so that the unused memory will be freed. Which means all the variables that we don't need anymore will get discarded. Though the thing is, that we cannot control how the garbage colection works so it's not guaranteed that .NET will free up our unused memory.
Another way to solve that issue of course, is to just not use string variables at all inside our loop. Either use a StringBuilder, which is muttable, and thus we can re-write it. Or don't save any variables at all, and just show the end result directly.  
Like for example use Write-Host and inside parenthesis put everything that we want to show. Instead of saving the text into a string variable and then using it like `Write-Host $output`.

