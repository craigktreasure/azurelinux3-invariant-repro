# Repro

## Summary

Upgrading a simple Blazor application (using Blazorise in this case) that was previously running just fine on .NET 8 in
the `8.0-azurelinux3.0-distroless-extra` or `8.0-cbl-mariner2.0-distroless-extra` containers to .NET 9 encounters
globalization errors with the use of `9.0-azurelinux3.0-distroless-extra`.

> **IMPORTANT**
>
> This issue only appears on ARM64 devices, which pull the ARM64 variant of the continer images by default.

## Instructions

### Pre-requisites

- [Docker](https://www.docker.com/products/docker-desktop/)

### To recreate the repro from this repository

I used a [Blazorise](https://blazorise.com/) application because that's where I encountered the issue. It's possible
this effects other applications as well, but I don't know believe the issue I'm reporting is specific to Blazorise.

1. Run the following commands to setup the code:

   ```shell
   mkdir repro
   cd repro
   dotnet new install Blazorise.Templates # At the time of writing, this installed version 1.6.0.
   dotnet new globaljson # Should result in version 9.0.100-rc.2.24474.11 being specified.
   dotnet new blazorise -n MyNewBlazoriseApp -p Bootstrap5 -bh Server -ut false -f net8.0 -o .\
   ```

2. Due to bugs in the template, remove entries to `MyNewBlazoriseApp.Client` in `MyNewBlazoriseApp.sln`.
3. Change `<TargetFramework>net8.0</TargetFramework>` to `<TargetFrameworks>net8.0;net9.0</TargetFrameworks>` in `MyNewBlazoriseApp.csproj` to target both .NET 8 and 9.
4. Create a Dockerfile at `MyNewBlazoriseApp/Dockerfile` with the following contents of the file [here](/MyNewBlazoriseApp/Dockerfile).

### Reproduce the issue

You can either run the `Run.ps1` script in the root of the repository or run
the commands manually below.

```shell
docker build -f .\MyNewBlazoriseApp\Dockerfile --force-rm --build-arg baseImageTag=8.0-cbl-mariner2.0-distroless-extra --build-arg sdkImageTag=9.0-azurelinux3.0 --build-arg TFM=net8.0 -t mynewblazoriseapp:net8-mariner2 .
docker build -f .\MyNewBlazoriseApp\Dockerfile --force-rm --build-arg baseImageTag=8.0-azurelinux3.0-distroless-extra --build-arg sdkImageTag=9.0-azurelinux3.0 --build-arg TFM=net8.0 -t mynewblazoriseapp:net8-azurelinux3 .
docker build -f .\MyNewBlazoriseApp\Dockerfile --force-rm --build-arg baseImageTag=9.0-noble-chiseled-extra --build-arg sdkImageTag=9.0-noble --build-arg TFM=net9.0 -t mynewblazoriseapp:net9-noble .
docker build -f .\MyNewBlazoriseApp\Dockerfile --force-rm --build-arg baseImageTag=9.0-azurelinux3.0-distroless-extra --build-arg sdkImageTag=9.0-azurelinux3.0 --build-arg TFM=net9.0 -t mynewblazoriseapp:net9-azurelinux3 .
docker run --rm -it -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development mynewblazoriseapp:net8-mariner2
# Open http://localhost:8080 and observe the working site. Hit ctrl+c to exit.
docker run --rm -it -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development mynewblazoriseapp:net8-azurelinux3
# Open http://localhost:8080 and observe the working site. Hit ctrl+c to exit.
docker run --rm -it -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development mynewblazoriseapp:net9-noble
# Open http://localhost:8080 and observe the working site. Hit ctrl+c to exit.
docker run --rm -it -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development mynewblazoriseapp:net9-azurelinux3
# Open http://localhost:8080 and observe the broken site. See errors in console output and dev console. Hit ctrl+c to exit.
```

The error output encountered using .NET 9 with `9.0-azurelinux3.0-distroless-extra`:

```text
System.Globalization.CultureNotFoundException: Only the invariant culture is supported in globalization-invariant mode. See https://aka.ms/GlobalizationInvariantMode for more information. (Parameter 'name')
cs is an invalid culture identifier.
   at System.Globalization.CultureInfo..ctor(String name, Boolean useUserOverride)
   at Blazorise.Localization.TextLocalizerService.AddLanguageResource(String cultureName)
   at Blazorise.Localization.TextLocalizerService.ReadResource()
   at Blazorise.Localization.TextLocalizerService..ctor()
   at System.RuntimeMethodHandle.InvokeMethod(Object target, Void** arguments, Signature sig, Boolean isConstructor)
   at System.Reflection.MethodBaseInvoker.InvokeWithNoArgs(Object obj, BindingFlags invokeAttr)
   at System.Reflection.RuntimeConstructorInfo.Invoke(BindingFlags invokeAttr, Binder binder, Object[] parameters, CultureInfo culture)
   at Microsoft.Extensions.DependencyInjection.ServiceLookup.CallSiteVisitor`2.VisitCallSiteMain(ServiceCallSite callSite, TArgument argument)
   at Microsoft.Extensions.DependencyInjection.ServiceLookup.CallSiteRuntimeResolver.VisitCache(ServiceCallSite callSite, RuntimeResolverContext context, ServiceProviderEngineScope serviceProviderEngine, RuntimeResolverLock lockType)
   at Microsoft.Extensions.DependencyInjection.ServiceLookup.CallSiteRuntimeResolver.VisitScopeCache(ServiceCallSite callSite, RuntimeResolverContext context)
   at Microsoft.Extensions.DependencyInjection.ServiceLookup.CallSiteVisitor`2.VisitCallSite(ServiceCallSite callSite, TArgument argument)
   at Microsoft.Extensions.DependencyInjection.ServiceLookup.CallSiteRuntimeResolver.Resolve(ServiceCallSite callSite, ServiceProviderEngineScope scope)
   at Microsoft.Extensions.DependencyInjection.ServiceLookup.DynamicServiceProviderEngine.<>c__DisplayClass2_0.<RealizeService>b__0(ServiceProviderEngineScope scope)
   at Microsoft.Extensions.DependencyInjection.ServiceProvider.GetService(ServiceIdentifier serviceIdentifier, ServiceProviderEngineScope serviceProviderEngineScope)
   at Microsoft.Extensions.DependencyInjection.ServiceLookup.ServiceProviderEngineScope.GetService(Type serviceType)
   at Microsoft.AspNetCore.Components.ComponentFactory.<>c__DisplayClass9_0.<CreatePropertyInjector>g__Initialize|1(IServiceProvider serviceProvider, IComponent component)
   at Microsoft.AspNetCore.Components.ComponentFactory.InstantiateComponent(IServiceProvider serviceProvider, Type componentType, IComponentRenderMode callerSpecifiedRenderMode, Nullable`1 parentComponentId)
   at Microsoft.AspNetCore.Components.RenderTree.Renderer.InstantiateChildComponentOnFrame(RenderTreeFrame[] frames, Int32 frameIndex, Int32 parentComponentId)
   at Microsoft.AspNetCore.Components.RenderTree.RenderTreeDiffBuilder.InitializeNewComponentFrame(DiffContext& diffContext, Int32 frameIndex)
   at Microsoft.AspNetCore.Components.RenderTree.RenderTreeDiffBuilder.InitializeNewSubtree(DiffContext& diffContext, Int32 frameIndex)
   at Microsoft.AspNetCore.Components.RenderTree.RenderTreeDiffBuilder.InsertNewFrame(DiffContext& diffContext, Int32 newFrameIndex)
   at Microsoft.AspNetCore.Components.RenderTree.RenderTreeDiffBuilder.InsertNewFrame(DiffContext& diffContext, Int32 newFrameIndex)
   at Microsoft.AspNetCore.Components.RenderTree.RenderTreeDiffBuilder.InsertNewFrame(DiffContext& diffContext, Int32 newFrameIndex)
   at Microsoft.AspNetCore.Components.RenderTree.RenderTreeDiffBuilder.AppendDiffEntriesForRange(DiffContext& diffContext, Int32 oldStartIndex, Int32 oldEndIndexExcl, Int32 newStartIndex, Int32 newEndIndexExcl)
   at Microsoft.AspNetCore.Components.RenderTree.RenderTreeDiffBuilder.ComputeDiff(Renderer renderer, RenderBatchBuilder batchBuilder, Int32 componentId, ArrayRange`1 oldTree, ArrayRange`1 newTree)
   at Microsoft.AspNetCore.Components.Rendering.ComponentState.RenderIntoBatch(RenderBatchBuilder batchBuilder, RenderFragment renderFragment, Exception& renderFragmentException)
   at Microsoft.AspNetCore.Components.RenderTree.Renderer.ProcessRenderQueue()
```
