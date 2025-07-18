﻿param (
	$TestPublic = $true,
	
	$TestInternal = $true,
	
	[ValidateSet('None', 'Default', 'Passed', 'Failed', 'Pending', 'Skipped', 'Inconclusive', 'Describe', 'Context', 'Summary', 'Header', 'Fails', 'All')]
	$Show = "None",
	
	$Include = "*",
	
	$Exclude = ""
)

Write-PSFMessage -Level Important -Message "Starting Tests"

Write-PSFMessage -Level Important -Message "Importing Module"

Remove-Module d365fo.tools -ErrorAction Ignore
Import-Module "$PSScriptRoot\..\fscps.lcs.psd1"
Import-Module "$PSScriptRoot\..\fscps.lcs.psm1" -Force

Write-PSFMessage -Level Important -Message "Creating test result folder"
$null = New-Item -Path "$PSScriptRoot\..\.." -Name TestResults -ItemType Directory -Force

$totalFailed = 0
$totalRun = 0

$testresults = @()

#region Run Public PSScriptAnalyzer Tests
if ($TestPublic) {
	Write-PSFMessage -Level Important -Message "Modules imported, proceeding with general tests"
	$file = Get-Item "$PSScriptRoot\general\PSScriptAnalyzer.Tests.ps1"

	$pesterParm = @{}
	$pesterParm.Path = $file.FullName
	$pesterParm.Parameters = @{CommandPath = "$PSScriptRoot\..\functions" }

	Write-PSFMessage -Level Significant -Message "  Executing <c='em'>$($file.Name)</c>"
	$TestOuputFile = Join-Path "$PSScriptRoot\..\..\TestResults" "TEST-$($file.BaseName).xml"
	$results = Invoke-Pester -Script $pesterParm -Show $Show -PassThru -OutputFile $TestOuputFile -OutputFormat NUnitXml
	foreach ($result in $results) {
		$totalRun += $result.TotalCount
		$totalFailed += $result.FailedCount
		$result.TestResult | Where-Object { -not $_.Passed } | ForEach-Object {
			$name = $_.Name
			$testresults += [pscustomobject]@{
				Describe = $_.Describe
				Context  = $_.Context
				Name     = "It $name"
				Result   = $_.Result
				Message  = $_.FailureMessage
			}
		}
	}
}

#endregion Run Public PSScriptAnalyzer Tests

#region Run Internal PSScriptAnalyzer Tests
if ($TestInternal) {
	Write-PSFMessage -Level Important -Message "Modules imported, proceeding with general tests"
	$file = Get-Item "$PSScriptRoot\general\PSScriptAnalyzer.Tests.ps1"

	$pesterParm = @{}
	$pesterParm.Path = $file.FullName
	$pesterParm.Parameters = @{CommandPath = "$PSScriptRoot\..\internal\functions" }

	Write-PSFMessage -Level Significant -Message "  Executing <c='em'>$($file.Name)</c>"
	$TestOuputFile = Join-Path "$PSScriptRoot\..\..\TestResults" "TEST-$($file.BaseName).xml"
	$results = Invoke-Pester -Script $pesterParm -Show $Show -PassThru -OutputFile $TestOuputFile -OutputFormat NUnitXml
	foreach ($result in $results) {
		$totalRun += $result.TotalCount
		$totalFailed += $result.FailedCount
		$result.TestResult | Where-Object { -not $_.Passed } | ForEach-Object {
			$name = $_.Name
			$testresults += [pscustomobject]@{
				Describe = $_.Describe
				Context  = $_.Context
				Name     = "It $name"
				Result   = $_.Result
				Message  = $_.FailureMessage
			}
		}
	}
}
#endregion Run Internal PSScriptAnalyzer Tests

$testresults | Sort-Object Describe, Context, Name, Result, Message | Format-List

if ($totalFailed -eq 0) { Write-PSFMessage -Level Critical -Message "All <c='em'>$totalRun</c> tests executed without a single failure!" }
else { Write-PSFMessage -Level Critical -Message "<c='em'>$totalFailed tests</c> out of <c='sub'>$totalRun</c> tests failed!" }

if ($totalFailed -gt 0) {
	throw "$totalFailed / $totalRun tests failed!"
}