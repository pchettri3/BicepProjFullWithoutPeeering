# connect to the azure account and subscription     0878652c-d29e-4662-9fff-bcd7e301ec23
Set-Location -path "C:\Lab\RegProjectBicepFull\BicepProjFullWithoutPeeering"
connect-azaccount -Tenant "0878652c-d29e-4662-9fff-bcd7e301ec23"

# get Context and set the context for the deployment      d4a23241-7c83-4708-a2ce-c5c15fd80a35
$context = get-azsubscription -SubscriptionId "d4a23241-7c83-4708-a2ce-c5c15fd80a35"
set-azcontext $context 
<#  "appRoleIndex": { 
 ---"saAccountCounts
--- pre-create main resource group if needed
--- New-AzResourceGroup -name 'rrr' -location 'location' -force

--- splat expresssion to assign parameters for deployment 
#>
$Parameters = @{
    Name = "deploymentName"+ (get-date).ToString("yyyyMMddHHmmss")
    TemplateFile = "main.bicep"
    TemplateParameterFile = "./modules/Parameters/parameters-infra-dev.json"
    env = "dev"
    saAccountCounts = 1
    appRoleIndex = 1
    vmCountIndex = 1
    Email = "pcinfra@xxx.com"
    CostCenter = "1234"
    Owner = "Infrastructure Team"
    

}




New-AzSubscriptionDeployment @parameters -verbose -Location "eastus"

# ResourceGroupName = "projNeudBaseRg"
# New-AzResourceGroupDeployment @Parameters -Verbose -R