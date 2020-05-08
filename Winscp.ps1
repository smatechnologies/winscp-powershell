param (
    [string] $winscpPath = "C:\Program Files (x86)\WinSCP\WinSCPnet.dll",
    [string] $localPath,
    [string] $remotePath,
    [string] $hostname,
    [string] $user,
    [string] $password,
    [string] $fileName,
    [string] $option
)
         
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "$winscpPath"
}
catch [Exception]
{
    Write-Host "Error: "$_.Exception.Message
    Exit 1
}

# Setup session options
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::ftp
    HostName = $hostname
    UserName = $user
    Password = $password
    #SshHostKeyFingerprint = "ssh-rsa 2048 xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
}
 
$session = New-Object WinSCP.Session
 
if($option -eq "upload")
{
    try
    {
        # Connect
        $session.Open($sessionOptions)

        # Upload files
        $transferOptions = New-Object WinSCP.TransferOptions
        #$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
        $transferResult = $session.PutFiles($localPath,($remotePath + $filename), $False, $transferOptions)
    
        # Throw on any error
        $transferResult.Check()
        Write-Host $session.Output
    
        # Print results
        foreach ($transfer in $transferResult.Transfers)
        {
            Write-Host "Upload of $($transfer.FileName) succeeded"
        }
    }
    catch [Exception]
    {
        Write-Host $_.Exception.Message
        Exit 7
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
}
elseif($option -eq "download")
{
    try
    {
        # Connect
        $session.Open($sessionOptions)
 
        # Download the file and throw on any error
        $sessionResult = $session.GetFiles(($remotePath + $fileName),($localPath + $fileName))
        
        # Throw error if found
        $sessionResult.Check()
        Write-Host $session.Output
    }
    catch [Exception]
    {
        Write-Host $_.Exception.Message
        Exit 7
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }    
}
else 
{
    Write-Host "Option not specified, must be 'upload' or 'download'"
    Exit 8
}
