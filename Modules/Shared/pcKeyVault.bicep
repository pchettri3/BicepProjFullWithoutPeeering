param namingConvention string
param location string
param tags object

param pcAccessPolicy array =[]
param pcNetworkAcls object = {
  defaultAction: 'deny'
  bypass: 'AzureServices'
  IpRules:[]
  virtualNetworkRules: []
}

resource pcKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv${namingConvention}'
  location: location
  tags: tags
  properties: {
    enabledForDeployment:true
    enabledForTemplateDeployment:true
    enabledForDiskEncryption:true
    enableRbacAuthorization:false
    accessPolicies:pcAccessPolicy
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    networkAcls:pcNetworkAcls
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
  }
}
