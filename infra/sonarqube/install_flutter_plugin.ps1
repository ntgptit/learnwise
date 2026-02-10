param(
  [string]$ContainerName = "learnwise-sonarqube",
  [string]$PluginVersion = "0.5.2"
)

$ErrorActionPreference = "Stop"

$pluginFileName = "sonar-flutter-plugin-$PluginVersion.jar"
$pluginDownloadUrl = "https://github.com/insideapp-oss/sonar-flutter/releases/download/$PluginVersion/$pluginFileName"
$temporaryPath = Join-Path $env:TEMP $pluginFileName
$containerPluginPath = "/opt/sonarqube/extensions/plugins/$pluginFileName"

Invoke-WebRequest -Uri $pluginDownloadUrl -OutFile $temporaryPath
docker cp $temporaryPath "${ContainerName}:$containerPluginPath"
docker restart $ContainerName | Out-Null

Write-Output "Installed $pluginFileName into $ContainerName and restarted the container."
