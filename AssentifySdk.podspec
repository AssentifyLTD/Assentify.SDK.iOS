#
# Be sure to run `pod lib lint AssentifySdk.podspec` to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AssentifySdk'
  s.version          = '0.0.69'
  s.summary          = 'This iOS Pod provides integration with Assentify services.'

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC

  
  This iOS Pod provides integration with Assentify services.
  DESC

  s.homepage = 'https://github.com/AssentifyLTD/Assentify.SDK.iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Assentify' => 'info.assentify@gmail.com' }
  s.source           = { :git => 'https://github.com/AssentifyLTD/Assentify.SDK.iOS.git', :tag => s.version.to_s }
  
  s.documentation_url = 'https://github.com/AssentifyLTD/Assentify.SDK.iOS/blob/main/README.md'

  s.ios.deployment_target = '15.0'

  s.static_framework = true
  
  
  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5']


  s.source_files = 'AssentifySdk/Classes/**/*'
  s.resources = [
  "best-fp16.tflite",
  "classes.txt",
  "card_background.svg",
  "face_background.svg",
  "transmitting_background.svg",
  "check-liveness.tflite",
  "audio_card_success.mp3",
  "audio_face_success.mp3",
  "audio_wrong.mp3",
  "down.gif",
  "up.gif",
  "right.gif",
  "left.gif",
  "wink_left.gif",
  "wink_right.gif",
  "blink.gif",
  "error_layout.svg",
  "success_layout.svg",
  "qr_background.svg"
  ]
  
  s.frameworks = 'UIKit'
  s.dependency 'TensorFlowLiteSwift' , '2.7.0'
  s.dependency 'SVGKit'
  s.dependency 'GoogleMLKit/FaceDetection'
  s.dependency 'NFCPassportReader'
  s.dependency 'Clarity'
  s.dependency 'Bugsnag'
  s.dependency 'BugsnagPerformance'




  # s.resource_bundles = {
  #   'AssentifySdk' => ['AssentifySdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end
