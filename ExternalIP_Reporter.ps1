# Grab current location of script
$currentDirectory = $PSScriptRoot
# full url of discord webhook should be in secrets.txt
$URI = (cat "$currentDirectory\secrets.txt").Split(",")

# Does path exist for the file that stores the "current IP"? if not make it
if ([string]$storedIP = Cat -Path "C:\temp\ExternalIP.txt") {} ELSE {New-Item -ItemType File -Path "C:\temp\ExternalIP.txt"| Out-Null}

# Grab current IP via webrequest/restmethod store as variable "CurrentIP"
[string]$CurrentIP = (Invoke-RestMethod -uri "https://damninter.net/" -Method GET | Select-String -Pattern "IPv4\sIP\sis\:(\d+[\.\d+?]+)" -AllMatches).Matches.groups[1].value

# Compare stored IP address from .txt file to the currentIP just found if different notify on webhook and save into file, overwriting.
if ($storedIP -eq $CurrentIP) {}
ELSE
    {
        $Thumbnail = New-DiscordThumbnail -Url "https://raw.githubusercontent.com/EvotecIT/PSDiscord/master/Links/Asset%20130.png"
        $Section = New-DiscordSection -Title "$CurrentIP" -Description ''
        Foreach ($webhook in $URI)
            {
                Send-DiscordMessage -WebHookUrl $webhook -Sections $Section -AvatarName 'ExternalIPChecker'
            }
        $CurrentIP | Out-File -FilePath "C:\temp\ExternalIP.txt" -Force
    }