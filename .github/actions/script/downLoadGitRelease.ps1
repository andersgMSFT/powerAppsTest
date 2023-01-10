function DownloadRelease {
    Param(
        [string] $token,
        [string] $projects = "*",
        [string] $api_url = $ENV:GITHUB_API_URL,
        [string] $repository = $ENV:GITHUB_REPOSITORY,
        [string] $path,
        [string] $mask = "Apps",
        $release
    )

    if ($projects -eq "") { $projects = "*" }
    Write-Host "Downloading release $($release.Name), projects $projects, type $mask"
    if ([string]::IsNullOrEmpty($token)) {
        $authstatus = (invoke-gh -silent -returnValue auth status --show-token) -join " "
        $token = $authStatus.SubString($authstatus.IndexOf('Token: ') + 7).Trim()
    }
    $headers = @{ 
        "Accept"        = "application/octet-stream"
        "Authorization" = "token $token"
    }
    $projects.Split(',') | ForEach-Object {
        $project = $_.Replace('\', '_')
        Write-Host "project '$project'"
        
        $release.assets | Where-Object { $_.name -like "$project-*-$mask-*.zip" -or $_.name -like "$project-$mask-*.zip" } | ForEach-Object {
            $uri = "$api_url/repos/$repository/releases/assets/$($_.id)"
            Write-Host $uri
            $filename = Join-Path $path $_.name
            InvokeWebRequest -Headers $headers -Uri $uri -OutFile $filename 
            return $filename
        }
    }
}       
