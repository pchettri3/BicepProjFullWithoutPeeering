param location string 
param saAccountName string
param tags object


// param storageSuffix string

// var storageAccountname  = '${namingConvention}${storageSuffix}'

@description('creates the number of SA account based on the saindex value specified in the deployment parameter, or default')
resource pcStroageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: saAccountName
  location: location
  tags : tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties:{
    accessTier:'Hot'
    allowBlobPublicAccess:false
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    networkAcls:{
      bypass:'AzureServices'
      defaultAction: 'Deny'
      //ipRules:
    }
  }
}
@description('creates one blob storage account per SA account called and looped from the RG module')
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
 name: 'default'
 parent: pcStroageAccount
  
  properties: {
    restorePolicy:{
      enabled:false
    }
    deleteRetentionPolicy: {
      enabled: true
      days:7
    }
    containerDeleteRetentionPolicy:{
      enabled:true
      days:7
    }
    changeFeed:{
      enabled:true
      retentionInDays:5
    }
    isVersioningEnabled:true
    }

}
@description('creates one File share storage per SA account called and looped from the RG module')
resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent:pcStroageAccount
  name:'default'
    properties: {
shareDeleteRetentionPolicy:{
 enabled:true
  days:7
}
    }
dependsOn:[
  blobService
]
    }
