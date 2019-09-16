Pod::Spec.new do |s|

  s.name         = "RobotMacPenSDK"
  s.version      = "2.2.3"
  s.summary      = "A SDK for RobotMacPenServer."
  s.description  = "A SDK for RobotMacPenServer.RobotMacPenServer."
  s.homepage     = "https://github.com/PPWrite/SDK_Mac"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "OneQuietCat" => "onequietcat@gmail.com" }
  s.platform     = :osx, '10.10'
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/PPWrite/SDK_Mac.git", :tag => "#{s.version}" }
  s.requires_arc = true
  s.vendored_frameworks =  'RobotPenMacSDK/*.framework'
  s.libraries = 'sqlite3'
  s.frameworks =  'ColorSync'


end