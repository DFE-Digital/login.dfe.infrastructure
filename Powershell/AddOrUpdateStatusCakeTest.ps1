# Script to add status cake tests during a build pipeline
# api details can be found here https://www.statuscake.com/api/Tests/Updating%20Inserting%20and%20Deleting%20Tests.md

Param(
    [Parameter(Mandatory=$true)]
    [string]$websiteName, # Name to show for the test e.g. "IEX Proxy (Dev)"
    [Parameter(Mandatory=$true)]
    [string]$hostDomain, # The domain part of the url e.g. "signin-dev-iex-as.azurewebsites.net"
    [Parameter(Mandatory=$true)]
    [string]$urlToTest, # endpoint within the deployed application to act as a health check e.g. "/saml/metadata"
    [Parameter(Mandatory=$true)]
    [string]$tags, # Comma seperated list of tags - no spaces between comma's e.g. "signin"
    [Parameter(Mandatory=$true)]
    [string]$statusCakeUserName, # Username from status cake api user
    [Parameter(Mandatory=$true)]
    [string]$statusCakeApiKey, # Api key from status cake admin interface
    [Parameter(Mandatory=$false)]
    [int]$checkRate = 300, # Check rate value in seconds
    [Parameter(Mandatory=$false)]
    [string]$testType = "HTTP", # Valid Values are HTTP / TCP / PRICING
    [Parameter(Mandatory=$false)]
    [string]$statusCakeContactGroupId = "113811", # The contact group to send to (currently the slack login group)
    [Parameter(Mandatory=$false)]
    [string]$statusCakeApiRoot = "https://app.statuscake.com", # The api endpoint to call
    [Parameter(Mandatory=$false)]
    [int]$statusCakeConfirmationServers = 2, # The number of confirmation servers to use
    [Parameter(Mandatory=$false)]
    [int]$alertDelayRate = 0, # The length of time before alerts are raised
    [Parameter(Mandatory=$false)]
    [int]$crawlTimeout = 30, # How long to wait before receiving the first byte
    [Parameter(Mandatory=$false)]
    [string]$hostingProvider = "Azure" # The name of the hosting provider as it should appear in Status Cake
)

# Static Variables
$dev = $true # Use this on DFE machines to enable the proxy

$invalidResponseCodes = "204,205,206,303,400,401,403,404,405,406,408,410,413,444,429,494,495,496,499,500,501,502,503,504,505,506,507,508,509,510,511,521,522,523,524,520,598,599" # Comma seperated list of invalid responses

# Functions

function GetTestId{
    $headers = @{
        Username = $statusCakeUserName
        API = $statusCakeApiKey
    }

    $statusCakeApiUrl = "$statusCakeApiRoot/API/Tests"

    if($dev){ # Append the proxy
        $tests = Invoke-RestMethod -Uri $statusCakeApiUrl -Method GET -Headers $headers -Proxy $proxy -ProxyUseDefaultCredentials
    }
    else{
        $tests = Invoke-RestMethod -Uri $statusCakeApiUrl -Method GET -Headers $headers
    }
    
    foreach($test in $tests){
        if(!$test.WebsiteName.Equals($websiteName)){
            continue;
        }

        Write-Host "Found existing test with the name $websiteName, test id is $($test.TestID)."
        return $test.TestID
    }

}

function AddOrUpdateTest{
    param(
        [string]$testId
    )
    $contentType = "application/x-www-form-urlencoded"
    $headers = @{
        Username = $statusCakeUserName
        API = $statusCakeApiKey
    }

    $statusCakeApiUrl = "$statusCakeApiRoot/API/Tests/Update"

    $websiteUrl = "https://$hostDomain$urlToTest" # The url to check

    $data = @{
        TestType=$testType
        ContactGroup = $statusCakeContactGroupId
        WebsiteName=$websiteName
        WebsiteURL=$websiteUrl
        CheckRate=$checkRate
        Confirmation=$statusCakeConfirmationServers
        TriggerRate=$alertDelayRate
        Timeout=$crawlTimeout
        TestTags=$tags
        WebsiteHost=$hostingProvider
        StatusCodes=$invalidResponseCodes

    }
    
    Write-Host "Adding Data:"
    Write-Host "==="

    $postData = ""
    $first = $true

    foreach($key in $data.Keys){
        $dataValue = "$key=$($data[$key])"
        Write-Host "$dataValue"
        if(!$first){
            $postData += "&"
        }

        $first = $false
        $postData += $dataValue
    }

    # if the test id has been found - append it
    if($testId){
        Write-Output "Updating Test Id $testId"
        $postData += "&TestID=$testId"
    }
    if($dev){
        Write-Host $postData
    }

    if($dev){ # Append the proxy
        Invoke-RestMethod -Uri $statusCakeApiUrl -Method PUT -ContentType $contentType -Headers $headers -Body $postData -Proxy $proxy -ProxyUseDefaultCredentials
    }
    else{
        Invoke-RestMethod -Uri $statusCakeApiUrl -Method PUT -ContentType $contentType -Headers $headers -Body $postData
    }
}


# Lets Go!
if($dev){
    $proxy = [System.Net.WebRequest]::GetSystemWebproxy().GetProxy("http://www.statuscake.com")
}
$testId = GetTestId

#Write-Host $testId
AddOrUpdateTest $testId

