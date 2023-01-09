# Power Platform Test
Test repository to explore how we can use Github and Github actions to build an ALM set up for building Power Platform content for Business Central. Note this is just a prototype.


## Actions
**CICD**

Automatically deploys an new version of the solution to QA environment when a push to main is complete

**Create release**

Creates a release with a managed and unmanaged version of the solution.


**Deploy solution from branch**

Packages and deploys the solution to a specified environment.

**Get latest solution changes**

NOTE: Cannot be run from main - to avoid direct commits 

Exports the Power platform solution from a specified environment. Unpacks the code and pushed a commit to your branch with the changes 

## Missing functionality
- "Deploy from release" action 
- "Add sample Apps" action (makes more sense when we have a template)
- Script to update hardcoded dependencies in Power App (current limitation in connector)
- Better flow for getting managed solution.
- General clean up - most only makes sense to do when we move to the ALGO repo


## Example of development work flow 
1. Create a new branch based on master 
2. Run "Deploy solution from branch" to your dev environment 
3. Log in to make.powerapps.com and make the changes you want 
4. Run "Get latest solution changes" in the branch 
5. Create a PR with you changes 
6. Done 
