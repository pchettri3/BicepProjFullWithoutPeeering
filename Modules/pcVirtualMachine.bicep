param pcnamingConvention string 
param tags string
param tagvalue object = {
  createdby:tags

}
// param dataDiskRule object
// param vmcount int
// param vmname string
param coreSubnetName string
param coreSubnetID string
param OSdiskname string
param datadiskname string 
// param diskindex int
//param snetNamePrefix string
@description('Username for the Virtual Machine.')
param adminUsername string
@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string
// param vmsuffix array
/*@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'myPublicIP'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'*/

/*@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition' */


@description('Location for all resources.')
param location string = resourceGroup().location

resource myDisk 'Microsoft.Compute/disks@2022-07-02' =    {
  name: datadiskname
  location: location
  sku: {
    name: 'StandardSSD_LRS'
  }

  properties: {
    diskSizeGB: 20
    creationData: {
      createOption: 'Empty'
    }
  }
}


param environmentType string
var environmentConfigurationMap = {
  dev : {
    hardwareProfile: {
     vmSize: 'Standard_B2ms'
   }
   storageProfile: {
     imageReference: {
       publisher: 'MicrosoftWindowsServer'
       offer: 'WindowsServer'
       sku: '2022-Datacenter'
       version: 'latest'
   
     }
     osDisk: { 
       osType: 'Windows'
       name: OSdiskname
       createOption: 'FromImage'
       caching: 'ReadWrite'
       writeAcceleratorEnabled: false
       managedDisk: {
         storageAccountType: 'StandardSSD_LRS'
       }
       deleteOption: 'Detach'
     }
   }
 
   osProfile: {
    computerName: pcnamingConvention
    adminUsername: adminUsername
    adminPassword: adminPassword
    windowsConfiguration: {
      provisionVMAgent: true
      enableAutomaticUpdates: true
      patchSettings: {
        patchMode: 'AutomaticByOS'
        assessmentMode: 'ImageDefault'
        enableHotpatching: false
      }
}
}
networkProfile: {
networkInterfaces: [
  {
    id: pcVmNic.id
    properties: {
      primary: true
    }
  }
  ]

}   
winRM: {
listeners: []
}
enableVMAgentPlatformUpdates: false
diagnosticsProfile: {
bootDiagnostics: {
  enabled: false
}
}
}

stg : {
      hardwareProfile: {
       vmSize: 'Standard_B2ms'
     }
     storageProfile: {
       imageReference: {
         publisher: 'MicrosoftWindowsServer'
         offer: 'WindowsServer'
         sku: '2022-Datacenter'
         version: 'latest'
     
       }
       osDisk: {
         osType: 'Windows'
         name: OSdiskname
         createOption: 'FromImage'
         caching: 'ReadWrite'
         writeAcceleratorEnabled: false
         managedDisk: {
           storageAccountType: 'StandardSSD_LRS'
         }
         deleteOption: 'Detach'
       }
     }
   
     osProfile: {
      computerName: pcnamingConvention
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
  }
}
 networkProfile: {
  networkInterfaces: [
    {
      id: pcVmNic.id
      properties: {
        primary: true
      }
    }
    ]

}   
winRM: {
  listeners: []
}
enableVMAgentPlatformUpdates: false
diagnosticsProfile: {
  bootDiagnostics: {
    enabled: false
  }
}
 }
  
    Prod : {
      /*name: '${pcnamingConvention}-disk}'
      location: location
   tags: tags
      // properties: {
      */
      hardwareProfile: {
        vmSize: 'Standard_D2s_v5'
      }
      storageProfile: {
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2019-Datacenter'
          version: 'latest'
      
        }
        osDisk: {
          osType: 'Windows'
          name: OSdiskname
          createOption: 'FromImage'
          caching: 'ReadWrite'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          deleteOption: 'Detach'
        }
       dataDisks: [ 
          {
            createOption:  'attach'
            lun: substring(datadiskname, length(datadiskname)-1,1)
             diskSizeGB:20 
             managedDisk: {
              id: myDisk.id

            }
          }
        ]
}
osProfile: {
  computerName: pcnamingConvention
  adminUsername: adminUsername
  adminPassword: adminPassword
  windowsConfiguration: {
    provisionVMAgent: true
    enableAutomaticUpdates: true
    patchSettings: {
      patchMode: 'AutomaticByOS'
      assessmentMode: 'ImageDefault'
      enableHotpatching: false
    }
  }
}
networkProfile: {
  networkInterfaces: [
    {
      id: pcVmNic.id
      properties: {
        primary: true
      }
    }
    ]

}   

winRM: {
  listeners: []
}
enableVMAgentPlatformUpdates: false

diagnosticsProfile: {
  bootDiagnostics: {
    enabled: true
  }
}
 }
    }
  


    resource pcVmNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
      name: '${pcnamingConvention}nic'

       location: location
       properties: {
        ipConfigurations: [
          {
            name: 'ipConfigName'
            properties: {
              privateIPAllocationMethod: 'Dynamic'
              subnet: {
              name: coreSubnetName
                id: coreSubnetID
              }
            }
          }
        ]
      }
    }
  
output netinterface string = coreSubnetID
resource pcVirtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: pcnamingConvention
  location: location
   tags:tagvalue
  properties: {
       storageProfile:  environmentConfigurationMap[environmentType].storageProfile
       
        hardwareProfile: environmentConfigurationMap[environmentType].hardwareProfile
        networkProfile: environmentConfigurationMap[environmentType].networkProfile
        diagnosticsProfile: environmentConfigurationMap[environmentType].diagnosticsProfile
        osProfile: environmentConfigurationMap[environmentType].osProfile
        
      }
      

      }
 

  