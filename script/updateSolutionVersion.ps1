[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $solutionPath,
    [Parameter(Position = 0, mandatory = $true)]
    [string] $version,
    [Parameter(Position = 0, mandatory = $false)]
    [bool] $dev
)

$xmlFile = (Get-ChildItem $solutionPath);
if ($xmlFile.Exists) {
    Write-Host "Updating solution: "$xmlFile.FullName;
    $xml = [xml](Get-Content $xmlFile.FullName);
    $node = $xml.SelectSingleNode("//Version");
    
    Write-Host "Updating version: "$version;
    $node.'#text' = $version;

    if ($dev) {
        $nodeWithName = $xml.SelectSingleNode("//UniqueName");
        Write-Host "Updating solution name: " + $nodeWithName.'#text' + "(dev)";
        $nodeWithName.'#text' = $nodeWithName.'#text' + "(dev)";    
    }

    $xml.Save($xmlFile.FullName);
}
else {
    Write-Error "Could not find file: " + $solutionPath;
}

