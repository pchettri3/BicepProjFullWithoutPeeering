# connect to the azure account and subscription       47e98099-1e24-4b89-9323-e8523b3451ac
connect-azaccount -Tenant "0878652c-d29e-4662-9fff-bcd7e301ec23"

# get Context and set the context for the deployment    78c12fb7-5330-469d-9200-357d99222056  
$context = get-azsubscription -SubscriptionId "d4a23241-7c83-4708-a2ce-c5c15fd80a35"
set-azcontext $context 
##  "appRoleIndex": { 
 # "saAccountCounts
# prcreaet main resource group if needed
## ### New-AzResourceGroup -name 'rrr' -location 'location' -force

# splat expresssion to assign parameters for deployment 
$Parameters = @{
    Name = "deploymentName"+ (get-date).ToString("yyyyMMddHHmmss")
    TemplateFile = "main.bicep"
    TemplateParameterFile = "./modules/Parameters/parameters-infra-prod.json"
    env = "prod"
    saAccountCounts = 3
    appRoleIndex = 1
    vmCountIndex = 1
    }
New-AzSubscriptionDeployment @parameters -verbose -Location "westus2" 

# ResourceGroupName = "projNeudBaseRg"