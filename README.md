# PrivacyBlur

![Logo](./android/app/src/main/res/mipmap-hdpi/ic_launcher.png)

A cross-platform application to obfuscate sensitive data from images, targeting iOS and Android devices. Mainly written in [dart](https://dart.dev/) with the [Flutter](https://flutter.dev/) SDK.

The App is available on Google Playstore  and the the Appstore now!

<table style="border: none;">
  <tr>
    <td style="border: none; padding: 0px; text-align: right">
          <a href='https://f-droid.org/packages/de.mathema.privacyblur'>
          <img style='height: auto; width: 140px; object-fit: cover' alt='Get it on F-Droid' src='https://fdroid.gitlab.io/artwork/badge/get-it-on.png'/>
          </a>
    </td>
    <td style="border: none;">
      <a href='https://play.google.com/store/apps/details?id=de.mathema.privacyblur'><img width="140px" height="auto" alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'/></a>
    </td>
    <td style="border: none;">
      <a href="https://apps.apple.com/us/app/privacyblur/id1536274106">
        <object data="docs/assets/black.png" type="image/png">
          <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1619827200&h=9d23d850d1506bbe56180b2aa8ee51f7" alt="PrivacyBlur">
        </object>
      </a>
    </td>
  </tr>
</table>

## Table of contents

- [Privacy Blur](#privacyblur)
  - [Table of contents](#table-of-contents)
  - [Project description](#what-does-the-app-do)
  - [Code style](#code-style)
  - [Internationalization](#internationalization)
  - [Features](#features)
  - [Setup](#flutter-sdk-setup)
    - [windows](#windows)
    - [macOS](#macos)
  - [Building](#Building)
    - [Flavors](#flavors)
    - [iOS](#ios-building)
    - [Android](#android-building)
  - [Structure](#structure)
  - [Architecture](#architecture)
    - [Navigation](#navigation)
    - [Dependency Injection](#dependency-injection)
    - [BloC](#bloc)
    - [Views](#views)
    - [Widgets](#widgets)
      - [Stateful Widgets](#stateful-widgets)
      - [Adaptive Widgets](#adaptive-widgets)
  - [Internationalization](#internationalization)
  - [Theme](#theme)
  - [Assets](#assetsresources)
    - [Icons](#icons)
    - [Images](#images)
    - [Strings](#strings)
  - [Image Manipulation Library](#imagefilter-library-description)
  - [Testing](#testing)
  - [Dependencies](#dependencies)
  - [License](#license)


## What does the app do?

The project is aiming to provide a free, clean and simple solution for users to manipulate image data.
No in-app purchases. No ads. No watermark. No hassle. Free forever because privacy shouldn't cost anything. Free because we care!

## Code style

We have some restrictions about the code style of this project.
You can find all requirements in the [CONTRIBUTING](CONTRIBUTING.md#code-style)

## Features

- Face detection
- Blur / Pixelate effect
- Fine / coarse grain effect
- Round / Square area
- Export to your camera roll

## Flutter SDK Setup

The app is running on Flutter SDK 2.2 and dart 2.13.
Before working with the project, please make sure to run ``flutter upgrade``.

### Windows
click here:
[Installation Guide on Windows](https://flutter.dev/docs/get-started/install/windows)

### macOS
click here:
[Installation Guide on MacOS](https://flutter.dev/docs/get-started/install/macos)

## Building 
:warning: :bangbang:
### Flavors

In order to upload to different Platforms/Stores we implemented build flavors.

- foss (for FDroid)
- production (for all other Platforms)

#### Building with Flavors

**This section is very important if you´re trying to run the project on you own!**
The application is available in different flavors:

- foss (version without MLKit - FaceDetection)
- full (self-explanatory)

Running with default commands: ```flutter run``` and ```flutter build``` wont work anymore here.
Make sure to read this section and configure your build-types according to the flavors.

More on how to configure build-types in you IDE:

- Click in the top bar of your IDE on the corresponding Build-Configuration tile
- Click "Edit Configurations" (IntelliJ)
- Click "+"-Button to add a configuration
- Enter the entry point - e.g.: ``[PROJECT_PATH]/lib/main-[flavor_name].dart``
- Enter the build flavor

![Instructions](docs/assets/blur1633609294856.jpg)


For Debugging:
````bash
flutter run --flavor [flavor_name] -t lib/[entry_flavor_file].dart
````
For Deployment:
````bash
flutter build [platform] --flavor [flavor_name] -t lib/[entry_flavor_file].dart
````

The app is targeted for iOS and Android on Phones and Tablets.
Desktop and Web Platform may cause issues and are currently not planned.

It's recommended to run:
```bash
flutter clean
flutter pub get
```
as soon as building issues appear.


### iOS-Building

[Flutter guide for building on iOS](https://flutter.dev/docs/deployment/ios)

You will need an MacOS Machine to be able to run a Flutter iOS application.
Please also make sure you installed the correct version of cocoapods and Xcode on your machine.

For deployment information visit: [Deployment Guide iOS](https://flutter.dev/docs/deployment/ios)

### Android-Building

[Flutter guide for building on Android](https://flutter.dev/docs/deployment/android)

No further requirements for building an android version.

For deployment information visit: [Deployment Guide Android](https://flutter.dev/docs/deployment/android)

## Structure

```
lib/--+--main.dart (entry point)
      +--main_foss.dart (entry point for foss flavor)
      |
      +--resources/--- images, fonts, strings, etc...
      |
      +--------src/--+------app.dart (some inital code)
                     +------app_container.dart (app dependency initialization)
                     +------router.dart (navigation handling)
                     +------di.dart (dependency injection) 
                     |
                     |
                     +--screens/--screen_name/
                     |                  +--helpers/-- (garbage place, like many events and states)
                     |                  +--widgets/-- (internal widgets for this screen)
                     |                  |
                     |                  +--repo.dart
                     |                  +--bloc.dart
                     |                  +--view.dart                                  
                     |                 
                     |
                     +--widgets/-- (common widgets for application)
                     |
                     |
                     +----utils/-- (some utils for application if necessary)
```

## Architecture

In order to build a maintainable, scalable and testable project, the app is build with an architectural pattern and file structure.
For readability purposes we limited the file size to **300 lines**.

### Navigation

The navigation is kept relatively simple with Flutter Navigation v1.
The ``router.dart`` file includes all routing and navigation logic in 2 classes.

- ScreenNavigator: implements and provides methods to enable routing
- AppRouter: declares all routes and their configuration

To be able to test each route individually the AppRouter has multiple constructors. A constructor must also be defined for each route.
The constructor then overwrites what is the actual initial route and boots up at the specified location.

Each route receives the Dependency Injection instance, and the AppRouter instance itself. Optional arguments follow as 3rd parameter.

### Dependency Injection

The Dependency Injection Class is used to inject all testable parts of the application in the right order.
It holds the provider for different blocs and repositories. The instance of the class must be passed to the view, so that they can access all dependencies in the Provider/Consumer structure.

### BLoC

In dart its useful to work with Streams, and the Provider pattern. That's why we chose the popular [BLoC](https://bloclibrary.dev/#/) pattern.
It makes sense to implement a bloc for each screen, but only if it needs to hold and manage data. Usually the bloc receives the corresponding Repositories from the Dependency Injection.

The BLoC class file is located in the same directory as the screen view.
Each View is using ``events`` to trigger ``state`` updates inside the bloc, which are consumed by the view again.
Events and states are located inside the helpers' directory on the screens' folder.

To be able to decide which state should be emitted, the bloc consumes events and handles the decision based on that.
It's important to always yield something after each event, otherwise the UI won't be updated and blocked.

```dart
Stream<SampleState> mapEventToState(SampleEvent event) async* {
  if (event is EventOne) {
    yield* handleStateOneChange(event);
  } else if (event is EventTwo) {
    yield* handleStateTwoChange(event);
  } ...
}
```
**The bloc works as the logic component of the screen and separates all logic from the UI. Thus, the bloc also shouldn't handle any UI parts.**

### Views

Each View represents the widget, that is used as screen in the Navigation route. It should only define the UI and consume/use state.
Primarily it's better to implement screens as StatelessWidgets and only rerender the parts of the screen which really need to be rendered after state updates.

A Bloc-Screen is wrapped by a MultiBlocProvider, which gets the corresponding bloc from the Dependency Injection and makes it available through context for the nested BlocConsumer.
```dart
return MultiBlocProvider(
    providers: [_di.getSampleBloc()],
    child: BlocConsumer<SampleBloc, SampleState>(...)
```

On simple UI data changes as displaying a Toast Message we used the buildWhen condition of the bloc consumer to prevent a whole rerender. Only the MessageBar is drawn above the screen by the listener.
```dart 
BlocConsumer<SampleBloc, SampleState>(
  listenWhen: (_, curState) => (curState is SimpleState),
  buildWhen: (_, curState) => !(curState is SimpleState),
  listener: (_, state) {
    showMessageOnSimpleState(...)
  }
  ...
```

Most parts of the views are separated in own methods. This improves readability and modularity. As soon the file size exceeds 300 lines or widgets grow to a huge size it makes sense to move the widgets them to another file.

### Widgets

Widgets exist on common and screen scope level. Common Widgets are located in ``src/widgets`` and screen widgets in ``src/screen_name/widgets``.
Widgets on common level shouldn't implement screen specific configurations and should be made reusable with minimal setup.
Widgets on screen scope are either only used in this place, or their usage is very specific to the screen.

#### Stateful Widgets
Best practise for Widgets which hold state is to also manage it internally. For example:

```dart
class WidgetState extends State<WidgetWithState> {
  late double _initialValue;

  @override
  void didUpdateWidget(covariant DeferredSlider oldWidget) {
    _initialValue = widget._initialValue;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _initialValue = widget._initialValue;
    super.initState();
  }
  
  ... Widget build ...
  
  void onChanged(doubleValue) {
    setState(() {
      _initialValue = doubleValue;
    });
    this.widget.onChanged(doubleValue);
  }
}
```

#### Adaptive Widgets

The app is targeted for iOS and Android, but needs to look different on each platform.
That's why we split platform specific code (iOS/Android) inside ```src/widgets/adaptive_widgets_builder.dart```.
We saw, that Flutter is starting to build adaptive versions of Widgets.
When they will complete with this, we can remove and replace "builders" inside this file with the adaptive version of Flutter widgets.

## Internationalization

The app is translated into:
- :us: English (default language)
- :de: German

Translations live inside the ``lib/resources/i18n`` directory.
To add new languages you need to do the following:

- add lang code to supported languages
````dart
  var delegate = await LocalizationDelegate.create(
      ...
      supportedLocales: [..., '<language_code>']);
````

- add json file for lang code in ```lib/resources/i18n/<lang_code>.json```
- copy structure from an existing .json file
- As soon as new texts are added, the new keys need to be generated. Run: flutter ``flutter pub run build_runner build --delete-conflicting-outputs``


## Theme

The Theme is split into different platforms and additionally themeModes for android.
``theme_provider.dart``
- iosTheme (providing themeMode split iOS ThemeData)
- light (providing light android ThemeData)
- dark (providing dark android ThemeData)

Dark and Light mode are supported and depend on the system preference.
```dart
// AppBuilder widget
themeMode: ThemeMode.system,
```

## Assets/Resources

All assets/resources can be found in ``lib/resouces``.
Images, icons and other common resources should be placed here.

### Icons
Currently, the app is using a custom icon font which includes 4 icons for the image editing tools in the toolbar selection.
Fonts can be generated here: [fluttericon.com](https://www.fluttericon.com/).

__Do only include icons that are used inside the project!__

Additional flutter provides default icons that can be used either from ``CupertinoIcons`` or ``Icons`` Class.
To handle icons from one place the project has the icons_provider class.
This is the place where one iconName can be defined and can have extra logic to split between platforms.

### Images

Images can be added here. To handle different screen resolutions with image sizes there is the possibility to add an image in x2 and x3 sizes for the referring screens.
On dart side its enough to load it like this: ``lib/resources/images/<image_name>``. Dart handles the split between the resolutions.

Currently, the app only uses the App logo which is essential on Launch-/Splash and Main-Screen. Its also recommended limiting the number of static image files, due to the fact that they extend the project size by a large amount.

### Strings

In this place all text strings that are used inside the application. It is planned to add i18n and i10n on a later stage of the project.
All strings inside here need to be moved to the translation .aab files then.

## ImageFilter library description
This library is a singleton. It uses very much memory while working, so its very bad idea to create few instances of this class.

Class can load and filter images.

Supported filters:
- Pixelate
- linear Blur (not Gaussian, too slow)

Class features:
- preview of changes before commit
- undo changes in some special area (erase tool)
- processing squared and rounded areas
- processing multiple areas in one transaction
- overriding processed pixels all together with selected filter

How to work with this class:
 ```dart
    import 'dart:ui' as img_tools;                           
            final file = File(filename);  
            final imageFilter = ImageAppFilter();
            var completer = Completer<img_tools.Image>();
            img_tools.decodeImageFromList(file.readAsBytesSync(), (result) {
              completer.complete(result);
            });
            var image = await completer.future;
            
            /// VERY IMPORTANT TO USE AWAIT HERE!!!
            var filteredImage = await imageFilter.setImage(_blocState.image);
            imageFilter.transactionStart();
            imageFilter.setMatrix(MatrixAppPixelate(20));
            imageFilter.apply2CircleArea(200, 200, 150);
            /// for preview before saving (only changed area of image will be updated)
            filteredImage = await imageFilter.getImage();

            imageFilter.setMatrix(MatrixAppBlur(20));
            imageFilter.apply2CircleArea(400, 400, 250);

            /// save to cached image, after that you can not cancel changes
            /// only if you load image again.
            imageFilter.transactionCommit();

            /// get saved image after transaction completed (complete merged image without changed part)
            filteredImage = await imageFilter.getImage();
```
### Methods
- **static void setMaxProcessedWidth(int)** - default 1000 for blur speed optimization we need to know maximum processed area width
- **Future\<ImageFilterResult\> setImage(dart:ui.Image)** - set image for filtering.
- **Future\<ImageFilterResult\> getImage()** - if transactions is active, will return only changed area without background image. If transaction is closed - will return full updated images.
- **void transactionStart()** - open transaction for changes
- **void transactionCancel()** - reset changes and close transaction
- **void transactionCommit()** - apply changes from transaction and close transaction
- **void setFilter(ImageAppMatrix newMatrix)** - set current filter
- **void apply2SquareArea(int x1, int y1, double radius)** - apply selected filter to square area with center and radius
- **void apply2CircleArea(int x1, int y1, double radius)** - apply selected filter to circle area with center and radius
- **void cancelCurrent()** - cancel all current changes in active transaction
- **void cancelSquare(int, int, int, int)** - cancel changes in square area
- **void cancelCircle(int, int, int)** - cancel changes in circle area
### Filters
- MatrixAppPixelate(int blockSize)
- MatrixAppBlur(int blockSize) - Linear Blur

## Testing
run ``flutter test`` command in project root or test folder. All test-files must be ended with **_test.dart** suffix

## Dependencies

Do only add null-safety dependencies!
The application runs in sound null safety. Consequently, all dependencies added need to follow this restriction.

- flutter_styled_toast: used for alerts
- image_size_getter: get image sizes to decide if image should be rotated
- flutter_exif_rotation: used for initial rotation on image load
- url_launcher: used to open a link in main screen
- image_picker: used to get the access to the image library
- image: used for image file handling
- image_gallery_saver: used to save image to library
- permission_handler: used for accessing OS permission status
- path_provider: used to read OS image paths
- bloc: library for architectural pattern class
- flutter_bloc: flutter additional features for dart bloc library
- mockito: used for mocks in testing
- bloc_test: used for testing blocs
- flutter_translate: adding i18n to the app
- flutter_translate_gen: used to generate variables for static usage of translations

---

## License

MIT
