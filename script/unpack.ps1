
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

    pac solution unpack  -pca -c -aw -ad  -z $zipPath -f $solutionPath;

    write-host "done";
}
