<#
.SYNOPSIS
    Build the Raspberry Pi (arm64) SickChill image on this desktop.

.DESCRIPTION
    Default: fast overlay build (~10s) of the current code on top of the local base image,
    saved to build\sickchill-<branch>.tar for Portainer's Images > Import.

    -Base  Full build of the base image (~2 min with cache, longer the first time). Run this once,
           and again whenever pyproject.toml dependencies change.
    -Push  Upload to ghcr.io/sean2603/sickchill:<branch> instead of writing a .tar
           (needs: docker login ghcr.io).

.EXAMPLE
    ./build-pi.ps1 -Base     # first time only
    ./build-pi.ps1           # every code change -> build\sickchill-feature_TBA.tar
    ./build-pi.ps1 -Push     # every code change -> ghcr.io
#>
param(
    [switch]$Base,
    [switch]$Push
)

# Not "Stop": Windows PowerShell treats docker's progress output on stderr as an error.
# Failures are caught via $LASTEXITCODE instead.
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$sha = (git rev-parse HEAD).Trim()
# Label builds with uncommitted changes so Help & Info doesn't claim a commit it doesn't match
$label = $branch
if (git status --porcelain) {
    $label = "$branch-dirty"
    Write-Warning "Uncommitted changes: the image will show branch '$label' in Help & Info"
}
$baseImage = "sickchill:base-arm64"
$localImage = "sickchill:$branch"
$remoteImage = "ghcr.io/sean2603/sickchill:$branch"

if ($Base) {
    docker buildx inspect sc *> $null
    if ($LASTEXITCODE -ne 0) {
        docker buildx create --name sc --driver docker-container --buildkitd-flags "--allow-insecure-entitlement security.insecure"
    }
    docker buildx build --builder sc --platform linux/arm64 --allow security.insecure --target sickchill-final `
        --build-arg SOURCE=1 --build-arg GIT_BRANCH=$branch --build-arg GIT_SHA=$sha -t $baseImage --load .
    if ($LASTEXITCODE -ne 0) { throw "Base build failed" }
    Write-Host "Base image ready: $baseImage"
    return
}

docker image inspect $baseImage *> $null
if ($LASTEXITCODE -ne 0) { throw "No $baseImage yet - run ./build-pi.ps1 -Base first" }

$output = if ($Push) { @("-t", $remoteImage, "--push") } else { @("-t", $localImage, "--load") }
docker buildx build --builder desktop-linux --platform linux/arm64 -f Dockerfile.overlay `
    --build-arg BASE=$baseImage --build-arg GIT_BRANCH=$label --build-arg GIT_SHA=$sha @output .
if ($LASTEXITCODE -ne 0) { throw "Overlay build failed" }

if ($Push) {
    Write-Host "Pushed $remoteImage ($label@$($sha.Substring(0,12))). In Portainer: redeploy with Re-pull image on."
} else {
    New-Item -ItemType Directory -Force build | Out-Null
    $tar = "build\sickchill-$branch.tar"
    docker save $localImage -o $tar
    if ($LASTEXITCODE -ne 0) { throw "docker save failed" }
    Write-Host "Saved $tar ($label@$($sha.Substring(0,12))). In Portainer: Images > Import, then redeploy with Re-pull image off."
}
