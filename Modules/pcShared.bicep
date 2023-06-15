param location string
param environment string
param tags object
param namesuffix string
param deploymentMI string = 'resourceDeployMI'
param deploymentsub string = subscription().subscriptionId
param usmiRG string = 'myrg1'
param restrictedNamingPlaceHolder string
param resourceGroupname string = resourceGroup().name
var existingLawName = 'laW${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.logAnalyticsWorkspacePrefix}'
// param resourceNamingPlacHolder string
var enableSS = environment == 'prod'
param aaDate string = utcNow('mm-dd-yy')
var sharedNamePrefixes = loadJsonContent('./Parameters/AzPrefixes.json')
@allowed([
  'AzureActivity'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'ServiceMap'
  'SQLAssesment'
  'AgentHealthAssistant'
  'AntiMalware'
])
@description('Solutions would be added to the log analytics workspace. - DEFAULT VALUE  AgentHealthAssistant,AntiMalware,AzureActivity,ChangeTracking,Security, SecurityInsights,ServiceMap,SQLAssesment,Updates,VMInsights')
param parPcLawSolutions array = [   
'AzureActivity'
'ChangeTracking'
'Security'
'SecurityInsights'
'ServiceMap'
//'AgentHealthAssistant'
//'AntiMalware'
//'SQLAssesment'
//'Updates'
//'VMInsights'
]
// param parPcLawSolutions array TEMP{test}

// 'AgentHealthAssistant'
// 'AntiMalware'

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing =  {
  name: deploymentMI
  scope: resourceGroup(deploymentsub,usmiRG)
}

output identityId string = userAssignedIdentity.id

module inlineScript './Shared/inlinebicep.bicep' = {
  name : 'runPowerShellInlineWithOutput'
   params: {
   resourceGroupName  : resourceGroupname
   resourceName : existingLawName
   location: location
   UserAssignedIdentity: userAssignedIdentity.id
   namesuffix : namesuffix
}
}
output resourceExists bool = inlineScript.outputs.resourceExists
module pcAutomation 'shared/pcAutomation.bicep' =  if (enableSS) {
  name: 'deployauto${aaDate}'
  params: {
    namingConvention: replace(restrictedNamingPlaceHolder, '[PC]',sharedNamePrefixes.parameters.automationAccountPrefix)
    location: location
    tags: tags
  }
}

module pcLaw 'Shared/pcLaw.bicep'= if (enableSS) {
  name: 'deploy-law-${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.logAnalyticsWorkspacePrefix}${namesuffix}'
  params: {
    namingConvention: '${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.logAnalyticsWorkspacePrefix}'
   parPcLawSolutions: parPcLawSolutions
    pcAutoId: pcAutomation.outputs.pcAutomationAccountId
   tag: tags
    location:location
    resourceExists  : inlineScript.outputs.resourceExists
    linkedResourceExists : inlineScript.outputs.linkedResourceExists

   }
  }

module keyVault 'Shared/pcKeyVault.bicep' = if (enableSS) {
  name: 'deploy-kv${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.KeyVault}${namesuffix}'
  params: {
    location: location
    namingConvention: replace(restrictedNamingPlaceHolder, '[PC]',sharedNamePrefixes.parameters.KeyVault) 
    tags: tags
    
    }
  }
module recovery 'Shared/pcRecoveryVault.bicep' = if (enableSS) {
  name: 'deploy-rsv${aaDate}${namesuffix}'
     params: {
    location: location
    tags: tags
    namingConvention: '${restrictedNamingPlaceHolder}${sharedNamePrefixes.parameters.RecoveryServicesvault}'
    namesuffix : namesuffix
  }
}



