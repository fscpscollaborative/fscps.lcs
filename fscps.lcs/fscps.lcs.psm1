$script:ModuleRoot = "$PSScriptRoot"
$script:ModuleVersion = (Import-PowerShellDataFile -Path "$($script:ModuleRoot)\fscps.lcs.psd1").ModuleVersion
$Script:DefaultTempPath = "c:\temp\fscps.lcs"
$Script:BinFolder = "$($Script:ModuleRoot)\bin"
$Script:PlaywrightDll = "$($Script:BinFolder)\Microsoft.Playwright.dll"
$Script:CookiesPath = "$Script:BinFolder\.playwright\state.json"

# Detect whether at some level dotsourcing was enforced
$script:doDotSource = Get-PSFConfigValue -FullName fscps.lcs.Import.DoDotSource -Fallback $false
if ($fscps.lcs_dotsourcemodule) { $script:doDotSource = $true }

<#
Note on Resolve-Path:
All paths are sent through Resolve-Path/Resolve-PSFPath in order to convert them to the correct path separator.
This allows ignoring path separators throughout the import sequence, which could otherwise cause trouble depending on OS.
Resolve-Path can only be used for paths that already exist, Resolve-PSFPath can accept that the last leaf my not exist.
This is important when testing for paths.
#>

# Detect whether at some level loading individual module files, rather than the compiled module was enforced
$importIndividualFiles = Get-PSFConfigValue -FullName fscps.lcs.Import.IndividualFiles -Fallback $false
if ($fscps.lcs_importIndividualFiles) { $importIndividualFiles = $true }
if (Test-Path (Resolve-PSFPath -Path "$($script:ModuleRoot)\..\.git" -SingleItem -NewChild)) { $importIndividualFiles = $true }
if (-not (Test-Path (Resolve-PSFPath "$($script:ModuleRoot)\commands.ps1" -SingleItem -NewChild))) { $importIndividualFiles = $true }

function Import-ModuleFile
{
	<#
		.SYNOPSIS
			Loads files into the module on module import.
		
		.DESCRIPTION
			This helper function is used during module initialization.
			It should always be dotsourced itself, in order to proper function.
			
			This provides a central location to react to files being imported, if later desired
		
		.PARAMETER Path
			The path to the file to load
		
		.EXAMPLE
			PS C:\> . Import-ModuleFile -File $function.FullName
	
			Imports the file stored in $function according to import policy
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Path
	)
	
	$resolvedPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($Path).ProviderPath
	if ($doDotSource) { . $resolvedPath }
	else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($resolvedPath))), $null, $null) }
}


if ($importIndividualFiles)
{
	# Execute Preimport actions
	. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\preimport.ps1"
	# Import all internal functions
	foreach ($function in (Get-ChildItem "$($script:ModuleRoot)\internal\functions" -Filter "*.ps1" -Recurse -ErrorAction Ignore))
	{
		. Import-ModuleFile -Path $function.FullName
	}

	# Import all public functions
	foreach ($function in (Get-ChildItem "$($script:ModuleRoot)\functions" -Filter "*.ps1" -Recurse -ErrorAction Ignore))
	{
		. Import-ModuleFile -Path $function.FullName
	}

	# Execute Postimport actions
	. Import-ModuleFile -Path "$($script:ModuleRoot)\internal\scripts\postimport.ps1"
}
else
{
	if (Test-Path (Resolve-PSFPath "$($script:ModuleRoot)\resourcesBefore.ps1" -SingleItem -NewChild))
	{
		. Import-ModuleFile -Path "$($script:ModuleRoot)\resourcesBefore.ps1"
	}

	. Import-ModuleFile -Path "$($script:ModuleRoot)\commands.ps1"

	if (Test-Path (Resolve-PSFPath "$($script:ModuleRoot)\resourcesAfter.ps1" -SingleItem -NewChild))
	{
		. Import-ModuleFile -Path "$($script:ModuleRoot)\resourcesAfter.ps1"
	}
}

function Ensure-PlaywrightBrowsers {
    # Check for the .playwright folder or a marker file to avoid redundant installs
    $browsersMarker = Join-Path $Script:BinFolder ".playwright" 
    if (-not (Test-Path $browsersMarker)) {
        Write-Verbose "Installing Playwright browsers..."
        $Env:PLAYWRIGHT_DRIVER_SEARCH_PATH = "$Script:BinFolder"
        $arguments = @("install", "--with-deps")
        [Microsoft.Playwright.Program]::Main($arguments)
    } else {
        Write-Verbose "Playwright browsers already installed."
    }
}
#region Playwright
$tempFolder = [System.IO.Path]::Combine($Script:DefaultTempPath, "Microsoft.Playwright")
[System.IO.Directory]::CreateDirectory($Script:tempFolder) | Out-Null
$nugetUrl = "https://www.nuget.org/api/v2/package/Microsoft.Playwright"
$nugetPackagePath = [System.IO.Path]::Combine($tempFolder, "Microsoft.Playwright.nupkg")

if(-not (Test-Path "$nugetPackagePath")) {
	Start-BitsTransfer -Source $nugetUrl -Destination $nugetPackagePath -Dynamic -HttpMethod GET -ErrorAction SilentlyContinue
}
$exctractedFolderPath = [System.IO.Path]::Combine($tempFolder, "_extracted")
if(Test-Path "$exctractedFolderPath") { 
	Remove-Item "$exctractedFolderPath" -Recurse -Force -ErrorAction SilentlyContinue
}
# Extract the NuGet package
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($nugetPackagePath, $exctractedFolderPath)

Get-ChildItem $tempFolder -Recurse | Where-Object { $_.Name -eq "Microsoft.Playwright.dll" } | ForEach-Object {
    $dllPath = $_.FullName
    Copy-Item -Path $dllPath -Destination "$($script:PlaywrightDll)" -Force
    [Reflection.Assembly]::Load([System.IO.File]::ReadAllBytes("$($script:PlaywrightDll)")) | Out-Null
}
# Ensure Playwright browsers are installed
Ensure-PlaywrightBrowsers
#endregion Playwright

#endregion Load individual files
#region Load compiled code
"<compile code into here>"
#endregion Load compiled code