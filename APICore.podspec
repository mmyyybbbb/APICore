Pod::Spec.new do |s|
  s.name             = 'APICore'
  s.version          = '1.0.6'
  s.summary          = 'Модуль APICore'
  s.homepage         = 'https://gitlab.com/BCSBroker/iOS/apicore'
  s.author           = 'BCS'
  s.source           = { :git => 'https://gitlab.com/BCSBroker/iOS/apicore.git', :tag => s.version.to_s }
  s.license      = { :type => 'MIT', :file => "LICENSE" }
  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'
  s.module_name  = 'APICore'  
  s.source_files  = 'APICore/**/*.swift'
  s.dependency 'Moya/RxSwift'
  s.dependency 'RxSwift' 
  s.dependency 'Moya'
end
