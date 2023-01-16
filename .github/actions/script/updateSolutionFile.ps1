[CmdletBinding()]
param(
    [Parameter(Position = 1, mandatory = $false)]
    [string] $version,
    [Parameter(Position = 2, mandatory = $false)]
    [string] $postFix,
    [Parameter(Position = 3, mandatory = $false)]
    [string] $managed
)

function Update-UniqueName {
    param(
        [Parameter(Position = 0, mandatory = $false)]
        [string] $postFix,
        [Parameter(Position = 1, mandatory = $true)]
        [xml] $xml
    )

    # Work around for handling empty value in work flow
    if ($postFix -eq "0") {
        $postFix = "";
    }

    $nodeWithName = $xml.SelectSingleNode("//UniqueName");
    if ($postFix) {
        $newName = $nodeWithName.'#text' + "__" + $postFix;
        Write-Host "Updating solution name: "$newName;
        $nodeWithName.'#text' = $newName;    
    }
    else {
        # Remove postfix if exists
        $postFixIndex = $nodeWithName.'#text'.LastIndexOf("__");       
        if ($postFixIndex -gt -1) {
            Write-Host "Updating solution name (remove postfix): "$nodeWithName.'#text';
            $newName = $nodeWithName.'#text'.Substring(0, $nodeWithName.'#text'.IndexOf("__"));
            $nodeWithName.'#text' = $newName;    
        }
    }
}

function Update-VersionNode {
    param(
        [Parameter(Position = 0, mandatory = $false)]
        [string] $version,
        [Parameter(Position = 1, mandatory = $true)]
        [xml] $xml
    )
    if ($version) {
        $versionNode = $xml.SelectSingleNode("//Version");
        Write-Host "Updating version: "$version;
        $versionNode.'#text' = $version;
    }
}

function Update-ManagedNode {
    param(
        [Parameter(Position = 0, mandatory = $false)]
        [string] $managed,
        [Parameter(Position = 1, mandatory = $true)]
        [xml] $xml
    )

    $managedValue = if ($managed) { "1" } else { "0" };

    $nodeWithName = $xml.SelectSingleNode("//Managed");
    Write-Host "Updating managed flag: "$managedValue;
    $nodeWithName.'#text' = $managedValue;    
}

function Update-SolutionFiles {
    param(
        [Parameter(Position = 0, mandatory = $false)]
        [string] $version,
        [Parameter(Position = 1, mandatory = $false)]
        [string] $postFix,
        [Parameter(Position = 2, mandatory = $false)]
        [string] $managed,
        [Parameter(Position = 3, mandatory = $true)]
        [string[]] $solutionFiles
    )
    foreach ($solutionFile in $solutionFiles) {
        Write-Host "Updating solution: "$solutionFile;
        $xmlFile = [xml](Get-Content $solutionFile);

        Update-VersionNode -version $version -xml $xmlFile;
        Update-UniqueName -postFix $postFix -xml $xmlFile;
        update-ManagedNode -managed $managed -xml $xmlFile;
        
        $xmlFile.Save($solutionFile);
    }
}

function Get-PowerPlatformSolutionFiles {
    $solutionFiles = Get-ChildItem -Path . -Filter "solution.xml" -Recurse -File;
    return $solutionFiles.FullName;
}

$solutionFiles = Get-PowerPlatformSolutionFiles;
Update-SolutionFiles -version $version -postFix $postFix -managed $managed -solutionFiles $solutionFiles;