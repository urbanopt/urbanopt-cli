param (
    [Parameter(Mandatory=$true)][string]$conda_version,
    [Parameter(Mandatory=$true)][string]$python_version,
    [Parameter()][string]$install_path = "."
)

function Invoke-WebRequestExitOnError {
    param([string]$url, [string]$filename)
    Write-Debug "Invoke-WebRequest $url"

    try {
        Invoke-WebRequest -OutFile $filename $url
    }
    catch {
        throw "failed to download $url"
    }
}


function Get-Python {
    param([string]$conda_base_url, [string]$filename, [string]$python_version, [string]$install_path)
    $path = Join-Path "." "${filename}"
	$url = "https://repo.anaconda.com/miniconda/${filename}"
    if (($FORCE_DOWNLOAD -eq 1) -and (Test-Path $path)) {
        Remove-Item $path
    }
    if (!(Test-Path $path)) {
        Invoke-WebRequestExitOnError $url $path
    }

    $full_path = Resolve-Path $install_path
    $dst = Join-Path $full_path "python-$python_version"
    $cmd_args = "/InstallationType=JustMe /AddToPath=0 RegisterPython=0 /S /D=${dst}"
    $result = Start-Process -FilePath ${path} -NoNewWindow -PassThru -Wait -ArgumentList $cmd_args
    if ($FORCE_DOWNLOAD -eq 1) {
        Remove-Item $path
    }
    if ($result.ExitCode -ne 0) {
        $msg = "Failed to run Python installer: ExitCode=${result.ExitCode}" 
        Write-Error $msg
        exit $result.ExitCode
    }
}


### MAIN ###
#
# Example usage:
# .\install_python.ps1 4.12.0 3.9
#
# Anaconda recommends only running this distribution in an Anaconda shell.
# pip will fail with SSL errors in a non-Anaconda PowerShell.
# Anaconda says to workaround the issue by setting this environment variable:
# $env:CONDA_DLL_SEARCH_MODIFICATION_ENABLE = 1
# Refer to https://github.com/conda/conda/issues/8273
# To test the install run these commands:
# .\python-3.9\python --version
# .\python-3.9\Scripts\pip list
#
# To enable debug prints run this in the shell:
# $DebugPreference="Continue"
#
# To prevent re-download of the Python package set the environment variable
# FORCE_DOWNLOAD to 0.
#
# If you get the error "running scripts is disabled on this system" then follow
# the provided link or run the command below to change the security policy for
# the current shell:
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process

$python_version_fields = $python_version -split "\."
if ($python_version_fields.length -ne 2) {
    $msg = "failed to run [$command]: ExitCode={0}" -f $result.ExitCode
    Write-Error "Python version must be major.minor, such as '3.9'"
    exit 1
}
$python_major_minor = -join $python_version_fields[0..1]
$conda_base_url = "https://repo.anaconda.com/miniconda/"
$conda_package_name = "Miniconda3-py${python_major_minor}_${conda_version}-Windows-x86_64.exe"

if (Test-Path env:FORCE_DOWNLOAD) {
    $FORCE_DOWNLOAD = $env:FORCE_DOWNLOAD
} else {
    $FORCE_DOWNLOAD = 1
}
Write-Debug "FORCE_DOWNLOAD=${FORCE_DOWNLOAD}"

if (!(Test-Path $install_path)) {
    mkdir $install_path
}

$ErrorActionPreference = "Stop"
Get-Python $conda_base_url $conda_package_name $python_version $install_path
