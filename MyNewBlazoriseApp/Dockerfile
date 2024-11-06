ARG sdkImageTag=9.0-azurelinux3.0
ARG baseImageTag=9.0-azurelinux3.0-distroless-extra

FROM mcr.microsoft.com/dotnet/sdk:${sdkImageTag} AS build
ARG TFM=net9.0
WORKDIR /source

# Copy project file and restore as distinct layers
COPY . .
RUN dotnet restore

# Copy source code and publish app
COPY . .
RUN dotnet publish --configuration Release --framework $TFM --no-restore -o /app

FROM mcr.microsoft.com/dotnet/nightly/aspnet:${baseImageTag}
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["./MyNewBlazoriseApp"]
