
[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $msAppPath,
    [Parameter(Position = 1, mandatory = $true)]
    [string] $appSourcePath)

process {
    write-host "******************************************";
    write-host "Unpacking your Power App to msApp file";
    write-host "******************************************";

    pac canvas unpack --msApp $msAppPath --sources $appSourcePath

    write-host "done";
}
