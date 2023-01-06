
[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $msAppPath,
    [Parameter(Position = 1, mandatory = $true)]
    [string] $appSourcePath)

process {
    write-host "******************************************";
    write-host "Packing your Power App to msApp file";
    write-host "******************************************";

    pac canvas pack --msApp $msAppPath --sources $appSourcePath

    write-host "done";
}
