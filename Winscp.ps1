param (
    [string] $localPath,
    [string] $remotePath,
    [string] $hostname,
    [string] $user,
    [string] $password,
    [string] $fileName
)
         
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::ftp
        HostName = $hostname
        UserName = $user
        Password = $password
        #SshHostKeyFingerprint = "ssh-rsa 2048 xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
    }
 
    $session = New-Object WinSCP.Session
 
    try
    {
        # Connect
        $session.Open($sessionOptions)
 
        # Format timestamp
        #$stamp = $(Get-Date -Format "yyyyMMddHHmmss")
 
        # Download the file and throw on any error
        $session.GetFiles(($remotePath + $fileName),($localPath + $fileName)).Check()
        #Write-Host $session.Output 
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch [Exception]
{
    Write-Host ("Error: {0}" -f $_.Exception.Message)
    exit 1
}