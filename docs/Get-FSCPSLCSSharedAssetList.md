---
external help file: fscps.lcs-help.xml
Module Name: fscps.lcs
online version:
schema: 2.0.0
---

# Get-FSCPSLCSSharedAssetList

## SYNOPSIS
Retrieves a list of shared assets from D365 LCS.

## SYNTAX

```
Get-FSCPSLCSSharedAssetList [[-AssetFileType] <AssetFileType>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-FSCPSLCSSharedAssetList function uses Microsoft Playwright to automate the login process to LCS (Lifecycle Services)
and retrieves a list of shared assets based on the specified asset file type.
It handles authentication, session management,
and API requests to fetch the required data.

## EXAMPLES

### EXAMPLE 1
```
Get-FSCPSLCSSharedAssetList -AssetFileType SoftwareDeployablePackage
```

Retrieves a list of shared assets of type "SoftwareDeployablePackage" from D365 LCS.

## PARAMETERS

### -AssetFileType
The type of asset file to retrieve.
This parameter is mandatory and defaults to "SoftwareDeployablePackage".

```yaml
Type: AssetFileType
Parameter Sets: (All)
Aliases:
Accepted values: Model, ProcessDataPackage, SoftwareDeployablePackage, GERConfiguration, DataPackage, PowerBIReportModel, ECommercePackage, NuGetPackage, RetailSelfServicePackage, CommerceCloudScaleUnitExtension

Required: False
Position: 1
Default value: SoftwareDeployablePackage
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
- This function uses Microsoft Playwright for browser automation.
- Author: Oleksandr Nikolaiev (@onikolaiev)

## RELATED LINKS
