/*var environmentConfigurationMap = {
  Production: {
    appServicePlan: {
      sku: {
        name: 'P2V3'
        capacity: 3
      }
    }
    storageAccount: {
      sku: {
        name: 'ZRS'
      }
    }
  }
  Test: {
    appServicePlan: {
      sku: {
        name: 'S2'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'LRS'
      }
    Department: {
      name: 'Finance'
    },
    env: {
      value: 'dev'
    },
    "addressPrefixes": {
      "value": [
        "10.0.0.0/20"
      ]
    },
    "dnsServers": {
      "value": [
        "1.1.1.1",
        "4.4.4.4"
      ]
    },
    "locationList": {
      "value": {
        "westus2": "azw2",
        "westus": "azw"
      }
    },
    "subnets": {
      "value": [
        {
          "name": "frontend",
          "subnetPrefix": "10.0.2.0/24",
          "delegation": "Microsoft.Web/serverfarms",
          "privateEndpointNetworkPolicies": "disabled",
          "serviceEndpoints": [
            {
              "service": "Microsoft.KeyVault",
              "locations": [
                "*"
              ]
            },
            {
              "service": "Microsoft.Web",
              "locations": [
                "*"
              ]
            }
          ]
        },
        {
          "name": "backend",
          "subnetPrefix": "10.0.3.0/24",
          "delegation": "Microsoft.Web/serverfarms",
          "privateEndpointNetworkPolicies": "enabled",
          "serviceEndpoints": [
            {
              "service": "Microsoft.KeyVault",
              "locations": [
                "*"
              ]
            },
            {
              "service": "Microsoft.Web",
              "locations": [
                "*"
              ]
            },
            {
              "service": "Microsoft.AzureCosmosDB",
              "locations": [
                "*"
              ]

    }
  }
}
*/
