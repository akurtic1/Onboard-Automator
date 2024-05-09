param vmName string = 'myVM' // Virtual machine name
param vmSize string = 'Standard_DS2_v2' // Virtual machine size
param location string = 'West Europe' // Location

// Define the virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'myVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'mySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Define the network security group (NSG)
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'myNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
        }
      }
    ]
  }
}

// Define the network interface
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'myNIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'myIPConfig'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/mySubnet' // Corrected subnet reference using string interpolation
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id // Associate the NSG with the network interface
    }
  }
}
// Define the virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureuser'
      adminPassword: 'MyPassword123!' // Replace with a strong password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
