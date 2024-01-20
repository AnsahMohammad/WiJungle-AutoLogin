# Login to SVNIT network

# initializing the configurations
if (-not (Test-Path login.config)) {
    $Username = Read-Host "Enter your username"
    $Password = Read-Host "Enter the Password" -AsSecureString

    # Save USERNAME and PASSWORD in login.config
    Set-Content -Path login.config -Value "USERNAME=$Username" -Encoding utf8
    Add-Content -Path login.config -Value "PASSWORD=$(ConvertFrom-SecureString $Password)" -Encoding utf8
}

# Fetching the data from config file
$Config = Get-Content -Path login.config | Out-String | Invoke-Expression

# keepalive the connection
function KeepAlive {
    param (
        [string]$UserId,
        [string]$K1
    )

    while ($true) {
        Start-Sleep -Seconds 50
        $Response = Invoke-RestMethod -Uri "https://172.16.1.1:8090/index.php?pageto=ka&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3&u=$UserId&k1=$K1&username=$($Config.USERNAME)" -Method Post -UseBasicParsing

        if ($Response.status -eq "fail") {
            Write-Host "Error occurred while connecting to the network"
        }
    }
}

function LoginToNetwork {
    # Checking for the SVNIT connection
    if (Test-Connection -ComputerName "172.16.1.1" -Count 1 -Quiet) {
        Write-Host "Connecting to SVNIT network"

        $Response = Invoke-RestMethod -Uri "https://172.16.1.1:8090/index.php?pageto=c&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3" -Method Post -UseBasicParsing -Body @{
            fixeduserid  = $Config.USERNAME
            loginMethod  = 6
            password     = $Config.PASSWORD
            portal       = 1
            stage        = 9
        }

        if ($Response.status -eq "fail") {
            Write-Host "Error occurred while connecting to the network"
        }
        else {
            Write-Host "Connected to SVNIT network"
        }

        $UserId = $Response.data.userid
        $K1 = $Response.data.k1

        Start-Job -ScriptBlock { param($UserId, $K1) KeepAlive -UserId $UserId -K1 $K1 } -ArgumentList $UserId, $K1
    }
    else {
        Write-Host "Couldn't find the SVNIT network"
        exit 1
    }
}

function Logout {
    Invoke-RestMethod -Uri "https://172.16.1.1:8090/index.php?pageto=fbo&operation=4&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3" -Method Post -UseBasicParsing
}

# main execution begins here

LoginToNetwork

# Wait for user input
while ($true) {
    $Cmd = Read-Host "Enter command"
    if ($Cmd -eq "logout") {
        # Kill the keepalive process
        Stop-Job -Name "KeepAlive"
        Logout
        Write-Host "Logged out"
        exit 0
    }
    elseif ($Cmd -eq "login") {
        LoginToNetwork
    }
    elseif ($Cmd -eq "help") {
        Write-Host "Enter command 'login' to login to SVNIT network"
        Write-Host "Enter command 'logout' to logout from SVNIT network"
    }
    else {
        Write-Host "Invalid command"
    }
}
