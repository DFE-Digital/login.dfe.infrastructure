<#
    .SYNOPSIS
    Add a storage path to an App Service resource

    .DESCRIPTION
    Attaches an Azure Storage account with an existing Container to an App Service.
    It currently only works when all resources (App Service and Storage) are in the same resource group
    and has only been tested against a Linux App Service using a Docker container.

    .PARAMETER ResourceGroupName
    The resouce group containing all the resources

    .PARAMETER AppServiceName
    The App Service to attach the storage to

    .PARAMETER StorageAccountName
    The existing Storage account you one to attach

    .PARAMETER StoragePathName
    The name of this particular storage path

    .PARAMETER ShareName
    The name of the existing Container in the Storage account resource

    .PARAMETER MountPath
    The path we are mounting to with the App Service (e.g. /var/lib/grafana)

    .PARAMETER StoragePathType
    The storage path type either AzureBlob or AzureFiles

    .LINK
    https://docs.microsoft.com/en-us/powershell/module/az.websites/new-azwebappazurestoragepath?view=azps-2.4.0

    .EXAMPLE
    $AddStoragePathParams = @{
        ResourceGroupName  = $resourceGroupName
        AppServiceName     = $appServiceName
        StorageAccountName = $storageAccountName
        StoragePathName = "GrafanaProvisioning"
        ShareName = "provisioning"
        MountPath = "/etc/grafana/provisioning"
    }

    .\Add-WebAppAzureStoragePath.ps1 @AddStoragePathParams

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$AppServiceName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$StoragePathName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$ShareName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$MountPath,
    [Parameter(Mandatory = $false)]
    [ValidateSet("AzureBlob", "AzureFiles")]
    [String]$StoragePathType = "AzureBlob"
)

try {

    # Get Storage Account Key
    $AccountKeyParams = @{
        ResourceGroupName = $ResourceGroupName
        Name              = $StorageAccountName
    }
    $StorageAccountKey = (Get-AzStorageAccountKey @AccountKeyParams).Value[0]

    $NewStoragePathParams = @{
        Name        = $StoragePathName
        AccountName = $StorageAccountName
        Type        = $StoragePathType
        ShareName   = $ShareName
        AccessKey   = $StorageAccountKey
        MountPath   = $MountPath
    }
    $NewStoragePath = New-AzWebAppAzureStoragePath @NewStoragePathParams

    $StoragePathUpdated = $false

    # Get existing storage paths if there are any
    $ExistingStoragePaths = (Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName).AzureStoragePath

    if ($ExistingStoragePaths) {
        $ExistingStoragePaths | ForEach-Object {
            if ($_.Name -eq $StoragePathName) {
                Write-Output "Update existing storage path: $StoragePathName"
                $_.AccountName = $StorageAccountName
                $_.Type = $StoragePathType
                $_.ShareName = $ShareName
                $_.AccessKey = $StorageAccountKey
                $_.MountPath = $MountPath

                $StoragePathUpdated = $true
            }
        }

        if (!$StoragePathUpdated) {
            # Add new storage path
            Write-Output "No matching storage paths, add a new one"
            $UpdatedStoragePaths = $ExistingStoragePaths += $NewStoragePath
        }
    }
    else {
        # Add new storage path
        $UpdatedStoragePaths = $ExistingStoragePaths += $NewStoragePath
    }

    $AppConfig = @{
        ResourceGroup    = $ResourceGroupName
        Name             = $AppServiceName
        AzureStoragePath = $UpdatedStoragePaths
    }

    Set-AzWebApp @AppConfig
}
catch {
    throw "$_"
}
