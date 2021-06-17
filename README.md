# Charity Run Helper

**Disclaimer:** This project as-is is not ready for production due to lacking security

A Flutter and Firebase application with the goal of reducing paperwork when organizing charity runs. Intended to be used as both mobile and web app.

## Setup

1. [Install Flutter](https://flutter.dev/docs/get-started/install) according to your platform needs
2. Install dependencies by running `flutter pub get` in the project directory (if not automatically done by your IDE)
3. Install [firebase-tools](https://github.com/firebase/firebase-tools)
4. Execute `firebase deploy` in the project directory and follow the wizard
5. Add apps for all platforms to your Firebase project and add the configuration files according to the FlutterFire documentation: [Android](https://firebase.flutter.dev/docs/installation/android#generating-a-firebase-project-configuration-file), [iOS](https://firebase.flutter.dev/docs/installation/ios#installing-your-firebase-configuration-file), [Web](#configuring-web)
6. Customize the package name (change from *com.feliskio.cr_helper*)

### Configuring Web

To configure the web version you need to create a file called *configure-firebase.js* inside the *web* directory. Paste the *firebaseConfig* object you got from the Firebase console.
