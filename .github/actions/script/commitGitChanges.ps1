[CmdletBinding()]
param(
  [Parameter(Position = 0, mandatory = $true)]
  [string] $solutionName,
  [Parameter(Position = 1, mandatory = $true)]
  [string] $environmentName
)

if (git status --porcelain) {
  Write-Host "Commiting changes to branch";
  git config user.email "git@workflow.com"; 
  git config user.name "Pull changes workflow"; 
  git add $solutionName; 

  $commitMessage = "pull latest solution changes from " + $environmentName; 
  git commit -m $commitMessage; 
  git push; 
}
else {
  Write-Host "No changes to commit";
}
