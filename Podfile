# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'BosniaRoadTraffic' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for BosniaRoadTraffic
  pod 'RxDataSources'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Firebase/Firestore'
  pod 'Firebase'
  pod 'Firebase/Analytics'
end

deployment_target = '14.0'
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
      end
    end
    project.build_configurations.each do |bc|
      bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
    end
  end
  installer.pods_project.build_configurations.each do |config|
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  end
end
