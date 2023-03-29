targetScope = 'subscription'


// var resourceNamePrefix = loadJsonContent('./Parameters/AzPrefixes.json'.json')
param tags object
//param NetworkNamePrefix string
//param addressPrefixes array 
//param subnets array
param virtualNetworks array
param vmCountIndex int 
//param vnet int
param adminUsername string
param restrictedNamingPlaceHolder string
@secure()
param adminPassword string 
// param environment string
param dnsServers array 
// param snetlength int
// param index int
param resourceNamingPlacHolder string
//param deploymentdate string= utcNow('yyyy-MM-dd')
param location string
param demoRgName string
param environment string 
// param vnetID string
// param coreRgName string = ''
// param coreVnetname string = ''
param saNamingPrefix string
// param vnetNamingPrefix string
// param sharedNamePrefixes string
param saAccountCounts int

//param addressPrefix string
var resourceNamePrefix =  loadJsonContent('./Parameters/AzPrefixes.json')
// var deployResource = environment !='core'

// var core = contains(namingConvention, 'core')? true : false


//var vnetNameprefix = replace(resourceNamingPlacHolder,'[PC]', resourceNamePrefix.parameters.virtualnetworkPrefix)
var nsgNamingPlaceHolder = replace(resourceNamingPlacHolder,'[PC]', resourceNamePrefix.parameters.NetworSecurityGroup)
// var snetNamingPlaceholder = replace(resourceNamingPlacHolder, '[PC]',resourceNamePrefix.parameters.subNetPrefix)
var vmNamePrefix = take(replace(resourceNamingPlacHolder,'[PC]', resourceNamePrefix.parameters.virtualmachinePrefix),12)

resource pcResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'Deploy-${demoRgName}-main01'
  location: location
  tags:tags
}
@description('Creates number of storage account specified during deployment')
module StorageAccount './pcStorageAccount.bicep' = [ for i in range(0, saAccountCounts): { //if(deployResource) {
 scope: pcResourceGroup
name: 'depoy-${saNamingPrefix}deploymentdate${i}'


params:{
  location: location
  saAccountName: '${saNamingPrefix}psa0${i}'
  tags: tags
}
}]



 module pcVirtualNetwork './pcVirtualNetwork.bicep' = [ for vnet in virtualNetworks: {
  scope: pcResourceGroup
  
  name: vnet.name//'${vnet}.${NetworkNamePrefix}01'
 params: {
  //NetworkNamePrefix: NetworkNamePrefix
  virtualNetworks: virtualNetworks //added
  vnet : vnet
// addressPrefixes : 
addressPrefixes: vnet.addressPrefixes
location: location
  tags: tags
//environment: environment
 nsgNamePrefix: nsgNamingPlaceHolder
 // snetName: snetNamePrefix  
  
//subNets: vnet.subNets
 dnsServers: dnsServers

 subNets: [ for subnet in vnet.subnets: {
  name : subnet.name      
  addressPrefix: subnet.addressPrefix
 
  
  } ] 
} 
} ]

//var vnetlen = length(virtualNetworks)

//var allnet = pcVirtualNetwork[virtualNetworks.count()].outputs.subnetsall[0]

var resourcegId = pcResourceGroup.id


//var coreSubnetId = '${resourcegId}/providers/Microsoft.Network/virtualNetworks/${hubVnet}/subnets/CoreSubnet'
var vnetResourcePrefix = '${resourcegId}/providers/Microsoft.Network/virtualNetworks/'
/*
///subscriptions/d4a23241-7c83-4708-a2ce-c5c15fd80a35/resourceGroups/RG-ADDS/providers/Microsoft.Network/virtualNetworks/it-dev-vnet/subnets/it-dev-subnet
var coreSubnet = pcVirtualNetwork[0].outputs.subnetsall[0]
var coreToolSubnet  = pcVirtualNetwork[0].outputs.subnetsall[1]
var  coreDsSubnet  = pcVirtualNetwork[0].outputs.subnetsall[2]

var appSubnet = pcVirtualNetwork[1].outputs.subnetsall[0]
var appToolSubnet  = pcVirtualNetwork[1].outputs.subnetsall[1]
var appMonSubnet  = pcVirtualNetwork[1].outputs.subnetsall[2]

var dbSubnet  = pcVirtualNetwork[1].outputs.subnetsall[0]
var dbToolSubnet  = pcVirtualNetwork[1].outputs.subnetsall[1]

var wvdSubnet  = pcVirtualNetwork[1].outputs.subnetsall[0]
var wvdToolSubnet  = pcVirtualNetwork[1].outputs.subnetsall[1]


var ouputNetworkObjects = {
 
  coreSubnetName : coreSubnet[0].name
  coresubnetAddressPrefix : coreSubnet[0].addressPrefix
  coreToolSubnetName : coreToolSubnet[1].name
  coreToolSubnetAddressPrefix : coreToolSubnet[1].addressPrefix
  coreDsSubnetName : coreDsSubnet[2].name
  coreDsSubnetAddressPrefix : coreDsSubnet[2].addressPrefix

  appSubnetName : appSubnet[0].name
  appSubnetAddressPrefix : appSubnet[0].addressPrefix
  appToolSubnetName : appToolSubnet[1].name
  appToolSubnetAddressPrefix : appToolSubnet[1].addressPrefix
  appMonSubnetName : appMonSubnet[2].name
  appMonSubnetAddressPrefix : appMonSubnet[2].addressPrefix

  dbSubnetName : dbSubnet[0].name
  dbSubnetAddressPrefix : dbSubnet[0].addressPrefix
  dbToolSubnetName : dbToolSubnet[1].name
  dbToolSubnetAddressPrefix : appToolSubnet[1].addressPrefix

  wvdSubnetName : wvdSubnet[0].name
  wvdSubnetAddressPrefix : wvdSubnet[0].addressPrefix
  wvdToolSubnetName : wvdToolSubnet[1].name
  wvdToolSubnetAddressPrefix : wvdToolSubnet[1].addressPrefix
}
*/
var CoreVnetId  = '${vnetResourcePrefix}${pcVirtualNetwork[0].name}/subnets/' 

output CoreSubnetName string =  pcVirtualNetwork[0].outputs.subnetsall[0].name //pcVirtualNetwork[0].outputs.subnetsall[0][0].name
//output outputcnetname  string = virtualNetworks::outputs.subnetsall[0][0].name
output CoreSubnetId string =   '${CoreVnetId}${pcVirtualNetwork[0].outputs.subnetsall[0].name}'//'${CoreVnetId}${pcVirtualNetwork[0].outputs.subnetsall[0][0].name}'

var wvdSubnetID  = '${vnetResourcePrefix}${pcVirtualNetwork[2].name}/subnets/'
output wvdVarSubnetID string = wvdSubnetID
///output parsnetone array = pcVirtualNetwork[0].outputs.subnetsall[0]
output parvnet string = pcVirtualNetwork[2].name

/*param custommtags object = {
  createdBy: '${wvdSubnetID}-tag'  //if az cli then it is deployed from the pipeline 
  environment: '${wvdSubnetID}-tag'
  deploymentDate: currentDate
  product: appRoleName
 }
*/
module VMresource 'pcVirtualMachine.bicep' = [for i in range(0,vmCountIndex): {
scope: pcResourceGroup
 name: '${vmNamePrefix}${i}'

  params: {
    location: location
        tags : wvdSubnetID
     pcnamingConvention: 'vm${restrictedNamingPlaceHolder}${i}'
    

    environmentType: environment
    adminUsername: adminUsername
    adminPassword: adminPassword

  coreSubnetName : pcVirtualNetwork[0].outputs.subnetsall[0].name // pcVirtualNetwork[0].outputs.subnetsall[0][0].name

    coreSubnetID:'${CoreVnetId}${pcVirtualNetwork[0].outputs.subnetsall[0].name}' 

   OSdiskname : '${restrictedNamingPlaceHolder}disk${i}'
   datadiskname:  '${restrictedNamingPlaceHolder}datDisk${i}'

  }
  
}] 
//output coreVnetName string = pcVirtualNetwork.outputs.virtualNetworkName
output coreRgname string = pcResourceGroup.name
