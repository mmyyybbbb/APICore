platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

source 'https://gitlab.com/BCSBroker/iOS/brokerrepo.git'
source 'https://github.com/CocoaPods/Specs.git'

def pods
  pod 'RxSwift', '~> 5.0.1'
  pod 'Moya', '~> 13.0.0'
end

target :APICore do
  pods
  
  target :APICoreTests do
    inherit! :search_paths
    pods
    pod 'RxBlocking'
  end
end


post_install do |installer|
  
  installer.pods_project.targets.each do |target|
    
    if ['Alamofire', 'Moya', 'Result', 'RxBlocking', 'RxSwift'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.0'
      end
    end
    
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
  
end

