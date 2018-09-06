
Pod::Spec.new do |s|

  s.name         = "RobotMacPenSDK"
  s.version      = "2.0.1"
  s.summary      = "A SDK for RobotMacPenServer."
  s.description  = "A SDK for RobotMacPenServer.RobotMacPenServer."
  s.homepage     = "https://github.com/PPWrite/SDK_Mac"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "OneQuietCat" => "onequietcat@gmail.com" }
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/PPWrite/SDK_Macac.git", :tag => "#{s.version}" }
  s.requires_arc = true


  s.subspec 'RobotMacPenSDK' do |macpen|
    macpen.vendored_frameworks =  'RobotMacPenSDK/*.framework'
  end

end