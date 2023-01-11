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

function InvokeWebRequest {
    Param(
        [Hashtable] $headers,
        [string] $method,
        [string] $body,
        [string] $outFile,
        [string] $uri,
        [switch] $retry,
        [switch] $ignoreErrors
    )

    try {
        $params = @{ "UseBasicParsing" = $true }
        if ($headers) {
            $params += @{ "headers" = $headers }
        }
        if ($method) {
            $params += @{ "method" = $method }
        }
        if ($body) {
            $params += @{ "body" = $body }
        }
        if ($outfile) {
            $params += @{ "outfile" = $outfile }
        }
        Invoke-WebRequest  @params -Uri $uri
    }
    catch {
        $message = GetExtendedErrorMessage -errorRecord $_
        if ($retry) {
            Write-Host $message
            Write-Host "...retrying in 1 minute"
            Start-Sleep -Seconds 60
            try {
                Invoke-WebRequest  @params -Uri $uri
                return
            }
            catch {}
        }
        if ($ignoreErrors.IsPresent) {
            Write-Host $message
        }
        else {
            Write-Host "::Error::$message"
            throw $message
        }
    }
}

function GetExtendedErrorMessage {
    Param(
        $errorRecord
    )

    $exception = $errorRecord.Exception
    $message = $exception.Message

    try {
        $errorDetails = $errorRecord.ErrorDetails | ConvertFrom-Json
        $message += " $($errorDetails.error)`r`n$($errorDetails.error_description)"
    }
    catch {}
    try {
        if ($exception -is [System.Management.Automation.MethodInvocationException]) {
            $exception = $exception.InnerException
        }
        $webException = [System.Net.WebException]$exception
        $webResponse = $webException.Response
        try {
            if ($webResponse.StatusDescription) {
                $message += "`r`n$($webResponse.StatusDescription)"
            }
        }
        catch {}
        $reqstream = $webResponse.GetResponseStream()
        $sr = new-object System.IO.StreamReader $reqstream
        $result = $sr.ReadToEnd()
        try {
            $json = $result | ConvertFrom-Json
            $message += "`r`n$($json.Message)"
        }
        catch {
            $message += "`r`n$result"
        }
        try {
            $correlationX = $webResponse.GetResponseHeader('ms-correlation-x')
            if ($correlationX) {
                $message += " (ms-correlation-x = $correlationX)"
            }
        }
        catch {}
    }
    catch {}
    $message
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
        $releases;
    }
}
else {
    $releases
}

Write-Host "Found : "$releases.Count " releases";

foreach ($release in $releases) {
    Write-Host "Release: "$release.url
}