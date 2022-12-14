
[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $zipPath,
    [Parameter(Position = 1, mandatory = $true)]
    [string] $solutionPath)

process {
    write-host "******************************************";
    write-host "Unpacking your Power App solution";
    write-host "******************************************";

    pac solution unpack -z $zipPath -f $solutionPath -pca;

    write-host "done";
}
