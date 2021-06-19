# Charity Run Helper

**Disclaimer:** This project as-is is not ready for production due to lacking security

A Flutter and Firebase application with the goal of reducing paperwork when organizing charity runs. Intended to be used as both mobile and web app.

## Setup

1. Customize the package name (change from *com.feliskio.cr_helper*)
2. [Install Flutter](https://flutter.dev/docs/get-started/install) according to your platform needs
3. Install dependencies by running `flutter pub get` in the project directory (if not automatically done by your IDE)
4. Create a new project in the [Firebase console](https://console.firebase.google.com/)
5. Add apps for all platforms to your Firebase project and add the configuration files according to the FlutterFire documentation: [Android](https://firebase.flutter.dev/docs/installation/android#generating-a-firebase-project-configuration-file), [iOS](https://firebase.flutter.dev/docs/installation/ios#installing-your-firebase-configuration-file), [Web](#configuring-web)
6. Install [firebase-tools](https://github.com/firebase/firebase-tools)
7. Configure Cloud Functions [environment variables](#configuring-environment-variables)
8. [Build for web](#running-the-app)
9. Execute `firebase deploy` in the project directory and follow the wizard

### Configuring Web

To configure the web version you need to create a file called *configure-firebase.js* inside the *web* directory. Paste the *firebaseConfig* object you got from the Firebase console.[]

### Configuring environment variables

Firebase offers the ability to set environment variables for Cloud Functions using the `firebase functions:config:set` command. You need to specify the following values:

* `smtp.host` SMTP server host
* `smtp.port` SMTP server port
* `smtp.user` SMTP username (often an email address)
* `smtp.password` SMTP password/access key
* `smtp.domain` Email sending base domain. Make sure your credentials support sending from any user on this domain.
* `hosting.base-url` Protocol and domain of the site hosting the web version (e.g. *https://your-project.web.app*)

## Running the app

Use `flutter run --no-sound-null-safety` to run the app on an attached device or emulator in debug mode.

Build the app for production using `flutter build [platform] --no-sound-null-safety`.

The *--no-sound-null-safety* flag is required because a package which doesn't support null safety (yet) was used.
