param namingConvention string
param location string
param tag object
param parPcLawSolutions array
param pcAutoId string
param namesuffix string
param resourceExists bool
param linkedResourceExists bool


// main.bicep





//var newResourceName = 'laW${namingConvention}'


//var resourceExists = pcSharedBicep.
/*
 
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-08-01-preview' = if (resourceExists != true) {
  name: 'law${namingConvention}'
  location: location
  sku: {
    name: 'logAnalyticsSku'
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
In this example, the createLogAnalytics boolean variable is set to true by default, but it can be set to false during deployment to indicate that the Log Analytics workspace already exists.

If createLogAnalytics is true, the code creates a new Log Analytics workspace with the given name and SKU. If it's false, the code uses the existing workspace with the given name and returns its ID as output.

Note that the Microsoft.OperationalInsights/workspaces resource type is currently in preview, so it may not be available in all regions. Also, make sure to check the pricing and billing implications of creating new Log Analytics workspaces before using this code in a production environment.







resource logAnalyticsWorkspaceDeployment 'Microsoft.Resources/deployments@2021-04-01' = {
  name: 'logAnalyticsWorkspaceDeployment'
  dependsOn: []
  properties: {
    mode: 'Incremental'
    template: {
      "$schema": "http
*@description('created after import')
*/
resource pclaw 'Microsoft.OperationalInsights/workspaces@2022-10-01' =  if (!resourceExists) {
  properties: {
 //   source: 'Azure'
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
  name: 'laW${namingConvention}'
  location: location
  tags: tag
  
}


@batchSize(1)
@description('la')
resource resPcLawSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [ for solution in parPcLawSolutions: if (!empty(parPcLawSolutions)){ 
  name: '${solution}(${pclaw.name})'
  location: location
  properties: {
    workspaceResourceId: pclaw.id
  }
  plan:{
    name:'${solution}(${pclaw.name})'
    product:'OMSGallery/${solution}'
    publisher:'Microsoft'
    promotionCode:''
  }
}]


param ExistorNot string = linkedResourceExists ? 'existing': 'new'
output linkedExist string = ExistorNot

resource resLawLinkedServiceForAutomationAccount 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = if (ExistorNot == 'new')  {
  name: '${pclaw.name}/Automation'
    properties: {
    resourceId:pcAutoId
  }
}
output pclawid string = pclaw.id
output pclawname string = pclaw.name

