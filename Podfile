# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

platform :ios, '13.0'

target 'Quiz' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Quiz

  # UI
  pod 'MaterialComponents/Dialogs', '124.2.0'

  # Services
  pod 'FirebaseAnalytics', '10.19.0'
  pod 'FirebaseMessaging', '10.19.0'
  pod 'FirebaseCrashlytics', '10.19.0'
  pod 'FirebaseRemoteConfig', '10.19.0'
  
  # Network
  pod 'Alamofire', '5.10.2'

  # Database
  pod 'SQLite.swift', '0.14.1'

  # In App
  pod 'SwiftyStoreKit', '0.16.1'
  pod 'SwiftyJSON', '5.0.1'
  pod 'TPInAppReceipt', '3.3.4'
  
  # Logger
  pod 'SwiftyBeaver', '1.9.5'

  # Test
  target 'QuizTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'QuizUITests' do
    # Pods for testing
  end
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
