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
        ResourceGroupName  = $ResourceGroupName
        CdnProfileName     = $CdnProfileName
        CdnEndpointName = $CdnEndpointName
        CustomDomainName = $CustomDomainName
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
    $GetAzCdnCustomDomain = @{
        ResourceGroupName = $ResourceGroupName
        ProfileName       = $CdnProfileName
        EndpointName      = $CdnEndpointName
    }

    $CdnCustomDomain = Get-AzCdnCustomDomain @GetAzCdnCustomDomain

    if (!$CdnCustomDomain) {
        Write-Verbose "No custom domain configured on CDN endpoint $($CdnEndpointName)"
        Write-Host "##vso[task.complete result=SucceededWithIssues;]DONE"
    }
    else {
        $CustomHttpsState = $CdnCustomDomain.CustomHttpsProvisioningState

        if ($CustomHttpsState -eq "Disabled") {
            $EnableAzCdnCustomDomain = $GetAzCdnCustomDomain

            $EnableAzCdnCustomDomain += @{
                CustomDomainName = $CustomDomainName.Replace('.', '-')
            }

            Write-Verbose "Enabling HTTPS on custom domain $($CustomDomainName)"
            Enable-AzCdnCustomDomainHttps @EnableAzCdnCustomDomain
            Write-Host "##vso[task.complete result=SucceededWithIssues;]DONE"
        }
        else {
            Write-Verbose "HTTPS on custom domain $($CustomDomainName) is $CustomHttpsState"

            if ($CustomHttpsState -eq "Enabling") {
                Write-Verbose "Current substate is $($CdnCustomDomain.CustomHttpsProvisioningSubstate)"
            }
        }
    }
}
catch {
    throw "$_"
}
