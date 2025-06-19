---
external help file: fscps.lcs-help.xml
Module Name: fscps.lcs
online version:
schema: 2.0.0
---

# Get-FSCPSLCSProjectList

## SYNOPSIS
Retrieves a list of all projects from D365 LCS with optional paging parameters.

## SYNTAX

```
Get-FSCPSLCSProjectList [[-StartPosition] <Int32>] [[-ItemsRequested] <Int32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The Get-FSCPSLCSProjectList function uses Microsoft Playwright to automate the login process to LCS (Lifecycle Services)
and retrieves a list of all projects using a POST request.
It handles authentication, session management,
and API requests to fetch the required data.

## EXAMPLES

### EXAMPLE 1
```
Get-FSCPSLCSProjectList -StartPosition 0 -ItemsRequested 20
```

Retrieves the first 20 projects from D365 LCS starting at position 0.

## PARAMETERS

### -StartPosition
The starting position for paging.
Defaults to 0.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ItemsRequested
The number of items to retrieve.
Defaults to 20.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 50
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
