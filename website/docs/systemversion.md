Specifies the target operation system min and max versions.

```lua
systemversion ("value")
```

### Parameters ###

`value` is a colon-delimited string specifying the min and max version, `min:max`.

Ranges are currently only supported by the Windows targets with the Visual Studio actions.

Otherwise, only a minimum version can be set for macOS/iOS/tvOS targets with `xcode` and `gmake`-based actions.

### Applies To ###

Project.

### Availability ###

Premake 5.0 or later.

### Examples ###

```lua
filter "system:windows"
   systemversion "10.0.10240.0" -- To specify the version of the SDK you want
```

```lua
filter "system:windows"
   systemversion "latest" -- To use the latest version of the SDK available
```

```lua
filter "system:windows"
   systemversion "10.0.10240.0:latest" -- To specify a range of minumum and maximum versions
```

```lua
filter "system:macosx"
   systemversion "13.0" -- To target a minimum macOS deployment version of 13.0
```

### Apple Targets ###

Under macOS this sets the minimum version of the operating system required for the app to run and is equivalent to setting the `-mmacosx-version-min` (or newer `-mmacos-version-min`) compiler flag.

The same is true for iOS, iPadOS, and watchOS system targets except it is equivalent to setting the `-miphoneos-version-min` (or newer `-mios-version-min`) compiler flag.

:::warning
There is also a `-miphonesimulator-version-min` or `-mios-simulator-version-min` compiler flag, but iOS simulator targets are not yet supported by Premake.
:::

The same is also true for tvOS system targets except it is equivalent to setting the `-mappletvos-version-min` (or newer `-mtvos-version-min`) compiler flag.

:::warning
There is also a `-mappletvsimulator-version-min` or `-mtvos-simulator-version-min` compiler flag, but tvOS simulator targets are not yet supported by Premake.
:::

For the `xcode` action this is equivalent to the `MACOSX_DEPLOYMENT_TARGET`, `IPHONEOS_DEPLOYMENT_TARGET`, or `TVOS_DEPLOYMENT_TARGET` Xcode setting (depending on the target OS).

### Windows Targets ###

Under Windows and Visual Studio actions, this is equivalent to setting the `WindowsTargetPlatformVersion` (and `WindowsTargetPlatformMinVersion` if targetting `UWP`) MSBuild properties.

### See Also ###

* [system](system.md)
