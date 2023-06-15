
connect-azaccount -Tenant "ac"

$context = get-azsubscription -SubscriptionId "9222056"
set-azcontext $context 

$Parameters = @{
    Name = "deploymentName"+ (get-date).ToString("yyyyMMddHHmmss")
    TemplateFile = "main.bicep"
    TemplateParameterFile = "./modules/Parameters/parameters-infra-stg.json"
    env = "stg"
    saAccountCounts = 3
    appRoleIndex = 1
    vmCountIndex = 1
}

New-AzSubscriptionDeployment @parameters -verbose -Location "eastus" 
