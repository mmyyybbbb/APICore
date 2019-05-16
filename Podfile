platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

source 'https://gitlab.com/BCSBroker/iOS/brokerrepo.git'
source 'https://github.com/CocoaPods/Specs.git'

def pods
  pod 'Moya/RxSwift', '~> 12.0.1'
  pod 'Moya', '~> 12.0.1'
end

target :APICore do
  pods
  
  target :APICoreTests do
    inherit! :search_paths
    pods
    pod 'RxBlocking', '~> 4.4.0'
  end
end
