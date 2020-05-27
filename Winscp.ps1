param (
    [string] $winscpPath = "C:\Program Files (x86)\WinSCP\WinSCPnet.dll",
    [string] $localPath,
    [string] $remotePath,
    [string] $hostname,
    [string] $user,
    [string] $password,
    [string] $fileName,
    [string] $ftpmode = "Passive",
    [string] $ftpsecure = "None",
    [string] $protocol = "ftp",
    [string] $transferMode = "Binary",
    [string] $ssh,
    [string] $recipient,
    [switch] $encryption,
    [string] $option
)

# Testing variables
<#
$hostname = "test.rebex.net"
$localPath = "C:\Winscp\"
$remotePath = "/"
$filename = "*.txt"
$protocol = "sftp"
$user = "demo"
$password = 'password'
$option = "list"
$ssh = ""
#>

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
    FtpMode = $ftpmode
    FtpSecure = $ftpsecure
    Protocol = $protocol
    HostName = $hostname
    UserName = $user
}

if($password -and !$ssh)
{ $sessionOptions.Password = $password }
elseif($password -and $ssh)
{
    $sessionOptions.SshHostKeyFingerprint = $ssh 
    $sessionOptions.Password = $password
}
else
{
    Write-Host "No password or SSH key specified!"
    Exit 8
}
$sessionOptions
Exit 

$session = New-Object WinSCP.Session
if($option -eq "upload")
{
    try
    {
        # Connect
        $session.Open($sessionOptions)

        # Upload files
        $transferOptions = New-Object WinSCP.TransferOptions
        $transferOptions.TransferMode = $transferMode

        $transferResult = $session.PutFiles(($localPath + $filename),$remotePath, $False, $transferOptions)
    
        # Throw on any error
        $transferResult.Check()
        $session.Output
    
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
        $sessionResult = $session.GetFiles(($remotePath + $fileName),$localPath)
        
        # Throw error if found
        $sessionResult.Check()
        $session.Output
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
elseif($option -eq "list")
{
    try
    {
        # Connect
        $session.Open($sessionOptions)
 
        # Download the file and throw on any error
        $sessionResult = $session.ListDirectory($remotePath)
        
        # Throw error if found
        $session.Output
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
    Write-Host "Option not specified, must be 'upload/download/list'"
    Exit 8
}
