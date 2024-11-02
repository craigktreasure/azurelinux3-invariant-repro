ARG baseImageTag=8.0-noble-chiseled-extra

FROM mcr.microsoft.com/dotnet/aspnet:${baseImageTag}

WORKDIR /app
COPY ./ /app
ENTRYPOINT ["dotnet", "MyNewBlazoriseApp.dll"]
