Pod::Spec.new do |s|
  s.name             = 'APICore'
  s.version          = '1.0.18'
  s.summary          = 'Модуль APICore'
  s.homepage         = 'https://gitlab.com/BCSBroker/iOS/apicore'
  s.author           = 'BCS'
  s.source           = { :git => 'https://gitlab.com/BCSBroker/iOS/apicore.git', :tag => s.version.to_s }
  s.license      = { :type => 'MIT', :file => "LICENSE" }
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.module_name  = 'APICore'  
  s.source_files  = 'APICore/**/*.swift'
  s.dependency 'Moya', '~> 13.0.1'
  s.dependency 'Moya/RxSwift', '~> 13.0.1'
  s.dependency 'RxSwift', '~> 4.5'
end
