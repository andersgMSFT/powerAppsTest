
[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $zipPath,
    [Parameter(Position = 1, mandatory = $true)]
    [string] $solutionPath)

process {
    write-host "******************************************";
    write-host "Packing your Power App solution";
    write-host "******************************************";

    pac solution pack -z $zipPath -f $solutionPath -pca;

    write-host "done";
}
