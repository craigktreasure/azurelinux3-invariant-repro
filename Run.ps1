$ErrorActionPreference = 'Stop'

Write-Host 'Building MyNewBlazoriseApp targeting .NET 8.0 into Mariner 2.0 .NET 8 container...' -ForegroundColor Magenta
docker build -f .\MyNewBlazoriseApp\Dockerfile --force-rm --build-arg baseImageTag=8.0-cbl-mariner2.0-distroless-extra --build-arg sdkImageTag=9.0-azurelinux3.0 --build-arg TFM=net8.0 -t mynewblazoriseapp:net8-mariner2 .
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Container build failed.'
}

Write-Host 'Building MyNewBlazoriseApp targeting .NET 8.0 into Azure Linux 3.0 .NET 8 container...' -ForegroundColor Magenta
docker build -f .\MyNewBlazoriseApp\Dockerfile --force-rm --build-arg baseImageTag=8.0-azurelinux3.0-distroless-extra --build-arg sdkImageTag=9.0-azurelinux3.0 --build-arg TFM=net8.0 -t mynewblazoriseapp:net8-azurelinux3 .

if ($LASTEXITCODE -ne 0) {
    Write-Error 'Container build failed.'
}

Write-Host 'Building MyNewBlazoriseApp targeting .NET 9.0 into Ubuntu Noble .NET 9 container...' -ForegroundColor Magenta
docker build -f .\MyNewBlazoriseApp\Dockerfile --force-rm --build-arg baseImageTag=9.0-noble-chiseled-extra --build-arg sdkImageTag=9.0-noble --build-arg TFM=net9.0 -t mynewblazoriseapp:net9-noble .
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Container build failed.'
}

Write-Host 'Building MyNewBlazoriseApp targeting .NET 9.0 into Azure Linux 3.0 .NET 9 container...' -ForegroundColor Magenta
docker build -f .\MyNewBlazoriseApp\Dockerfile --force-rm --build-arg baseImageTag=9.0-azurelinux3.0-distroless-extra --build-arg sdkImageTag=9.0-azurelinux3.0 --build-arg TFM=net9.0 -t mynewblazoriseapp:net9-azurelinux3 .
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Container build failed.'
}

Write-Host 'Running MyNewBlazoriseApp targeting .NET 8.0 on Mariner 2.0. Open http://localhost:8080 to view. Should work. Press ctrl+c to exit.' -ForegroundColor Magenta
docker run --rm -it -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development mynewblazoriseapp:net8-mariner2

Write-Host 'Running MyNewBlazoriseApp targeting .NET 8.0 on Azure Linux 3.0. Open http://localhost:8080 to view. Should work. Press ctrl+c to exit.' -ForegroundColor Magenta
docker run --rm -it -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development mynewblazoriseapp:net8-azurelinux3

Write-Host 'Running MyNewBlazoriseApp targeting .NET 9.0 on Ubuntu Noble. Open http://localhost:8080 to view. Should work. Press ctrl+c to exit.' -ForegroundColor Magenta
docker run --rm -it -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development mynewblazoriseapp:net9-noble

Write-Host 'Running MyNewBlazoriseApp targeting .NET 9.0 on Azure Linux 3.0. Open http://localhost:8080 to view. Should be broken. Press ctrl+c to exit.' -ForegroundColor Magenta
docker run --rm -it -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development mynewblazoriseapp:net9-azurelinux3

Write-Host 'Done!' -ForegroundColor Green
