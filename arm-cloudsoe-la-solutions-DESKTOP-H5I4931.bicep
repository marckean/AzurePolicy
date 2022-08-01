@description('The region that log analytics is deployed to.')
@allowed([
  'australiaeast'
  'australiasoutheast'
])
param workspaceRegion string

@description('The Log Analytics Workspace where any data sources will be directed.')
param workspaceResourceId string

var workspaceName = split(workspaceResourceId, '/')[8]
var changeTrackingResourceName_var = 'ChangeTracking(${workspaceName})'
var securityResourceName_var = 'Security(${workspaceName})'
var securityCenterFreeResourceName_var = 'SecurityCenterFree(${workspaceName})'
var updatesResourceName_var = 'Updates(${workspaceName})'
var vminsightsResourceName_var = 'VMInsights(${workspaceName})'

resource changeTrackingResourceName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: changeTrackingResourceName_var
  location: workspaceRegion
  properties: {
    workspaceResourceId: workspaceResourceId
  }
  plan: {
    name: 'ChangeTracking(${workspaceName})'
    product: 'OMSGallery/ChangeTracking'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource securityResourceName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: securityResourceName_var
  location: workspaceRegion
  plan: {
    name: securityResourceName_var
    promotionCode: ''
    product: 'OMSGallery/Security'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspaceResourceId
  }
}

resource securityCenterFreeResourceName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: securityCenterFreeResourceName_var
  location: workspaceRegion
  plan: {
    name: securityCenterFreeResourceName_var
    promotionCode: ''
    product: 'OMSGallery/SecurityCenterFree'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspaceResourceId
  }
}

resource updatesResourceName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: updatesResourceName_var
  location: workspaceRegion
  plan: {
    name: updatesResourceName_var
    promotionCode: ''
    product: 'OMSGallery/Updates'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspaceResourceId
  }
}

resource vminsightsResourceName 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: vminsightsResourceName_var
  location: workspaceRegion
  plan: {
    name: vminsightsResourceName_var
    promotionCode: ''
    product: 'OMSGallery/VMInsights'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspaceResourceId
  }
}

resource workspaceName_ChangeTrackingDefaultRegistry_IPv6_Setting 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  name: '${workspaceName}/ChangeTrackingDefaultRegistry_IPv6 Setting'
  properties: {
    enabled: 'True'
    keyName: 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Tcpip6\\Parameters'
    valueName: ''
    recurse: 'False'
    groupTag: 'Custom'
  }
  kind: 'ChangeTrackingDefaultRegistry'
  dependsOn: [
    changeTrackingResourceName
  ]
}

resource workspaceName_ChangeTrackingDefaultRegistry_LSA_Setting 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  name: '${workspaceName}/ChangeTrackingDefaultRegistry_LSA Setting'
  properties: {
    enabled: 'True'
    keyName: 'HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\Lsa'
    valueName: ''
    recurse: 'False'
    groupTag: 'Custom'
  }
  kind: 'ChangeTrackingDefaultRegistry'
  dependsOn: [
    changeTrackingResourceName
  ]
}

resource workspaceName_ChangeTrackingDefaultRegistry_WindowsNtCurrentVersion 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  name: '${workspaceName}/ChangeTrackingDefaultRegistry_WindowsNtCurrentVersion'
  properties: {
    enabled: 'True'
    keyName: 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion'
    valueName: ''
    recurse: 'False'
    groupTag: 'Custom'
  }
  kind: 'ChangeTrackingDefaultRegistry'
  dependsOn: [
    changeTrackingResourceName
  ]
}

resource workspaceName_SecurityEventCollectionConfiguration 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  name: '${workspaceName}/SecurityEventCollectionConfiguration'
  kind: 'SecurityEventCollectionConfiguration'
  properties: {
    tier: 'Recommended'
    tierSetMethod: 'Custom'
  }
}

resource DCR_AccountLockoutEvents 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'DCR-AccountLockoutEvents'
  kind: 'Windows'
  location: workspaceRegion
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Security!*[System[((EventID=4625))]]'
            'Security!*[System[((EventID=4740))]]'
          ]
          name: 'AccountLockoutEvents'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

resource DCR_ASREvents 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'DCR-ASREvents'
  kind: 'Windows'
  location: workspaceRegion
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Microsoft-Windows-Windows Defender/Operational!*[System[((EventID &gt;= 1121 and EventID &lt;= 1122))]]'
            'Microsoft-Windows-Windows Defender/WHC!*[System[((EventID &gt;= 1121 and EventID &lt;= 1122))]]'
          ]
          name: 'ASREvents'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

resource DCR_NTLMEvents 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'DCR-NTLMEvents'
  kind: 'Windows'
  location: workspaceRegion
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Microsoft-Windows-NTLM/Operational!*[System[((EventID &gt;= 8001 and EventID &lt;= 8004))]]'
          ]
          name: 'NTLMEvents'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

resource DCR_ExploitProtectionEvents 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'DCR-ExploitProtectionEvents'
  kind: 'Windows'
  location: workspaceRegion
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Microsoft-Windows-Security-Mitigations/KernelMode!*[System[((EventID &gt;= 1 and EventID &lt;= 24))]]'
            'Microsoft-Windows-Security-Mitigations/UserMode!*[System[((EventID &gt;= 1 and EventID &lt;= 24))]]'
            'Microsoft-Windows-Win32k/Operational!*[System[((EventID=260))]]'
            'System!*[System[Provider[@Name=\'Microsoft-Windows-WER-Diag\'] and (EventID=5)]]'
          ]
          name: 'ExploitProtectionEvents'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

resource DCR_IPsecEvents 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'DCR-IPsecEvents'
  kind: 'Windows'
  location: workspaceRegion
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Security!*[System[((EventID &gt;= 4650 and EventID &lt;= 4651))]]'
            'Security!*[System[((EventID=5451))]]'
          ]
          name: 'IPsecEvents'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

resource DCR_NetworkProtectionEvents 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'DCR-NetworkProtectionEvents'
  kind: 'Windows'
  location: workspaceRegion
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Microsoft-Windows-Windows Defender/Operational!*[System[((EventID &gt;= 1125 and EventID &lt;= 1126))]]'
            'Microsoft-Windows-Windows Defender/WHC!*[System[((EventID &gt;= 1125 and EventID &lt;= 1126))]]'
          ]
          name: 'NetworkProtectionEvents'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

resource DCR_SChannelEvents 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'DCR-SChannelEvents'
  kind: 'Windows'
  location: workspaceRegion
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'System!*[System[((EventID=36880))]]'
          ]
          name: 'SChannelEvents'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

resource DCR_WDACEvents 'Microsoft.Insights/dataCollectionRules@2021-04-01' = {
  name: 'DCR-WDACEvents'
  kind: 'Windows'
  location: workspaceRegion
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Microsoft-Windows-CodeIntegrity/Operational!*[System[((EventID=3077 or EventID=3092 or EventID=3099))]]'
          ]
          name: 'WDACEvents'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

output dataCollectionRuleResourceIds object = {
  'DCR-AccountLockoutEvents': DCR_AccountLockoutEvents.id
  'DCR-ASREvents': DCR_ASREvents.id
  'DCR-NTLMEvents': DCR_NTLMEvents.id
  'DCR-ExploitProtectionEvents': DCR_ExploitProtectionEvents.id
  'DCR-IPsecEvents': DCR_IPsecEvents.id
  'DCR-NetworkProtectionEvents': DCR_NetworkProtectionEvents.id
  'DCR-SChannelEvents': DCR_SChannelEvents.id
  'DCR-WDACEvents': DCR_WDACEvents.id
}