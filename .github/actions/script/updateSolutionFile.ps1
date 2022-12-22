﻿[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $solutionPath,
    [Parameter(Position = 1, mandatory = $false)]
    [string] $version,
    [Parameter(Position = 2, mandatory = $false)]
    [string] $postFix
)

$xmlFile = (Get-ChildItem $solutionPath);
if ($xmlFile.Exists) {
    Write-Host "Updating solution: "$xmlFile.FullName;
    $xml = [xml](Get-Content $xmlFile.FullName);
    
    if ($version) {
        $node = $xml.SelectSingleNode("//Version");
        Write-Host "Updating version: "$version;
        $node.'#text' = $version;
    }

    if ($postFix) {
        $nodeWithName = $xml.SelectSingleNode("//UniqueName");
        $newName = $nodeWithName.'#text' + "__" + $postFix;
        Write-Host "Updating solution name: "$newName;
        $nodeWithName.'#text' = $newName;    
    }
    else {
        $nodeWithName = $xml.SelectSingleNode("//UniqueName");
        if ($nodeWithName.'#text' -match "__") {
            $postFixIndex = $nodeWithName.'#text'.LastIndexOf("__");
            $newName = $nodeWithName.'#text'.subString($postFixIndex)
            Write-Host "Updating solution name: "$newName;
            $nodeWithName.'#text' = $newName;    
        }
    }

    $xml.Save($xmlFile.FullName);
}
else {
    Write-Error "Could not find file: " + $solutionPath;
}
