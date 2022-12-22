[CmdletBinding()]
param(
  [Parameter(Position = 0, mandatory = $true)]
  [string] $solutionName,
  [Parameter(Position = 1, mandatory = $true)]
  [string] $environmentName
)

if (git status --porcelain) {
  git config user.email "git@workflow.com"; 
  git config user.name "Pull changes workflow"; 
  git add $solutionName; 
  git commit -m "pull latest solution changes from " + $environmentName; 
  git push; 
}
