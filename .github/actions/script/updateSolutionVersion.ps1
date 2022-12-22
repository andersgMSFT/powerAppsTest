[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $solutionPath,
    [Parameter(Position = 0, mandatory = $false)]
    [string] $version,
    [Parameter(Position = 0, mandatory = $false)]
    [string] $dev
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

    if ($dev -eq "true") {
        $nodeWithName = $xml.SelectSingleNode("//UniqueName");
        $newName = $nodeWithName.'#text' + "_dev"
        Write-Host "Updating solution name: "$newName;
        $nodeWithName.'#text' = $newName;    
    }
    else {
        $nodeWithName = $xml.SelectSingleNode("//UniqueName");
        if ($nodeWithName.'#text' -match "_dev") {
            $newName = $nodeWithName.'#text'.subString($nodeWithName.'#text'.Length - 4)
            Write-Host "Updating solution name: "$newName;
            $nodeWithName.'#text' = $newName;    
        }
    }

    $xml.Save($xmlFile.FullName);
}
else {
    Write-Error "Could not find file: " + $solutionPath;
}

