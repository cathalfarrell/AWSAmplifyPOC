# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'AmplifyPOC' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AmplifyPOC
  $awsVersion = '~> 2.9.0'
  pod 'AWSMobileClient', $awsVersion
  pod 'AWSAuthUI', $awsVersion       # Optional dependency required to use drop-in UI
  pod 'AWSUserPoolsSignIn', $awsVersion
  #pod 'AWSCore', '~> 2.9.6'
  pod 'AWSCore', $awsVersion

  # For API
  pod 'AWSAPIGateway', $awsVersion

  # For S3 Storage
  pod 'AWSS3', $awsVersion

  # For Documentation Standards
  pod 'SwiftLint'

  target 'AmplifyPOCTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'AmplifyPOCUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
