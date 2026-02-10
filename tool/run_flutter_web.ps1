param(
  [int]$Port = 3000,
  [string]$Device = "chrome"
)

$ErrorActionPreference = "Stop"

flutter run -d $Device --web-hostname 0.0.0.0 --web-port $Port
