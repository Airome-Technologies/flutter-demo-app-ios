# Flutter Demo App (iOS)

## Project Structure

The project consists of plugin files and application examples. Launch app at `example` folder in order to test the plugin.

The plugin and example app structures are identical:

- `lib/` - Dart files
- `ios/` - iOS corresponding files
- `android/` - Android corresponding files
- `pubspec.yaml` - Project's metadata

## Dependencies

Adding dependency to platform-specific PCSDK libraries is required to work with it.

### Adding PCSDK as dependency for iOS

In iOS dependency is setting up in `<your_project>/ios/Podfile`:
``` ruby
target 'Runner' do
   
   use_frameworks!

   pod 'PCSDKModule', :git => 'https://repo.paycontrol.org/git/ios/pcsdk.git'

end
```

PCSDK has been already integrated in the example app and depencendy has been added to `example/ios/Podfile`.

At build time the builder will launch CocoaPods and download the SDK's binary file.

### Adding PCSDK as dependency for Android

```
...TBW...
```
