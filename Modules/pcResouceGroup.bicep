targetScope = 'subscription'

param tags object
param virtualNetworks array
param vmCountIndex int 
param adminUsername string
param restrictedNamingPlaceHolder string
@secure()
param adminPassword string 
param dnsServers array 
param resourceNamingPlacHolder string
param location string
param demoRgName string
param environment string 
param saNamingPrefix string
param saAccountCounts int

@description('passes through all JSON contect and assigns to a variable')
var resourceNamePrefix =  loadJsonContent('./Parameters/AzPrefixes.json')
//Replacing placeholder intial with the correct service name 
var nsgNamingPlaceHolder = replace(resourceNamingPlacHolder,'[PC]', resourceNamePrefix.parameters.NetworSecurityGroup)
var vmNamePrefix = take(replace(resourceNamingPlacHolder,'[PC]', resourceNamePrefix.parameters.virtualmachinePrefix),12)

resource pcResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'RG-${demoRgName}-main01'
  location: location
  tags:tags
}
@description('Creates number of storage account specified during deployment')
module StorageAccount './pcStorageAccount.bicep' = [ for i in range(0, saAccountCounts): { 
 scope: pcResourceGroup
name: 'depoy-${saNamingPrefix}deploymentdate${i}'


params:{
  location: location
  saAccountName:  replace(saNamingPrefix,'PC', resourceNamePrefix.parameters.storageAccountPrefix)
  tags: tags
}
}]


@description('virtual network module passes required parameter to generate resoure for vnets and subnets inside respecitve vent')
 module pcVirtualNetwork './pcVirtualNetwork.bicep' = [ for vnet in virtualNetworks: {
  scope: pcResourceGroup
  
  name: vnet.name
 params: {
   virtualNetworks: virtualNetworks 
  vnet : vnet
addressPrefixes: vnet.addressPrefixes
location: location
  tags: tags
 nsgNamePrefix: nsgNamingPlaceHolder
 dnsServers: dnsServers

 subNets: [ for subnet in vnet.subnets: {
  name : subnet.name      
  addressPrefix: subnet.addressPrefix
 
  
  } ] 
} 
} ]


var resourcegId = pcResourceGroup.id

var hubVnetId  = '${vnetResourcePrefix}${pcVirtualNetwork[0].name}/subnets/' 
var appVnetId  = '${vnetResourcePrefix}${pcVirtualNetwork[1].name}/subnets/' 
var dbVnetId  = '${vnetResourcePrefix}${pcVirtualNetwork[2].name}/subnets/' 
var wvdVnetId  = '${vnetResourcePrefix}${pcVirtualNetwork[3].name}/subnets/' 

var vnetResourcePrefix = '${resourcegId}/providers/Microsoft.Network/virtualNetworks/'

var managementSubnetName = pcVirtualNetwork[0].outputs.subnetsall[0].name
var managementSubnetID = '${hubVnetId}${managementSubnetName}'
var SharedSubnetName = pcVirtualNetwork[0].outputs.subnetsall[1].name
var SharedSubnetId = '${hubVnetId}${SharedSubnetName}'
var dmzSubnetName = pcVirtualNetwork[0].outputs.subnetsall[2].name
var dmzSubnetId = '${hubVnetId}${dmzSubnetName}'
var gatewaySubnetName = pcVirtualNetwork[0].outputs.subnetsall[2].name
var gatewaySubneId = '${hubVnetId}${gatewaySubnetName}'

var appSubnetName = pcVirtualNetwork[1].outputs.subnetsall[0].name
var appSubnetId = '${appVnetId}${appSubnetName}'
var appToolSubnetName = pcVirtualNetwork[1].outputs.subnetsall[1].name
var appToolSubnetId = '${appVnetId}${appToolSubnetName}'
var appDSSubnetName = pcVirtualNetwork[0].outputs.subnetsall[2].name
var appDsSubnetId = '${appVnetId}${appDSSubnetName}'

var dbSubnetName = pcVirtualNetwork[2].outputs.subnetsall[0].name
var dbSubnetId = '${dbVnetId}${dbSubnetName}'
var dbToolSubnetName = pcVirtualNetwork[2].outputs.subnetsall[1].name
var dbToolSubnetId = '${dbVnetId}${dbToolSubnetName}'

var wvdSubnetName = pcVirtualNetwork[3].outputs.subnetsall[0].name
var wvdSubnetId = '${wvdVnetId}${wvdSubnetName}'
var wvdToolSubnetName = pcVirtualNetwork[3].outputs.subnetsall[1].name
var wvdToolSubnetId = '${wvdVnetId}${wvdToolSubnetName}'




var ouputNetworkObjects = {
 
  managementSubnetName : managementSubnetName
  managementSubnetID : managementSubnetID

  SharedSubnetName : SharedSubnetName
  SharedSubnetId : SharedSubnetId
  dmzSubnetName : dmzSubnetName
  dmzSubnetId : dmzSubnetId
  gatewaySubnetName : gatewaySubnetName
  gatewaySubneId : gatewaySubneId

  appDsSubnetName : appSubnetName
  appDsSubnetId : appSubnetId

  appToolSubnetName : appToolSubnetName
  appToolSubnetId : appToolSubnetId

  appMonSubnetName : appDSSubnetName
  appMonSubnetId : appDsSubnetId

  dbSubnetName : dbSubnetName
  dbSubnetId :dbSubnetId

  dbToolSubnetName : dbToolSubnetName
  dbToolSubnetId : dbToolSubnetId

  wvdSubnetName : wvdSubnetId
  wvdSubnetId : wvdSubnetId

  wvdToolSubnetName : wvdToolSubnetName
  wvdToolSubnetId : wvdToolSubnetId
}

var wvdtags = ouputNetworkObjects.wvdSubnetId

module VMresource 'pcVirtualMachine.bicep' = [for i in range(0,vmCountIndex): {
scope: pcResourceGroup
 name: '${vmNamePrefix}${i}'

  params: {
    location: location
        tags : wvdtags
     pcnamingConvention: 'vm${restrictedNamingPlaceHolder}${i}'
    

    environmentType: environment
    adminUsername: adminUsername
    adminPassword: adminPassword

    coreSubnetName :   managementSubnetName //alternate option pcVirtualNetwork[0].outputs.subnetsall[0].name  // pcVirtualNetwork[0].outputs.subnetsall[0].name
    coreSubnetID: managementSubnetID // aternate option ${hubVnetId}${pcVirtualNetwork[0].outputs.subnetsall[0].name}'
    
       OSdiskname : '${restrictedNamingPlaceHolder}disk${i}'
       datadiskname:  '${restrictedNamingPlaceHolder}datDisk${i}'
    
      }
      
    }] 
  
output coreRgname string = pcResourceGroup.name
