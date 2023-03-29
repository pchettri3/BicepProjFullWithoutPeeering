param namesuffix string
param namingConvention string
param location string 
param tags object

resource pcRvault 'Microsoft.RecoveryServices/vaults@2022-10-01' = {
  name: 'rsv-${namingConvention}${namesuffix}'
 tags: tags
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
  }
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
}
