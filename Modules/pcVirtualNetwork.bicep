
@description('Tags to be applied to resources')
param tags object
@description('Azure location where resources are deployed')
param location string 
@description('VNET address prefixes')
param addressPrefixes  array 
param nsgNamePrefix string 
param vnet object = virtualNetworks[0]
param virtualNetworks array ///added the param on 3/26/23 
param dnsServers array
param subNets array 
//var subnetLength = length(subNets)

// param virtualNetworks array

// param nsgSecurityRules object

// param snetLength int

// param virtualNetworkPeerings array = []

// var nsgSecurityRules = loadJsonContent('./Parameters/nsg-rules.json').securityRules  ***MESSED UP DUE .securityRules****
@description('load the content of of JSON parameter file to the variable')
var nsgSecurityRules  = json(loadTextContent('./Parameters/nsg-rules.json')).securityRules
var dnsServersvar  = {
dnsServers: array(dnsServers)
}

@description('creates NSG # of NSG rules based on the number of blocks created on the NSG param file/JSON varaiable')
resource pcnsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgNamePrefix
  location: location
  properties: {
    securityRules: nsgSecurityRules
  }
  
}
@description('creates vNet and subnets based the # block defined on the parameter file ')

resource pcVnet 'Microsoft.Network/virtualNetworks@2022-07-01' = { //[ for (vnet,idx) in virtualNetworks: {  //it was without loop on 2/26/23
  name: vnet.name //'${vnet}.${NetworkNamePrefix}01'
  location: location
  tags: tags
  properties: {
    
   addressSpace: {
    addressPrefixes: addressPrefixes
   }
   
  dhcpOptions: !empty(dnsServers) ? dnsServersvar  : null 
   // ternary  If the dnsServers variable is not empty, the value of the dnsServers_var variable is assigned to the dhcpOptions field.
   subnets: [for subnet in vnet.subNets: {
       name : subnet.name //'${subnet.name}${environment}' //'${snetNamePrefix}${subnet.name}' //'${subNetName}-${subnet.name}'
  properties: {
    addressPrefix: subnet.addressPrefix //subnet.addressPrefix
        //Assigns private serviceEndpoints if the subnet serviceEndpoints states enabled or else null
  serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
  delegations: contains(subnet, 'delegation') ? subnet.delegation : []
    networkSecurityGroup: {
      id: pcnsg.id
    location: location
    }
   //Assigns private endpoint pol if the subnet privateEndpointNetworkPolicies states enabled or else null
   privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
   privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
           
  }
          } ]

//        }
    
      }//]
    }


output subnetsall array = [for subnet in  vnet.subNets: subnet] // [for subnet in subNets: vnet.subnets]
//output loopsubnet array = vnet.subnets

/*      
module peerToCore 'pcPeering.bicep' = if (peertoCore) {
  name: 'Peer-to-Core'
  params: {
    localVirtualNetworkid : pcVirtualNetwork.id
    peerName: '${pcVirtualNetwork}peer-to-core'
  }
  }

// Remote to local peering (reverse)
module peerToSpoke 'pcPeering.bicep' =  if(peertoScope) {
  scope:resourceGroup(coreRgName)
  name: 'Core-to-Peer'
  params: {
    localVirtualNetworkid : pcVirtualNetwork.id
    peerName: '${pcVirtualNetwork}Core-to-Peer'
  }
  }
*/
