param(
    [Parameter(Mandatory = $true)]
    [string]$Server,
    [Parameter(Mandatory = $true)]
    [string]$ServiceName,
    [Parameter(Mandatory = $true)]
    [string]$WarPath,
    [Parameter(Mandatory = $true)]
    [PSCredential]$Credential,
    [string]$RemoteWarPath = 'C:\app\application\tomcat\mes\webapps\ROOT.war'
)

$ErrorActionPreference = 'Stop'
$war = (Resolve-Path -LiteralPath $WarPath).Path
$localHash = (Get-FileHash -LiteralPath $war -Algorithm SHA256).Hash
$session = New-PSSession -ComputerName $Server -Credential $Credential -Authentication Negotiate

try {
    $remoteInfo = Invoke-Command -Session $session -ArgumentList $ServiceName, $RemoteWarPath -ScriptBlock {
        param($ServiceName, $RemoteWarPath)
        $ErrorActionPreference = 'Stop'
        $service = Get-Service -Name $ServiceName
        if ($service.Status -ne 'Stopped') {
            Stop-Service -Name $ServiceName
            $service.WaitForStatus('Stopped', [TimeSpan]::FromMinutes(3))
        }

        $deployDirectory = Split-Path -Parent $RemoteWarPath
        $backupDirectory = Join-Path (Split-Path -Parent $deployDirectory) 'backup'
        New-Item -ItemType Directory -Force -Path $backupDirectory | Out-Null

        if (Test-Path -LiteralPath $RemoteWarPath) {
            $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
            $backupPath = Join-Path $backupDirectory "ROOT-$stamp.war"
            Copy-Item -LiteralPath $RemoteWarPath -Destination $backupPath -Force
        }

        return @{ UploadPath = "$RemoteWarPath.uploading" }
    }

    Copy-Item -LiteralPath $war -Destination $remoteInfo.UploadPath -ToSession $session -Force

    $result = Invoke-Command -Session $session -ArgumentList $ServiceName, $RemoteWarPath, $remoteInfo.UploadPath -ScriptBlock {
        param($ServiceName, $RemoteWarPath, $UploadPath)
        $ErrorActionPreference = 'Stop'
        Move-Item -LiteralPath $UploadPath -Destination $RemoteWarPath -Force
        $hash = (Get-FileHash -LiteralPath $RemoteWarPath -Algorithm SHA256).Hash
        Start-Service -Name $ServiceName
        (Get-Service -Name $ServiceName).WaitForStatus('Running', [TimeSpan]::FromMinutes(3))
        return @{ Hash = $hash; Status = (Get-Service -Name $ServiceName).Status.ToString() }
    }

    if ($result.Hash -ne $localHash) {
        throw "Hash mismatch after deployment to $Server"
    }
    Write-Output "DEPLOYED server=$Server service=$ServiceName status=$($result.Status) sha256=$($result.Hash)"
} finally {
    if ($session) {
        Remove-PSSession $session
    }
}

