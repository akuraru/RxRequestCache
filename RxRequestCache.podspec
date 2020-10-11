#
# Be sure to run `pod lib lint RxRequestCache.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxRequestCache'
  s.version          = '0.1.1'
  s.summary          = 'RxRequestCache is a framework for caching the results of URLRequest'

  s.description      = <<-DESC
  RxRequestCache is a framework for caching the results of URLRequest.
  RxRequestCache can be File Cacha.
  DESC

  s.homepage         = 'https://github.com/akuraru/RxRequestCache'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'akuraru' => 'akuraru@gmail.com' }
  s.source           = { :git => 'https://github.com/akuraru/RxRequestCache.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/akuraru'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/RxRequestCache/*'
  s.frameworks = 'CryptoKit'
  s.dependency 'RxSwift'
end
