// The name of the team that will be responsible for the resource.
@maxLength(8)
@description('Deparment name that gets passed from parameter file during the deployment')
param department string
@description('Generate current date for useful suffix and deployment')
param currentDate string = utcNow('yyyy-MM-dd')
// The environment that the resource is for. Accepted values are defined to ensure consistency.
@description('Environment name that gets passed from parameter file during the deployment')
param environment string
@description('ApproleShotname from the object inside the array of application name and applicaton short name from main template')
param appRoleShortName string
//param appRoleName string
param locationShortName string
param index int = length(locationShortName)



// ****This would be more appropriate prefix for production env to extract only single letter out of envrironment instead of three letters to create prefix
// param locationprefix = substring(environment,0,1)

// The function/goal of the resource, for instance the name of an application it supports


// An index number. This enables you to have some sort of versioning or to create redundancy
// param index int

// First, we create shorter versions of the application role and the department name. 
// This is used for resources with a limited length to the name.
// There is a risk to doing at this way, as results might be non-desirable.
// An alternative might be to have these values be a parameter

// We only need the first three letter of the environment, so we substract it.
// var servicePrefix = azNamePrefixes.storageAccountPrefix.name
// var appRole = environmentInfo.parameters.appRole.value
// var environmentLetter = substring(environment,0,2)

// This line constructs the resource name. It uses [PC] for the resource type abbreviation.
// var resourceNamePlaceHolder = '${department}-${environment}-${appRoleShortName}${locationShortName}-[PC]' //-${padLeft(index,2,'0')}'
// This part can be replaced in the final template
// This line creates a short version for resources with a max name length of 24

// Storage accounts have specific limitations. The correct convention is created here. Convets name to lower and limits the length to 20. 
// Therefore, we could have flexibily to add 2 - 3 leeter suffix during resource deployment
// var restrictedNamePlaceholder = take(toLower('sharedservices001'),12)

//var saAccountNamePlaceHolder = take(toLower('${department}${environment}${appRoleShortName}${azNamePrefixes.parameters.storageAccountPrefix}${padLeft(index,2,'0')}'),20)


// Configuration set object variable to generate collective output keeps the code shorter
var outputObjects = {
  // This line constructs the none restricted resource naming convention. It uses [PC] for the resource type abbreviation.
  resourceNamePlaceHolder : '${department}-${environment}-${appRoleShortName}${locationShortName}-[PC]'
  // This line constructs the restricted resource naming convention. 
  restrictedNameSSPlaceholder : take(toLower('sharedservices001'),12)
    // This line constructs the restricted resource naming convention for the storage account 
   saAccountNamePlaceHolder : take(toLower('relli${department}${environment}${appRoleShortName}PC${padLeft(index,2,'0')}'),20)
   currentdate : currentDate
   restrictedNamePlaceholder : take(toLower('${department}${environment}${appRoleShortName}'),11)
}
// Ths line creates  object output to send collective naming convention outputs for use in other modules 
output outputObjects object = outputObjects
// utput locShortName string = locationShortName




