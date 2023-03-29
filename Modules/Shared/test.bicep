
@description('Generated from /subscriptions/d4a23241-7c83-4708-a2ce-c5c15fd80a35/resourceGroups/testrsvpc/providers/Microsoft.RecoveryServices/vaults/rsvepc215')
resource rsvepc 'Microsoft.RecoveryServices/vaults@2023-01-01' = {
  location: 'eastus'
  name: 'rsvepc215'
  etag: 'W/"datetime\'2023-02-15T21%3A19%3A08.9512241Z\'"'
  properties: {
    publicNetworkAccess: 'Enabled'
  }
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
}



@description('Generated from /subscriptions/d4a23241-7c83-4708-a2ce-c5c15fd80a35/resourceGroups/testrsvpc/providers/microsoft.operationalinsights/workspaces/testlawpc')
resource testlawpc 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  properties: {
    source: 'Azure'
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: json('-1.0')
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  name: 'testlawpc'
  location: 'eastus'
  tags: {
  }
}

@description('Generated from /subscriptions/d4a23241-7c83-4708-a2ce-c5c15fd80a35/resourceGroups/sent/providers/microsoft.operationalinsights/workspaces/sentinal')
resource sentinal 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  properties: {
    source: 'Azure'
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: json('-1.0')
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  name: 'sentinal'
  location: 'eastus'
  tags: {
  }
}
