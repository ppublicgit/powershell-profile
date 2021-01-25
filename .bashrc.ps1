$ROOT = "C:\Users\"
$HOMEDRIVE = "C:\"
$HOMEPATH = "paul.abers\"
Set-Variable HOME "$ROOT$HOMEPATH" -Force
(get-psprovider 'FileSystem').Home = $ROOT + $HOMEPATH

cd ~

function cd/ {set-location $ROOT}
# must call conda init powershell once before conda will work
# activate base anaconda
activate.bat

$Shell = $Host.UI.RawUI
$Shell.WindowTitle = "Crappy Windows Terminal"
$background = "Black"
$foreground = "Gray"
$Shell.BackgroundColor = $background
$Shell.ForegroundColor = $foreground
$Host.PrivateData.ErrorBackgroundColor = $background
$Host.PrivateData.WarningBackgroundColor = $background
$Host.PrivateData.DebugBackgroundColor = $background
$Host.PrivateData.VerboseBackgroundColor = $background
$colors = @{}
$colors['Command'] = [System.ConsoleColor]::Yellow
Set-PSReadLineOption -Colors $colors

function Write-BranchName {
    try {
        $branch = git rev-parse --abbrev-ref HEAD

        if($branch -eq "HEAD") {
            $branch = git rev-parse --short HEAD
            Write-Host "($branch)" -NoNewLine -ForegroundColor Magenta
        }
        else {
            Write-Host "($branch)" -NoNewLine -ForegroundColor Magenta
        }
    } catch {
        Write-Host "(no branches)" -NoNewLine -Foreground Magenta
    }
}

function Replace-Path-Home {
    Param ($input_path)
    $regex = "C:\\Users\\paul\.abers.*"
    $regex_root = "C:\\Users.*"
    if ($input_path -match $regex) {
        $output_path = "~" + $input_path.substring(19)
        
    } else {
        if ($input_path -match $regex_root) {
            if ($input_path.length -ge 9) {
                $output_path = $input_path.substring(9)
            }
            else {
                $output_path = "/"
            }
        }
        else {
            $output_path = $input_path
        }
        
    }
    return $output_path
}

function prompt {
    $user = $(Get-WmiObject -Class Win32_ComputerSystem | select username).username
    $path = Convert-Path $PWD
    $correct_path = Replace-Path-Home $path
    $input_prompt = "$>"
    $datetime = get-date -Format "dd.MM.yyyy HH:mm:ss"

    if ($Env:CONDA_PROMPT_MODIFIER) {
        Write-Host $Env:CONDA_PROMPT_MODIFIER -NoNewLine -ForegroundColor DarkCyan
    }
    Write-Host ": " -NoNewLine -ForegroundColor White
    Write-Host $datetime -NoNewLine -ForegroundColor Cyan
    Write-Host " : " -NoNewLine -ForegroundColor White
    Write-Host "$user" -NoNewLine -ForegroundColor DarkGreen
    Write-Host " : " -NoNewLine -ForegroundColor White
    if (Test-Path .git) {
        Write-Host $correct_path -NoNewLine -ForegroundColor Green
        Write-Host " : " -NoNewLine -ForegroundColor White
        Write-BranchName
        Write-Host " "
    }
    else {
        Write-Host $correct_path -NoNewLine -ForegroundColor Green
        Write-Host " " -NoNewLine
    }
    Write-Host " $ " -NoNewline
}