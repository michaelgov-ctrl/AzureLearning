

function New-CustomAzVmImage {


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
        [Parameter(Mandatory = $true)] 
        [string]$ImageName,
        [Parameter(Mandatory = $true)] 
        [string]$ImageOfferName, 
        [Parameter(Mandatory = $true)] 
        [string]$ImageCustomSKU,
        [Parameter(Mandatory = $true)] 
        [string]$ImageVersion,
        [Parameter(Mandatory = $false)]
        [switch]$NewGalleryRG
    )

    try {
        $SourceImageVM = Get-AzVM -ResourceGroupName $VmImageSourceResourceGroupName -Name $VmImageSourceName -ErrorAction Stop
    } catch { Write-Output $_; Write-Host "Failed to locate vm for source image" -ForegroundColor Red; Read-Host "press enter to break"; break }

    if ($NewGalleryRG) {
        try {
            New-AzResourceGroup -Name $GalleryResourceGroupName -Location $GalleryLocation -ErrorAction Stop
            New-AzGallery -ResourceGroupName $GalleryResourceGroupName -Name $GalleryName -Location $GalleryLocation -ErrorAction Stop
        } catch { Write-Output $_; Write-Host "Failed to create new resource group" -ForegroundColor Red; Read-Host "press enter to break"; break }
    }

    try {
        New-AzGalleryImageDefinition -ResourceGroupName $GalleryResourceGroupName -GalleryName $GalleryName -GalleryImageDefinitionName $ImageName -Publisher MyAzTesting -Offer $ImageOfferName -Sku $ImageCustomSKU -OsType Linux -OsState Specialized -Location $GalleryLocation -HyperVGeneration 'V2' -ErrorAction Stop
        New-AzGalleryImageVersion -ResourceGroupName $GalleryResourceGroupName -GalleryName $GalleryName -GalleryImageDefinitionName $ImageName -GalleryImageVersionName $ImageVersion -SourceImageId $SourceImageVM.Id.ToString() -Location $GalleryLocation -PublishingProfileEndOfLifeDate '2030-12-01' -ErrorAction Stop
    } catch { Write-Output $_; Write-Host "Failed to create new image" -ForegroundColor Red; Read-Host "press enter to break"; break }

}




$splat = @{
    #NewGalleryRG = $true
    GalleryResourceGroupName = "test-gallery-rg"
    GalleryLocation = "eastus"
    GalleryName = "mycustomgallery"
    VmImageSourceResourceGroupName = "test-debian-rg"
    VmImageSourceName = "ricktacular-spectacular-vm"
    ImageName = "CustomDebianPwshImage"
    ImageOfferName = "DebianPwsh"
    ImageCustomSku = ( (New-Guid).ToString().split("-")[-1] + ("{0:d3}" -f (Get-Random -Maximum 100 -Minimum 0)) )
    ImageVersion = "1.0.0"
}

New-CustomAzVmImage @splat

