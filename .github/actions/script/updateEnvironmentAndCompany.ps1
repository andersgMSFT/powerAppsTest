[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $AppPath,
    [Parameter(Position = 1, mandatory = $true)]
    [string] $companyId,
    [Parameter(Position = 2, mandatory = $true)]
    [string] $environmentName
)

function getCurrentSettings {
    $connectionsFilePath = $AppPath + "/Connections/Connections.json";
    # The Business Central connector id
    $connectorId = "db53e06c-0d5d-4540-a126-3218ac51e136";

    $connectionsfile = (Get-ChildItem $connectionsFilePath);
    if ($connectionsfile.Exists) {
        try {
            $jsonFile = Get-Content $connectionsfile.FullName | ConvertFrom-Json;
            $currentEnvironmentAndCompany = ($jsonFile.$connectorId.datasets | Get-Member -MemberType NoteProperty).Name   
            return $currentEnvironmentAndCompany; 
        }
        catch {
            Write-Error "Could not find connector node in file: " + $connectorId;
            return "";
        }
       
    }
    else {
        Write-Error "Could not find file: " + $connectionsfile;
        return "";
    }
}

$currentSettings = getCurrentSettings;
if ([string]::IsNullOrEmpty($currentSettings)) {
    Write-Error "Could not find connections file";
    return 2;
}

$newSettings = "$environmentName,$companyId";
Write-Host "Current settings: "$currentSettings;
Write-Host "New settings: "$newSettings;

$powerAppFiles = Get-ChildItem -Recurse -File .\BcSampleAppsSolution\CanvasApps

foreach($file in $powerAppFiles)
{
    $fileContent = Get-Content $file.FullName;
    if(Select-String -Pattern $currentSettings -InputObject $fileContent)
    {
       Set-Content -Path $file.FullName -Value $fileContent.Replace($currentSettings, $newSettings);
       Write-Host $file.FullName" --> updated ";
    }
}


