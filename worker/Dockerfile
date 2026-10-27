# syntax=docker/dockerfile:1
# .NET is always built on the builder's native platform and cross-targeted,
# because dotnet does not run reliably under QEMU emulation.
FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:8.0.427 AS build
ARG TARGETARCH
WORKDIR /source
COPY *.csproj .
RUN dotnet restore -a $TARGETARCH
COPY . .
RUN dotnet publish -c Release -o /app -a $TARGETARCH --self-contained false --no-restore

FROM mcr.microsoft.com/dotnet/runtime:8.0.33 AS final
WORKDIR /app
COPY --from=build /app .
# .NET 8 images ship a non-root "app" user; APP_UID is its numeric id (1654)
USER $APP_UID
ENTRYPOINT ["dotnet", "Worker.dll"]
