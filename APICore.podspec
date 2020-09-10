Pod::Spec.new do |s|
  s.name             = 'APICore'
  s.version          = '3.2.7'
  s.summary          = 'Модуль APICore'
  s.homepage         = 'https://github.com/BCS-Broker/APICore'
  s.author           = 'BCS-Broker'
  s.source           = { :git => 'https://github.com/BCS-Broker/APICore.git', :tag => s.version.to_s }
  s.license      = { :type => 'MIT', :file => "LICENSE" }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.1'
  s.module_name  = 'APICore'  
  s.source_files  = 'APICore/**/*.swift'
  s.dependency 'Moya', '~> 14.0.0'
  s.dependency 'RxSwift', '~> 5.1.0'
end
