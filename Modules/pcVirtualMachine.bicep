param pcnamingConvention string 
param tags string
param tagvalue object = {
  createdby:tags

}

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



@description('Location for all resources.')
param location string = resourceGroup().location

@description('Defining data disk resource')
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

//This setups up the configuration map and shortens the code the VM block and avoid the use of multiple if and else at the resoure block
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
  

    @description('Defining NIC  resource')
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
 

  