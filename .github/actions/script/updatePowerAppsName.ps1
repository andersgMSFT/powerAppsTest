[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $false)] [string] $postFix
)


function updateAllFiles {
    param(
        [Parameter(Position = 0, mandatory = $true)] [string] $rootFolder,
        [Parameter(Position = 0, mandatory = $true)] [string] $oldValue,
        [Parameter(Position = 0, mandatory = $true)] [string] $newValue
    )

    $powerAppFiles = Get-ChildItem -Recurse -File $rootFolder
    foreach ($file in $powerAppFiles) {
        $fileContent = Get-Content $file.FullName;
        if (Select-String -Pattern $oldValue -InputObject $fileContent) {
            Set-Content -Path $file.FullName -Value $fileContent.Replace($oldValue, $newValue);
            Write-Host $file.FullName" --> updated ";
        }
    }

}

function updateAllPowerApps {
    $connectionFiles = Get-ChildItem -Recurse -File -Include CanvasManifest.json    

    foreach ($connectionFile in $connectionFiles) {

        $connectionsFilePath = $connectionFile.FullName;
        $connectionsfile = (Get-ChildItem $connectionsFilePath);
        
        if ($connectionsfile.Exists) {
            try {
                $jsonFile = Get-Content $connectionsfile.FullName | ConvertFrom-Json;
                $powerAppName = $jsonFile.Properties.Name;

                $powerAppNameBase = $powerAppName;
                $postFixIndex = $powerAppName.IndexOf("__");
                if ($postFixIndex -gt 0) {
                    #Find the base app name without postfix
                    $powerAppNameBase = $powerAppName.subString(0, $postFixIndex);
                }

                $newPowerAppName = $powerAppNameBase;
                if ($postFix) {
                    $newPowerAppName = $powerAppNameBase + "__" + $postFix;
                }

                Write-Host "Updating powerApp name from: "$powerAppName;
                Write-Host "                         to: "$newPowerAppName;

                updateAllFiles -rootFolder . -oldValue $powerAppName -newValue $newPowerAppName;
            }
            catch {
                Write-Warning "Error while updating: " + $connectionsFilePath;
                continue;
            }
            
        }
        else {
            Write-Error "Could not find file: " + $connectionsFilePath;
            return "";
        }
    }
}

# Work around to calling the parameter with empty string from work flow
if ($postFix -eq "0") {
    $postFix = "";
}

updateAllPowerApps;