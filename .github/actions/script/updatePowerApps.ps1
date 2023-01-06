# NOTE: Still work in progress 
function updateAllFileAndFolderNames {
    param(
        [Parameter(Position = 0, mandatory = $true)] [string] $rootFolder,
        [Parameter(Position = 0, mandatory = $true)] [string] $oldValue,
        [Parameter(Position = 0, mandatory = $true)] [string] $newValue
    )

    $powerAppFiles = Get-ChildItem -Recurse -Directory $rootFolder

    Write-Host "Update folder and files";
    Write-Host "Old name: "$oldValue;
    Write-Host "New name: "$newValue;   

    foreach ($file in $powerAppFiles) {
        $fileName = $file.FullName;
        if ($file.name.contains($oldValue)) {
            
            $newName = $fileName.Replace($oldValue, $newValue);
            Write-Host $fileName"<-- updated";
            Rename-Item -Path $fileName $newName;            
        }
    }

    $powerAppFiles = Get-ChildItem -Recurse -File $rootFolder
    foreach ($file in $powerAppFiles) {
        $fileName = $file.FullName;
        if ($file.name.contains($oldValue)) {
            
            $newName = $fileName.Replace($oldValue, $newValue);
            Write-Host $fileName"<-- updated";
            Rename-Item -Path $fileName $newName;            
        }
    }
}

function updateAllFileContent {
    param(
        [Parameter(Position = 0, mandatory = $true)] [string] $rootFolder,
        [Parameter(Position = 0, mandatory = $true)] [string] $oldDisplayName,
        [Parameter(Position = 0, mandatory = $true)] [string] $newDisplayName,
        [Parameter(Position = 0, mandatory = $true)] [string] $oldAppName,
        [Parameter(Position = 0, mandatory = $true)] [string] $newAppName
    )

    Write-Host "Update file content";
    Write-Host "Old App name:     "$oldAppName;
    Write-Host "New App name:     "$newAppName;   
    Write-Host "Old Display name: "$oldDisplayName;
    Write-Host "New Display name: "$newDisplayName;   
    $powerAppFiles = Get-ChildItem -Recurse -File $rootFolder
    foreach ($file in $powerAppFiles) {
        $fileContent = Get-Content $file.FullName;

        if (Select-String -Pattern $oldDisplayName -InputObject $fileContent) {
            $fileContent = $fileContent.Replace($oldDisplayName, $newDisplayName);
            Write-Host $file.FullName" --> updated display name ";
        }

        if (Select-String -Pattern $oldAppName -InputObject $fileContent) {
            $fileContent = $fileContent.Replace($oldAppName, $newAppName);
            Write-Host $file.FullName" --> updated app name";
        }

        Set-Content -Path $file.FullName -Value $fileContent.Replace($oldAppName, $newAppName);
    }
}

function getPowerAppsInSolution {
    param(
        [Parameter(Position = 0, mandatory = $true)] [string] $solutionPath
    )

    $xmlFile = (Get-ChildItem $solutionPath"/Other/Solution.xml");
    if ($xmlFile.Exists) {
        Write-Host "Reading PowerAppsFrom: "$xmlFile.FullName;
        $xml = [xml](Get-Content $xmlFile.FullName);
            
        $powerApps = $xml.SelectNodes("//RootComponent");
        Write-Host "Found "$powerApps.Count" PowerApps";

        return $powerApps
    }
}

function getPowerAppDisplayName {
    param(
        [Parameter(Position = 0, mandatory = $true)] [string] $sourcePath
    )

    $appManifestFile = Get-ChildItem $sourcePath"/CanvasManifest.json";        
    if ($appManifestFile.Exists) {
        $jsonFile = Get-Content $appManifestFile.FullName | ConvertFrom-Json;
        $powerAppName = $jsonFile.Properties.Name;
        return $powerAppName;
    }
    else {
        Write-Error "could not find file: "$sourcePath"/CanvasManifest.json";        
    }
}


$powerApps = getPowerAppsInSolution -solutionPath .\BcSampleAppsSolution;
foreach ($powerApp in $powerApps) {
    $powerAppName = $powerApp.Attributes[1].'#text';
    $powerAppDisplayName = getPowerAppDisplayName -sourcePath .\BcSampleAppsSolution\CanvasApps\src\$powerAppName;

    Write-Host "Updating App: " $powerAppName " (" $powerAppDisplayName")";    
    updateAllFileAndFolderNames -rootFolder .\BcSampleAppsSolution -oldValue $powerAppName -newValue new_bcwarehousehelperdev_290e3;
    updateAllFileContent -rootFolder .\BcSampleAppsSolution -oldDisplayName $powerAppDisplayName -newDisplayName "BC Warehouse Helper" -oldAppName $powerAppName -newAppName new_bcwarehousehelperdev_290e3;

}