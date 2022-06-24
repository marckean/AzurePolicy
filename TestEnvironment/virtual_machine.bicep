param virtualMachineName01 string
param networkInterfaceName01 string
param location string
param adminUsername string
param adminPassword string
param virtualMachineSize string

var NICId = resourceId('Microsoft.Network/networkInterfaces', networkInterfaceName01)

resource virtualMachine_01 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName01
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-smalldisk-g2'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: virtualMachineName01
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'AutomaticByOS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NICId
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
