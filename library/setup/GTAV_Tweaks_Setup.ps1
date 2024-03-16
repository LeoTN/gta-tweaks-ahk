$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
# This makes sure to retrieve the script path.
If ($MyInvocation.MyCommand.CommandType -eq "ExternalScript") { 
    $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition 
}
Else {
    $scriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) 
    If (!$scriptPath) { 
        $scriptPath = "." 
    } 
}
$scriptParentDirectory = Split-Path -Parent $scriptPath
Clear-Host

function onInit() {
    $executableName = "GTAV_Tweaks.exe"
    $global:executableLocation = Join-Path -Path $scriptParentDirectory -ChildPath $executableName

    If (-not (Test-Path -Path $global:executableLocation)) {
        Write-Host "[ERROR] Could not find [$executableName] at [$scriptParentDirectory]."
        Exit
    }
    If (unblockExecutable) {
        runExecutable | Out-Null
    }
}

function unblockExecutable() {
    Try {
        Unblock-File -Path $global:executableLocation | Out-Null
        Return $true
    }
    Catch {
        Return $false
    }
}

function runExecutable() {
    Try {
        Start-Process -FilePath $global:executableLocation | Out-Null
        Return $true
    }
    Catch {
        Return $false
    }  
}

onInit