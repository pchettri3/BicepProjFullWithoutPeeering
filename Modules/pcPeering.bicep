param localVirtualNetworkid string
param peerName string


resource pcPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: peerName
  properties: {
    
    allowForwardedTraffic: false
    allowGatewayTransit:false
    allowVirtualNetworkAccess:true
    remoteVirtualNetwork:{
      id:localVirtualNetworkid
    }
useRemoteGateways:false
  }
}
