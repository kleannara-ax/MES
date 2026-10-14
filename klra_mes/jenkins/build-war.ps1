param(
    [string]$JdkHome = $env:JAVA_HOME,
    [Parameter(Mandatory = $true)]
    [string]$TomcatHome,
    [string]$OutputDirectory = ""
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $projectRoot 'out\jenkins'
}

$outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
$projectPrefix = $projectRoot.TrimEnd('\') + '\'
if (-not $outputRoot.StartsWith($projectPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "OutputDirectory must be inside the project: $outputRoot"
}

$javac = Join-Path $JdkHome 'bin\javac.exe'
$jar = Join-Path $JdkHome 'bin\jar.exe'
$servletApi = Join-Path $TomcatHome 'lib\servlet-api.jar'
$webRoot = Join-Path $projectRoot 'WebContent'
$sourceRoot = Join-Path $projectRoot 'src'
$stageRoot = Join-Path $outputRoot 'ROOT'
$classesRoot = Join-Path $stageRoot 'WEB-INF\classes'
$warPath = Join-Path $outputRoot 'ROOT.war'
$sourceList = Join-Path $outputRoot 'java-sources.txt'

foreach ($required in @($javac, $jar, $servletApi, $webRoot, $sourceRoot)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Required path not found: $required"
    }
}

if (Test-Path -LiteralPath $outputRoot) {
    Remove-Item -LiteralPath $outputRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $classesRoot | Out-Null

Copy-Item -Path (Join-Path $webRoot '*') -Destination $stageRoot -Recurse -Force

$javaSources = @(Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Filter '*.java' |
    Where-Object { $_.FullName -notlike (Join-Path $sourceRoot 'org\*') })
if ($javaSources.Count -eq 0) {
    throw 'No Java sources found.'
}

$sourceArguments = $javaSources | ForEach-Object {
    '"' + $_.FullName.Replace('\', '/') + '"'
}
[IO.File]::WriteAllLines($sourceList, $sourceArguments, [Text.UTF8Encoding]::new($false))

$classPath = @(
    (Join-Path $webRoot 'WEB-INF\lib\*'),
    $servletApi
) -join ';'

& $javac -encoding UTF-8 -source 1.8 -target 1.8 `
    -classpath $classPath -sourcepath $sourceRoot -d $classesRoot "@$sourceList"
if ($LASTEXITCODE -ne 0) {
    throw "javac failed with exit code $LASTEXITCODE"
}

Get-ChildItem -LiteralPath $sourceRoot -Recurse -File |
    Where-Object { $_.Extension -ne '.java' } |
    ForEach-Object {
        $relative = $_.FullName.Substring($sourceRoot.Length + 1)
        $destination = Join-Path $classesRoot $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
    }

$javaFx = Join-Path $JdkHome 'jre\lib\ext\jfxrt.jar'
if (-not (Test-Path -LiteralPath $javaFx)) {
    $javaFx = Join-Path $JdkHome 'lib\ext\jfxrt.jar'
}
if (Test-Path -LiteralPath $javaFx) {
    Copy-Item -LiteralPath $javaFx -Destination (Join-Path $stageRoot 'WEB-INF\lib\jfxrt.jar') -Force
}

Push-Location $stageRoot
try {
    & $jar -cf $warPath '.'
    if ($LASTEXITCODE -ne 0) {
        throw "jar failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}

$war = Get-Item -LiteralPath $warPath
$hash = Get-FileHash -LiteralPath $warPath -Algorithm SHA256
Write-Output "WAR=$($war.FullName)"
Write-Output "SIZE=$($war.Length)"
Write-Output "SHA256=$($hash.Hash)"
