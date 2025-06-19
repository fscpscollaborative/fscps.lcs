---
external help file: fscps.lcs-help.xml
Module Name: fscps.lcs
online version:
schema: 2.0.0
---

# Get-FSCPSLCSProject

## SYNOPSIS
Retrieves details of a specific project from Microsoft Dynamics Lifecycle Services (LCS) using its project ID.

## SYNTAX

```
Get-FSCPSLCSProject [-ProjectId] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-FSCPSLCSProject function uses Microsoft Playwright to interact with LCS and retrieves details of a specific project by its project ID.
It constructs the API request URL dynamically, includes the required headers (such as __RequestVerificationToken), and sends a GET request to the LCS API endpoint.
The function handles authentication, session management, and API requests to fetch the required project data.

## EXAMPLES

### EXAMPLE 1
```
Get-FSCPSLCSProject -ProjectId "12345"
```

Retrieves details of the project with ID "12345" from Microsoft Dynamics Lifecycle Services.

## PARAMETERS

### -ProjectId
Specifies the ID of the project to retrieve.
This parameter is mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
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
- Ensure that the Playwright environment is properly initialized before calling this function.
- Author: \[Your Name\]

## RELATED LINKS
