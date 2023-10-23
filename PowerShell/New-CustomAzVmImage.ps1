function New-PhishingAzVmImage {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$GalleryResourceGroupName, 
        [Parameter(Mandatory = $true)] 
        [string]$GalleryLocation, 
        [Parameter(Mandatory = $true)] 
        [string]$GalleryName,
        [Parameter(Mandatory = $true)] 
        [string]$VmImageSourceResourceGroupName,
        [Parameter(Mandatory = $true)]  
        [string]$VmImageSourceName,
        [Parameter(Mandatory = $false)]
        [switch]$NewImageDefinition,
        [Parameter(Mandatory = $true)] 
        [string]$ImageName,
        [Parameter(Mandatory = $false)] 
        [string]$ImageOfferName, 
        [Parameter(Mandatory = $false)] 
        [string]$ImageCustomSKU,
        [Parameter(Mandatory = $false)] 
        [string]$ImageVersion,
        [Parameter(Mandatory = $false)]
        [switch]$NewGalleryRG      
    )

    try {
        $SourceImageVM = Get-AzVM -ResourceGroupName $VmImageSourceResourceGroupName -Name $VmImageSourceName -ErrorAction Stop
    } catch { Write-Output $_; Write-Host "Failed to locate vm for source image" -ForegroundColor Red; Read-Host "press enter to break"; break }

    if ($NewGalleryRG) {
        try {
            $ResourceGroupCheck = Get-AzResourceGroup
            if ($ResourceGroupCheck.ResourceGroupName -notcontains $GalleryResourceGroupName) {
                New-AzResourceGroup -Name $GalleryResourceGroupName -Location $GalleryLocation -ErrorAction Stop
            }
            New-AzGallery -ResourceGroupName $GalleryResourceGroupName -Name $GalleryName -Location $GalleryLocation -ErrorAction Stop
        } catch { Write-Output $_; Write-Host "Failed to create a new image gallery" -ForegroundColor Red; Read-Host "press enter to break"; break }
    }

    if ($NewImageDefinition) {
        try {
            New-AzGalleryImageDefinition -ResourceGroupName $GalleryResourceGroupName -GalleryName $GalleryName -GalleryImageDefinitionName $ImageName -Publisher MyAzTestPublisher -Offer $ImageOfferName -Sku $ImageCustomSKU -OsType Linux -OsState Specialized -Location $GalleryLocation -HyperVGeneration 'V2' -ErrorAction Stop
        } catch { Write-Output $_; Write-Host "Failed to create a new image definition" -ForegroundColor Red; Read-Host "press enter to break"; break }
    }

    try {
        New-AzGalleryImageVersion -ResourceGroupName $GalleryResourceGroupName -GalleryName $GalleryName -GalleryImageDefinitionName $ImageName -GalleryImageVersionName $ImageVersion -SourceImageId $SourceImageVM.Id.ToString() -Location $GalleryLocation -PublishingProfileEndOfLifeDate '2030-12-01' -ErrorAction Stop
    } catch { Write-Output $_; Write-Host "Failed to create a new image version" -ForegroundColor Red; Read-Host "press enter to break"; break }
}

#execute function
$Splat = @{
    VmImageSourceResourceGroupName = "" # Name of Resource Group where Source VM Resides
    VmImageSourceName = "" # Name of Source VM
    GalleryResourceGroupName = "MyRG"
    GalleryLocation = "eastus"
    GalleryName = "MyGallery"
    ImageName = "" # Image Name
    ImageVersion = "" # Image Version
}

<# Uncomment and add ImageOfferName if you want a new Image Defintion

    $Splat['NewImageDefinition'] = $true
    $Splat['ImageOfferName'] = ""
    $Splat['ImageCustomSKU'] = ( (New-Guid).ToString().split("-")[-1] + ("{0:d3}" -f (Get-Random -Maximum 100 -Minimum 0)) )

#>

<# Uncomment if you want to create a new Resource Group

    $Splat['NewGalleryRG'] = $true
    
#>

New-PhishingAzVmImage @Splat

