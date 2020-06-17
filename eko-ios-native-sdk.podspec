#
#  Be sure to run `pod spec lint eko-ios-native-sdk.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "eko-ios-native-sdk"
  s.version      = "0.0.5"
  s.summary      = "A lightweight SDK that allows for easy integration of eko videos into an ios app."
  s.description  = <<-DESC
  The eko iOS SDK allows you to seamlessly integrate the eko player into your iOS apps and play any eko video in just 2 lines of code.
                   DESC

  s.homepage     = "https://github.com/EkoLabs/ios-native-sdk"
  s.license      = { :type => "Apache", :file => "LICENSE" }
  s.author             = { "Divya Mahadevan" => "divya@eko.com" }

  s.swift_version = "5.1"
  s.ios.deployment_target = "11.0"

  s.source       = { :git => "https://github.com/EkoLabs/ios-native-sdk.git", :tag => "#{s.version}" }
  s.source_files  = "sdk/EkoPlayerSDK/*.{h,m,swift}"
  s.framework = "UIKit"
  s.module_name = "EkoPlayerSDK"

end
