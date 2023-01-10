Param(
    [string] $token,
    [string] $api_url = $ENV:GITHUB_API_URL,
    [string] $repository = $ENV:GITHUB_REPOSITORY
)

function GetHeader {
    param (
        [string] $token,
        [string] $accept = "application/vnd.github.v3+json"
    )
    $headers = @{ "Accept" = $accept }
    if (![string]::IsNullOrEmpty($token)) {
        $headers["Authorization"] = "token $token"
    }

    return $headers
}

Write-Host "Analyzing releases $api_url/repos/$repository/releases"
$releases = @(InvokeWebRequest -Headers (GetHeader -token $token) -Uri "$api_url/repos/$repository/releases" | ConvertFrom-Json)
if ($releases.Count -gt 1) {
    # Sort by SemVer tag
    try {
        $sortedReleases = $releases.tag_name | 
        ForEach-Object { SemVerStrToSemVerObj -semVerStr $_ } | 
        Sort-Object -Property Major, Minor, Patch, Addt0, Addt1, Addt2, Addt3, Addt4 -Descending | 
        ForEach-Object { SemVerObjToSemVerStr -semVerObj $_ } | ForEach-Object {
            $tag_name = $_
            $releases | Where-Object { $_.tag_name -eq $tag_name }
        }
        $sortedReleases
    }
    catch {
        Write-Host -ForegroundColor red "Some of the release tags cannot be recognized as a semantic version string (https://semver.org)"
        Write-Host -ForegroundColor red "Using default GitHub sorting for releases"
        $releases
    }
}
else {
    $releases
}
