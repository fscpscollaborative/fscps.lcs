﻿<#
This script publishes the module to the gallery.
It expects as input an ApiKey authorized to publish the module.

Insert any build steps you may need to take before publishing it here.
#>
param (
	$ApiKey,
	
	$WorkingDirectory,
	
	$Repository = 'PSGallery',
	
	[switch]
	$LocalRepo,
	
	[switch]
	$SkipPublish,
	
	[switch]
	$AutoVersion,

	[switch]
	$Build
)

#region Handle Working Directory Defaults
if (-not $WorkingDirectory)
{
	if ($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS)
	{
		$WorkingDirectory = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
	}
	else { $WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY }
}
if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path $PSScriptRoot }
#endregion Handle Working Directory Defaults

# Build Library
if ($Build) {
	dotnet build "$WorkingDirectory\library\fscps.lcs.sln" -c Release
	Copy-Item -Path "$WorkingDirectory\library\fscps.lcs\bin\Release\net9.0\*" -Destination "$WorkingDirectory\fscps.lcs\bin" -Recurse -Force
	if ($LASTEXITCODE -ne 0) {
		throw "Failed to build fscps.lcs.dll!"
	}
}

# Prepare publish folder
Write-PSFMessage -Level Important -Message "Creating and populating publishing directory"
$publishDir = New-Item -Path $WorkingDirectory -Name publish -ItemType Directory -Force
Copy-Item -Path "$($WorkingDirectory)\fscps.lcs" -Destination $publishDir.FullName -Recurse -Force


# Create commands.ps1
$text = @()
Get-ChildItem -Path "$($publishDir.FullName)\fscps.lcs\internal\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}
Get-ChildItem -Path "$($publishDir.FullName)\fscps.lcs\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}
$text -join "`n`n" | Set-Content -Path "$($publishDir.FullName)\fscps.lcs\commands.ps1"

#region Gather text data to compile
# Create resourcesBefore.ps1
$processed = @()
$text = @()
foreach ($line in (Get-Content "$($PSScriptRoot)\filesBefore.txt" | Where-Object { $_ -notlike "#*" }))
{
	if ([string]::IsNullOrWhiteSpace($line)) { continue }
	
	$basePath = Join-Path "$($publishDir.FullName)\fscps.lcs" $line
	foreach ($entry in (Resolve-PSFPath -Path $basePath))
	{
		$item = Get-Item $entry
		if ($item.PSIsContainer) { continue }
		if ($item.FullName -in $processed) { continue }
		$text += [System.IO.File]::ReadAllText($item.FullName)
		$processed += $item.FullName
	}
}
if ($text) { $text -join "`n`n" | Set-Content -Path "$($publishDir.FullName)\fscps.lcs\resourcesBefore.ps1" }

# Create resourcesAfter.ps1
$processed = @()
$text = @()
foreach ($line in (Get-Content "$($PSScriptRoot)\filesAfter.txt" | Where-Object { $_ -notlike "#*" }))
{
	if ([string]::IsNullOrWhiteSpace($line)) { continue }
	
	$basePath = Join-Path "$($publishDir.FullName)\fscps.lcs" $line
	foreach ($entry in (Resolve-PSFPath -Path $basePath))
	{
		$item = Get-Item $entry
		if ($item.PSIsContainer) { continue }
		if ($item.FullName -in $processed) { continue }
		$text += [System.IO.File]::ReadAllText($item.FullName)
		$processed += $item.FullName
	}
}
if ($text) { $text -join "`n`n" | Set-Content -Path "$($publishDir.FullName)\fscps.lcs\resourcesAfter.ps1" }
#endregion Gather text data to compile

#region Update the psm1 file
$fileData = Get-Content -Path "$($publishDir.FullName)\fscps.lcs\fscps.lcs.psm1" -Raw
$fileData = $fileData.Replace('"<was not compiled>"', '"<was compiled>"')
$fileData = $fileData.Replace('"<compile code into here>"', ($text -join "`n`n"))
[System.IO.File]::WriteAllText("$($publishDir.FullName)\fscps.lcs\fscps.lcs.psm1", $fileData, [System.Text.Encoding]::UTF8)
#endregion Update the psm1 file

#region Updating the Module Version
if ($AutoVersion)
{
	Write-PSFMessage -Level Important -Message "Updating module version numbers."
	try { [version]$remoteVersion = (Find-Module 'fscps.lcs' -Repository $Repository -ErrorAction Stop).Version }
	catch
	{
		Stop-PSFFunction -Message "Failed to access $($Repository)" -EnableException $true -ErrorRecord $_
	}
	if (-not $remoteVersion)
	{
		Stop-PSFFunction -Message "Couldn't find fscps.lcs on repository $($Repository)" -EnableException $true
	}
	$newBuildNumber = $remoteVersion.Build + 1
	[version]$localVersion = (Import-PowerShellDataFile -Path "$($publishDir.FullName)\fscps.lcs\fscps.lcs.psd1").ModuleVersion
	Update-ModuleManifest -Path "$($publishDir.FullName)\fscps.lcs\fscps.lcs.psd1" -ModuleVersion "$($localVersion.Major).$($localVersion.Minor).$($newBuildNumber)"
	Update-ModuleManifest -Path "$($WorkingDirectory)\fscps.lcs\fscps.lcs.psd1" -ModuleVersion "$($localVersion.Major).$($localVersion.Minor).$($newBuildNumber)"
}
#endregion Updating the Module Version

#region Publish
if ($SkipPublish) { return }
if ($LocalRepo)
{
	# Dependencies must go first
	Write-PSFMessage -Level Important -Message "Creating Nuget Package for module: PSFramework"
	New-PSMDModuleNugetPackage -ModulePath (Get-Module -Name PSFramework).ModuleBase -PackagePath .
	Write-PSFMessage -Level Important -Message "Creating Nuget Package for module: fscps.lcs"
	New-PSMDModuleNugetPackage -ModulePath "$($publishDir.FullName)\fscps.lcs" -PackagePath .
}
else
{
	# Publish to Gallery
	Write-PSFMessage -Level Important -Message "Publishing the fscps.lcs module to $($Repository)"
	Publish-Module -Path "$($publishDir.FullName)\fscps.lcs" -NuGetApiKey $ApiKey -Force -Repository $Repository
}
#endregion Publish