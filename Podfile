platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

source 'https://gitlab.com/BCSBroker/iOS/brokerrepo.git'
source 'https://github.com/CocoaPods/Specs.git'

target :APICore do
  pod 'Moya/RxSwift'
  pod 'Moya'
  
  target :APICoreTests do
    inherit! :search_paths
    pod 'Moya/RxSwift'
    pod 'RxBlocking'
    pod 'Moya'
  end
end
