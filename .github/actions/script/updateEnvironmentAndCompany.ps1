[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)] [string] $companyId,
    [Parameter(Position = 1, mandatory = $true)] [string] $environmentName
)


function getCurrentSettings {
    # The Business Central connector id
    $connectorId = "db53e06c-0d5d-4540-a126-3218ac51e136";

    $connectionFiles = Get-ChildItem -Recurse -File -Include Connections.json    
    foreach ($connectionFile in $connectionFiles) {

        $connectionsFilePath = $connectionFile.FullName;
        $connectionsfile = (Get-ChildItem $connectionsFilePath);
        
        if ($connectionsfile.Exists) {
            try {
                $jsonFile = Get-Content $connectionsfile.FullName | ConvertFrom-Json;
                $currentEnvironmentAndCompany = ($jsonFile.$connectorId.datasets | Get-Member -MemberType NoteProperty).Name;
                #NOTE: We assume all have the same BC connection, so we just return the first one.
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
    Write-Error "No connection files in the current folder: ";
    return "";
}


function replaceOldSettings {
    param(
        [Parameter(Position = 0, mandatory = $true)] [string] $rootFolder,
        [Parameter(Position = 0, mandatory = $true)] [string] $oldSetting,
        [Parameter(Position = 0, mandatory = $true)] [string] $newSetting
    )

    $powerAppFiles = Get-ChildItem -Recurse -File $rootFolder
    foreach ($file in $powerAppFiles) {
        $fileContent = Get-Content $file.FullName;
        if (Select-String -Pattern $oldSetting -InputObject $fileContent) {
            Set-Content -Path $file.FullName -Value $fileContent.Replace($oldSetting, $newSetting);
            Write-Host $file.FullName" --> updated ";
        }
    }

}

$currentSettings = getCurrentSettings;
if ([string]::IsNullOrEmpty($currentSettings)) {
    Write-Error "Could not find connections file";
    return 2;
}

if ([string]::IsNullOrEmpty($companyId) -or [string]::IsNullOrEmpty($environmentName)) {
    Write-Error "Missing environment or company"
    return 2;
}

$newSettings = "$environmentName,$companyId";
Write-Host "Current settings: "$currentSettings;
Write-Host "New settings: "$newSettings;

replaceOldSettings -oldSetting $currentSettings -newSetting $newSettings -rootFolder .;
