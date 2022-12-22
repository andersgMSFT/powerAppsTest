[CmdletBinding()]
param(
    [Parameter(Position = 0, mandatory = $true)]
    [string] $solutionName,
)

if(git status --porcelain)
{
  git config user.email "git@workflow.com"; 
  git config user.name "Workflow"; 
  git add $solutionName; 
  git commit -m "pull latest solution changes"; 
  git push; 
}
