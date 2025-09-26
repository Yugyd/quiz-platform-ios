Quiz Platform (iOS)
===================

Quiz Platform is a Open Source knowledge testing platform for iOS. The project is based on the latest development
solutions and can act as a sample for other developers.

Coming soon app "Quiz Platform" on App Store.

# Apps built on Quiz Platform

200K+ downloads (total for 5 apps)

Download on the [App Store](https://itunes.apple.com/app/id1511742821).

Download on the [App Store](https://itunes.apple.com/app/id1511892537).

Download on the [App Store](https://itunes.apple.com/app/id1511890375).

Download on the [App Store](https://itunes.apple.com/app/id1511888213).

Download on the [App Store](https://itunes.apple.com/app/id1510892232).

# Stack

## Legacy

* Min SDK: iOS 13
* Language: Swift
* Architecture: MVP
* UI: Storyboard
* Navigation: Storyboard Navigation
* Threading: RxSwift
* DI: Manual service locator
* DB: SQLite.swift
* Firebase: Analytics, Crashlytics, Messaging, Remote Config
* Testing: Coming soon

## Modern

* Min SDK: iOS 15
* Language: Swift
* Architecture: MVVM
* UI: SwiftUI
* Navigation: Storyboard Navigation (Migrate Swift Navigation)
* Threading: Combine + Swift Concurrency (async/await)
* DI: Needle
* DB: Core Data (Migrate to Swift Data after update to iOS 17)
* Firebase: Analytics, Crashlytics, Messaging, Remote Config
* Testing: JUnit

# Contributions

[Guide](docs/CONTRIBUTION.md)

# Deploy

### First deploy

* Set up Firebase project
    * Create a new Firebase project
    * Add iOS app to the project
    * Set up Analytics, Crashlytics, Messaging, Remote Config
    * Fill Remote Config values
    * Set up APNs for Messaging
    * Download GoogleService-Info.plist and remote_config_defaults.plist
* Set up App Store Connect account
    * Create a new App ID in Apple Developer account
    * Create a new App record in App Store Connect
    * Create certificates and profiles for distribution and development
    * Set up signing in Xcode project settings (General + Signing & Capabilities)
* [Publish](#update-app-on-app-store)

### Update

* Set up the codebase
    * Edit data in GlobalScope
    * Edit data in StaticScope]
    * Edit standalone configuration
* Set up resources
    * Replace DisplayName in info and General project
    * Replace bundleName
    * Replace Resources
        * Assets
        * Databases
    * Check app icon
* Set up configuration files
    * Info.plist -> GADApplicationIdentifier
    * Product.plist -> Remove products
    * Update remote_config_defaults.plist
    * Update GoogleService-Info.plist
* Update metadata
    * Check the Info tab
    * Increase versions
* Build
    * Select your release profile
    * Select `Any iOS Device`
* Publish to App Store
    * Archive
    * Upload to App Store
    * Fill in the information in App Store Connect
    * Submit for review

# License

```
   Copyright 2025 Roman Likhachev

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```
