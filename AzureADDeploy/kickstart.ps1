﻿Import-Module Azure
Import-Module AzureRM


Param(
  [string]$adminPassword,
  [string]$userPassword
)

function Get-RandomString ($length) {
  $set    = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
  $result = ""
  for ($x = 0; $x -lt $Length; $x++) {
    $result += $set | Get-Random
  }
  return $result
}

$URI  = 'https://raw.githubusercontent.com/jaredhaight/AzureADLab/master/AzureADLab/azuredeploy.json'
$_artifactsLocation = "https://raw.githubusercontent.com/jaredhaight/AzureADLab/master/AzureADLab/"
$location  = 'eastus2'
$locationName = "East US"
$resourceGroupName    = 'evil.training'
$studentCode = "a" + (Get-RandomString 6)
$adminUserName = "EvilAdmin"
$domainName = "ad.evil.training"
$dnsPrefix = $studentCode
$storageAccountName = $studentCode+"storage"    # Lowercase required
$adVMName = $studentCode+"-dc01"
$adAvailabilitySetName = $studentCode+"AvailSet"
$adNicName = $studentCode + "nic"
$adNicIPAddress = "10.0.0.4"
$adSubnetName = $studentCode+"subnet"
$adSubnetAddressPrefix = "10.0.0.0/24"
$virtualNetworkName = $studentCode+"vnet"
$virtualNetworkAddressRange = "10.0.0.0/16"
$publicIPAddressName = $studentCode+"pip"

# Check that the public dns $addnsName is available
try {
  if (Test-AzureRmDnsAvailability -DomainNameLabel $dnsPrefix -Location $location)
  { 
    'Available' 
  } 
  else 
  { 
    'Taken. addnsName must be globally unique.' 
    break
  }
}
catch {
  Login-AzureRmAccount
  if (Test-AzureRmDnsAvailability -DomainNameLabel $dnsPrefix -Location $location)
  { 
    'Available' 
  } 
  else 
  { 
    'Taken. addnsName must be globally unique.' 
    break
  }
}

# Create the new resource group. Runs quickly.
try {
  Get-AzureRmResourceGroup -Name $resourceGroupName -Location $location -ErrorAction Stop
}
catch {
  New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}

# Parameters for the template and configuration
$MyParams = @{
  adminUsername               = $adminUserName
  adminPassword               = $adminPasswordPlainText
  domainName                  = $domainName
  dnsPrefix                   = $dnsPrefix
  virtualNetworkName          = $virtualNetworkName
  storageAccountName          = $storageAccountName
  adNicName                   = $adNicName
  adNicIpAddress              = $adNicIPAddress
  adVMName                    = $adVMName
  adSubnetName                = $adSubnetName
  publicIPAddressName         = $publicIPAddressName
  adAvailabilitySetname       = $adAvailabilitySetName
  virtualNetworkAddressRange  = $virtualNetworkAddressRange
  adSubnetAddressPrefix       = $adSubnetAddressPrefix
  _artifactsLocation          = $_artifactsLocation
}

# Splat the parameters on New-AzureRmResourceGroupDeployment  
$SplatParams = @{
  TemplateUri             = $URI 
  ResourceGroupName       = $resourceGroupName 
  TemplateParameterObject = $MyParams
  Name                    = 'EVILTraining'
}

# This takes ~30 minutes
# One prompt for the domain admin password
New-AzureRmResourceGroupDeployment @SplatParams -Verbose