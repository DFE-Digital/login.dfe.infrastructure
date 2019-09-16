<#
    .SYNOPSIS
    Enable HTTPS for a custom domain on a CDN endpoint. This will use the CDN managed certificate.

    .DESCRIPTION
    Enables a CDN managed HTTPS certificate on the custom domain on the specified CDN profile and endpoint

    .PARAMETER ResourceGroupName
    The resouce group containing all the resources

    .PARAMETER CdnProfileName
    The App Service to attach the storage to

    .PARAMETER CdnEndpointName
    The existing Storage account you one to attach

    .PARAMETER CustomDomainName
    The name of this particular storage path

    .EXAMPLE
    $EnableCdnCustomDomainHttps = @{
        ResourceGroupName  = $resourceGroupName
        CdnProfileName     = $appServiceName
        CdnEndpointName = $storageAccountName
        CustomDomainName = "GrafanaProvisioning"
    }

    .\Enable-CdnCustomDomainHttps.ps1 @EnableCdnCustomDomainHttps -Verbose
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$CdnProfileName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$CdnEndpointName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$CustomDomainName
)

try {
    $GetAzureRmCdnCustomDomain = @{
        ResourceGroupName = $ResourceGroupName
        ProfileName       = $CdnProfileName
        EndpointName      = $CdnEndpointName
    }

    $CustomHttpsState = (Get-AzureRmCdnCustomDomain @GetAzureRmCdnCustomDomain -ErrorAction SilentlyContinue).customHttpsProvisioningState

    if (!$customHttpsState) {
        Write-Verbose "Domain $($CustomDomainName) not configured on CDN endpoint $($CdnEndpointName)"
        Write-Host "##vso[task.complete result=SucceededWithIssues;]DONE"
    }
    elseif ($CustomHttpsState -eq "Disabled") {
        $EnableAzureRmCdnCustomDomain = $GetAzureRmCdnCustomDomain

        $EnableAzureRmCdnCustomDomain += @{
            CustomDomainName = $CustomDomainName.Replace('.', '-')
        }

        Write-Verbose "Enabling HTTPS on custom domain $($CustomDomainName)"
        Enable-AzureRmCdnCustomDomain @EnableAzureRmCdnCustomDomain
        Write-Host "##vso[task.complete result=SucceededWithIssues;]DONE"
    }
    else {
        Write-Verbose "HTTPS on custom domain $($CustomDomainName) is $CustomHttpsState"
    }
}
catch {
    throw "$_"
}
