

# this is just a quick proof-of-concept

# show something on the console and update it every 10 seconds

$block = {
    param ([System.Collections.Concurrent.ConcurrentDictionary[string,string]]$Status)

    function wr([string]$Message) {
       # encapsulate a message with save/restore cursor at the start/end
       Write-Host ([char]27+'[s' + $Message + [char]27+'[u') -NoNewline
    }

    $e      = [char]27
    $Width  = [System.Console]::WindowWidth
    $Height = [System.Console]::WindowHeight
    $Line1  = "$e[$($Height-15);$($Width-15)H"
    $Line2  = "$e[$($Height-14);$($Width-15)H"
    $Line3  = "$e[$($Height-13);$($Width-15)H"
    $Line4  = "$e[$($Height-12);$($Width-15)H"
    $Timer  = [Diagnostics.StopWatch]::StartNew()
    $GCInterval = 10 # <-- in minutes
    while ($true) {
        if ([datetime]::Now.Second % 10 -eq 0) { # <-- show popup every 10 seconds
            $StatusMsg = $Status.Message
            if ($StatusMsg -eq 'DONE') {break}  # <-- exit the loop with a specific message

            if ($StatusMsg.Length -ge 14) {$Msg = $StatusMsg.Substring(0,12)+'…'}
            else                          {$Msg = $StatusMsg}
            $Now = "[$(Get-Date -f 'HH:mm:ss')]"
            $Pad = ' '*(13-$Msg.Length)
            wr (
                $Line1+'╔═════════════╗' +
                $Line2+'║ ' + $Now+'  ║' +
                $Line3+'║'+$Msg+$Pad+'║' +
                $Line4+'╚═════════════╝'
            )
        }
        Start-Sleep -Milliseconds 950

        if ($Timer.Elapsed.TotalMinutes -ge $GCInterval) {
            [GC]::Collect()    # <-- Garbage Collection every 10 minutes
            $Timer.Restart()
            # NOTE: Why do GC ?  Cause on each loop I'm creating a few string variables which
            #       are immutable and thus the memory utilzation stacks up as time goes by
        } #if garbage collection
    } #while loop
    $Timer.Stop()
} #scriptblock

$Status = [System.Collections.Concurrent.ConcurrentDictionary[string,string]]::new()
[void]$Status.TryAdd('Message','just a test')
$job = Start-ThreadJob -ScriptBlock $block -ArgumentList $Status -StreamingHost $Host
# wait a few seconds for the message to show up on the right-side of the console

$Status.Message = 'heres another'
# hit enter a few times in the console to scroll the buffer down
# wait 10 seconds for the refresh

$Status.Message = 'and a longer one'
# hit enter a few times in the console to scroll the buffer down
# wait another 10 seconds for the refresh

$Status.Message = 'DONE'
# this will finish the background job

Get-Job

$job | Stop-Job -PassThru | Remove-Job
