


param nsgNamePrefix string 
param vnet object = virtualNetworks[0]
param virtualNetworks array ///added the param on 3/26/23 
param dnsServers array
param subNets array 
param suball array

@description('load the content of of JSON parameter file to the variable')
var nsgSecurityRules  = json(loadTextContent('../Parameters/nsg-rules.json')).securityRules


@description('creates NSG # of NSG rules based on the number of blocks created on the NSG param file/JSON varaiable')
resource pcnsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = if (  != 'GatewaySubnet' ? nsgSecurityRules : null) {
  name: nsgNamePrefix
  properties: {
    securityRules: nsgSecurityRules
  }
}
  