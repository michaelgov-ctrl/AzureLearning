$resourceGroupName = Read-Host "Enter the Resource Group name"
$location = Read-Host "Enter the location (i.e. centralus)"
$projectName = Read-Host "Enter the project name (used for generating resource names)"
$username = Read-Host "Enter the administrator username"
$key = Read-Host "Enter the SSH public key"

New-AzResourceGroup -Name $resourceGroupName -Location $location
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri "https://raw.githubusercontent.com/michaelgov-ctrl/AzureLearning/main/ARMTemplates/DebianVM/azuredeploy.json" -projectName $projectName -location $location -adminUsername $username -adminPublicKey $key
Get-AzVM -ResourceGroupName $resourceGroupName -Name ($projectName + "-vm")
