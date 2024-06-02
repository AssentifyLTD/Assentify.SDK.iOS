#
# Be sure to run `pod lib lint AssentifySdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AssentifySdk'
  s.version          = '0.0.1'
  s.summary          = 'This iOS Pod provides integration with Assentify services.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This iOS Pod provides integration with Assentify services.
                       DESC

  s.homepage         = 'https://assentify.com/home'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Assentify' => 'info.assentify@gmail.com' }
  s.source           = { :git => 'https://github.com/AssentifyLTD/Assentify.SDK.iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  s.static_framework = true

  s.source_files = 'AssentifySdk/Classes/**/*'
  s.resources = ["best-fp16.tflite", "classes.txt"]
  s.dependency 'TensorFlowLiteSwift'
  # s.resource_bundles = {
  #   'AssentifySdk' => ['AssentifySdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
