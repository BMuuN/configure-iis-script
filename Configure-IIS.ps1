# Command Arguments
param (
    [string]$branch
)

Import-Module WebAdministration

$websitePathAsp = "asp.example.local"
$websitePathMvc = "mvc.example.local"

$appPoolNameNonMvc = "ASP.NET v2.0"
$appPoolNameMvc = "ASP.NET v4.0"

# Check a code branch was supplied
if([string]::IsNullOrEmpty($branch)) {
    Write-Host "The -branch parameter is required e.g .\Configure-IIS.ps1 Dev-Team"
    Exit
}

Write-Host ""
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host ""
Write-Host "`tIIS WEBSITE CONFIGURATION"
Write-Host ""

# Remove ASP Website
if (Test-Path "IIS:\Sites\$websitePathAsp") {
    Write-Host "Removing ASP Website"
    Remove-WebSite -Name $websitePathAsp
}

# Remove MVC Website
if (Test-Path "IIS:\Sites\$websitePathMvc") {
    Write-Host "Removing MVC Website"
    Remove-WebSite -Name $websitePathMvc
}

# Create the ASP.Net 2.0 Integrated Application Pool
if (-Not (Test-Path "IIS:\AppPools\$appPoolNameNonMvc")) {
    
    Write-Host "Creating ASP.NET v2.0 Integrated Application Pool"
    
    $appPool = New-WebAppPool -Name $appPoolNameNonMvc
    $appPool.managedRuntimeVersion = “v2.0”
    $appPool.managedPipelineMode = “Integrated”
    $appPool.processModel.identityType = "LocalSystem"
    $appPool | Set-Item
    
    #Start-WebAppPool -Name $appPoolName
}

<#
# Create the ASP.Net 4.0 Classic Application Pool
# Note: Here as an example and is not apart of this script.
$appPoolNameMvcClassic = "ASP.NET v4.0 Classic"
if (-Not (Test-Path "IIS:\AppPools\$appPoolNameMvcClassic")) {
    
    Write-Host "Creating ASP.NET v4.0 Classic Application Pool"
    
    $appPool = New-WebAppPool -Name $appPoolNameMvcClassic
    $appPool.managedRuntimeVersion = “v4.0”
    $appPool.managedPipelineMode = “Classic”
    $appPool.processModel.identityType = "LocalSystem"
    $appPool | Set-Item
    
    #Start-WebAppPool -Name $appPoolName
}
#>

# Create the ASP.Net 4.0 Integrated Application Pool
if (-Not (Test-Path "IIS:\AppPools\$appPoolNameMvc")) {
    
    Write-Host "Creating ASP.NET v4.0 Integrated Application Pool"
    
    $appPool = New-WebAppPool -Name $appPoolNameMvc
    $appPool.managedRuntimeVersion = “v4.0”
    $appPool.managedPipelineMode = “Integrated”
    $appPool.processModel.identityType = "LocalSystem"
    $appPool | Set-Item
    
    #Start-WebAppPool -Name $appPoolNameMvc
}

Write-Host ""

# Websites

Write-Host "Adding ASP Website"
New-WebSite -Name $websitePathAsp -Port 80 -HostHeader $websitePathAsp -IPAddress "*" -PhysicalPath "C:\TFS\$branch\AspWebApplication" -ApplicationPool $appPoolNameNonMvc > $null

Write-Host "Adding MVC Website"
New-WebSite -Name $websitePathMvc -Port 80 -HostHeader $websitePathMvc -IPAddress "*" -PhysicalPath "C:\TFS\$branch\MvcWebApplication" -ApplicationPool $appPoolNameMvc > $null

Write-Host ""

# Global Themes Directory
Write-Host "Adding Global Themes to ASP Website"
New-WebVirtualDirectory -Site $websitePathAsp -Name "aspnet_client" -PhysicalPath "C:\inetpub\wwwroot\aspnet_client" > $null
Write-Host ""

# Nested Web Applications
Write-Host "Adding Nested Web Application to ASP Website"
New-WebApplication -Name "NestedWebApp" -Site $websitePathAsp -PhysicalPath "C:\TFS\$branch\NestedAspWebApplication" -ApplicationPool $appPoolNameNonMvc > $null
Write-Host ""

# Virtual Directory
Write-Host "Adding Virtual Directory to MVC Website"
New-WebVirtualDirectory -Site $websitePathMvc -Name "VirtualDirectory" -PhysicalPath "C:\TFS\$branch\MvcVirtualDirectory" > $null
Write-Host ""

# Disclaimer
Write-Host ""
Write-Host "Done!`nBye MuN!"
Write-Host ""
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

Exit