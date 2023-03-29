param namingConvention string
param location string
param tags object



resource pcAutoAccount 'Microsoft.Automation/automationAccounts@2022-08-08' ={
   name: 'aa${namingConvention}'
  location: location
  tags: tags
  identity: {
    type:'SystemAssigned'
  }
  properties:{
    sku:{
      name:'Basic'
    }
    publicNetworkAccess:false
  }
}

output pcAutomationAccountId string = pcAutoAccount.id
output pcAutomationAccountName string = pcAutoAccount.name
