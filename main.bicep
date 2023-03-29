// look into template specs
// git hub actions 

targetScope = 'subscription'
@description('Location name based on the current deployment location')
param location string = deployment().location
// param parPcLawSolutions array    TEM{TEST}
@description('LocationList provides the index to location to choose only number as paramber as location name grows in the parameer file')
param locationList object
@description('Deparment name that gets passed from parameter file during the deployment')
param department string
@description('Allows to chose the number of storage account at the deployment time')
param saAccountCounts int 
// param vmCount int 
@description('Envrionment name that helps to correct sizing and resources for different env during deployment ')
param env string = 'dev'
@description('An index to chose to correct application type and correct appShortname during deployment')
param appRoleIndex int
@description('Assigns correct appRole based on appindex to generate correct naming conv')
param appRole array
@description('Data paramter that gets passed along to modules')
param currentDate string = utcNow('yyyy-MM-dd')
@description('DNS server IPs that gets passed from deployment param file to main and remaining reosurce modules')
param dnsServers array
@description('vnet address prefxes that gets passed from deployment param file to main and remaining reosurce modules')
//param addressPrefixes array
param virtualNetworks array
//@description('subnets array that gets passed from deployment param file to main and remaining reosurce modules')
//param subNets array
// param snetLength int = length(subnets)
@description('generates applicatoin shortname to be applied to namingConv module')
param appShortName string = appRole[appRoleIndex].Shortname
@description('generates appRolename  to be applied to namingConv module')
param appRoleName string = appRole[appRoleIndex].Name

//param vnet int
// param addressPrefix string
param vmCountIndex int
//@Description ('importing azprefixes json file contect to a vaiable in the current module') 
param adminUsername string
@secure()
param adminPassword string
var locationShortName = locationList[location]
@description('Command to parse through AzPrefixes which hold Microsoft recommended service naming prefixes')
var sharedNamePrefixes = loadJsonContent('./Modules/Parameters/AzPrefixes.json')


// Meaningful vairable generation that is applied with the if statement for Enabling shared services.
var EnableSSResouce  = env == 'prod'




 @description('Resouce tag that would be passed for other resouce modules')
param tagValues object = {
  createdBy: 'prasant.chettri@xxxx.com'  //if az cli then it is deployed from the pipeline 
  environment: env
  deploymentDate: currentDate
  product: appRoleName
 }

 @description('Existing resource called to build the naming prefix before any other resource gets deployed')
resource coreResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01'= { // existing = {
  name: 'neuCoreRG01'
 location: location
  }
  @description('Output valude of the base RG')
output coreRG string = coreResourceGroup.id

@description('NamingConvention MODULE BLOCK')
module namingConvention './modules/namingConvention.bicep' = {
 name: '${env}-deployNaming'
 scope: coreResourceGroup
 params: {
   department: department
   environment: env
   // appRoleName: appRole[1].Name
   appRoleShortName: appShortName
   // location : locationList[locationIndex].location  *** no need for location as location shortname is used to generate name
   locationShortName: locationShortName// 0 west2, 1 east, 2 westus, 3 central, 4 west3
   }
}


output storageAccountname string = namingConvention.outputs.outputObjects.saAccountNamePlaceHolder



@description('same as currentdate param')
param deploymentdate string= utcNow('yyyy-MM-dd')
// param deploymentsuffix string = '${environment[0]}${locationList[locationIndex].location}${deploymentdate}'
@description('Deployment suffix value to suffix to deployment variabe in module if the module does not accept long value for name convention')
param deploymentsuffix string = '${env}${deploymentdate}'
// namesModule.outputs.outputobject.outputvariable1

@description('RG deployment module')
module demoResouceGroup 'Modules/pcResouceGroup.bicep' = {
  name: 'RGDeployment-${deploymentsuffix}' 
                                    
  params:{    
    //index : locationIndex
   // locationlist: locationList[locationIndex].shortname
    location : location 
    
    // addressPrefix:addressPrefixes[0]
       // namingConvention: '${localNamingRG}-core[0]'
       
     // replacing the resource name place holder with the RG group prefix
    demoRgName : 'demoRG-${replace(namingConvention.outputs.outputObjects.resourceNamePlaceHolder,'[PC]',sharedNamePrefixes.parameters.resourceGroupPrefix)}' // cannot be the value in the primary block the variable has not been generated
    saNamingPrefix: namingConvention.outputs.outputObjects.saAccountNamePlaceHolder
    tags: tagValues
    virtualNetworks: virtualNetworks
    //addressPrefixes: addressPrefixes
    dnsServers: dnsServers
    //subNets : subNets
    //vnet : vnet
    environment: env
    saAccountCounts : saAccountCounts  
    resourceNamingPlacHolder: namingConvention.outputs.outputObjects.resourceNamePlaceHolder
    // replacing the subnet place holder with the subnet prefix
    //NetworkNamePrefix :  namingConvention.outputs.outputObjects.restrictedNamePlaceholder
    // coreRgName: coreResourceGroup.id
    restrictedNamingPlaceHolder : namingConvention.outputs.outputObjects.restrictedNamePlaceholder
    
  vmCountIndex : vmCountIndex
    // snetLength : snetLength (planning to apply loop based on subnet array length when the code expands)
    //environment : env
   adminUsername: adminUsername
    adminPassword: adminPassword

  }
 } 

@description('module to create shared resources')
module sharedModule 'Modules/pcShared.bicep' = if(EnableSSResouce) {
  scope: coreResourceGroup
  name: 'Shared-${deploymentsuffix}'
  params: {
    location: location
   // resourceNamingPlacHolder: namingConvention.outputs.resourceNameConv
    environment : env
   // parPcLawSolutions: parPcLawSolutions TEMP{TEST}
    tags: tagValues
    restrictedNamingPlaceHolder : namingConvention.outputs.outputObjects.restrictedNameSSPlaceholder
    namesuffix : 'lnss'
    //namesuffix: uniqueString(substring(toLower(coreResourceGroup.id), 0, min(length(coreResourceGroup.name), 4)))
  }
}



