function LaunchVsDevShell {
  $VsInstallPath = & "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" "-latest" "-property" "installationPath"
  Import-Module (Join-Path $VsInstallPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll")
  Enter-VsDevShell -VsInstallPath $VsInstallPath -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"
}

function AdjustPathsForDevEnv {
  $RustPath = "$Env:USERPROFILE\.cargo\bin"
  $GitPath = "$Env:ProgramFiles\Git\cmd"
  $Env:Path += ";$Env:ProgramFiles\Git\cmd;$Env:USERPROFILE\.cargo\bin"
  $Env:Path += ";$GitPath;RustPath"
}

function SetDemikernelEnvVars {
  $env:CONFIG_PATH = "C:\config-catnap-new.yaml"
  $env:DEBUG = "yes"
  $env:LIBDPDK_PATH = "C:\Users\Administrator\AppData\Local\dpdk"
  $env:LIBOS = "catnap"
  $env:RUST_BACKTRACE=0
  $env:RUST_LOG="notrace"
  $env:XDP_PATH = "C:\Users\Administrator\xdp-dev-kit"
}

LaunchVsDevShell
AdjustPathsForDevEnv
SetDemikernelEnvVars

function GitStatus { git status }
Set-Alias gs GitStatus

function GitDiff { git diff }
Set-Alias gd GitDiff

function GitPull { git pull }
Set-Alias -Force gp GitPull

function Make { nmake }
Set-Alias -Force mm Make

function MakeClean { nmake clean }
Set-Alias -Force mc MakeClean

function MakeCleanMake { nmake clean && nmake }
Set-Alias -Force mcm MakeCleanMake

function MakeTest { nmake test-unit-rust }
Set-Alias -Force mt MakeTest

function MakeCleanMakeTest { nmake clean && nmake test-unit-rust }
Set-Alias -Force mcmt MakeCleanMakeTest

function GitCleanFdx { git clean -fdx }
Set-Alias -Force fdx GitCleanFdx
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Set-PSReadLineOption -EditMode Vi

Set-PSReadLineKeyHandler -Key Ctrl+f -ScriptBlock {
    param($key, $arg)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion()
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if (-not [string]::IsNullOrWhiteSpace($line)) {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}
