
[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $zipPath
)

process {
    write-host "******************************************";
    write-host "Importing the solution to your environment";
    write-host "******************************************";
    Write-Warning "Note: You need to setup auth first ";
    Write-Warning "This is your current settings. Use 'pac auth create' set up new connections";

    pac auth list;

    $userInput = Read-Host -Prompt "Do you want to continue? ('y' to continue)"

    if ($userInput -eq "y") {
        pac solution import --path $zipPath;
    }
}
