param utcValue string = utcNow()
param location string 
param resourceGroupName string 
param resourceName  string
param UserAssignedIdentity string
param namesuffix string
var aaLinkedName = '${resourceName}a${namesuffix}'

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runPowerShellInlineWithOutput'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${UserAssignedIdentity}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '9.0'
        arguments:  '-resourceName ${resourceName} -resourceGroupName  ${resourceGroupName} -aaLinkedName ${aaLinkedName}'
    scriptContent: '''
    
    param(
      [string] $resourceName, 
      [string] $ResourceGroupName,
      [string] $aaLinkedName
         )
         if (Get-AzResource -ResourceName $resourceName -ResourceType 'Microsoft.OperationalInsights/workspaces' -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue | Select-Object -First 1) {
          # Resource found
          $ResourceExists = $true
            }
          else {
              # Resource not found
              $ResourceExists = $false
        
      
      

         Write-Output $ResourceExists
        
         Write-Output $resourceName 
           Write-Host $ResourceExists
           Write-Host  $resourceName 
          }
          
          if (Get-AzResource -ResourceName $aaLinkedName -ResourceType 'Microsoft.OperationalInsights/workspaces/linkedServices' -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue | Select-Object -First 1) {
            # Resource found
            $linkedResourceExists = $true
              }
            else {
                # Resource not found
                $linkedResourceExists = $false
            }    
            Write-Output $linkedResourceExists
            Write-Output $aaLinkedName
     
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['Result'] = $ResourceExists
    $DeploymentScriptOutputs['aalResult'] = $linkedResourceExists
    $DeploymentScriptOutputs['nameOutput'] = $resourceName 
    '''
    
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT2H'
  }
}

output resourceExists bool = runPowerShellInlineWithOutput.properties.outputs.Result
output resourcName string = runPowerShellInlineWithOutput.properties.outputs.nameOutput
output linkedResourceExists bool = runPowerShellInlineWithOutput.properties.outputs.aalResult
