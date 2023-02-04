Pod::Spec.new do |s|
  s.name             = 'TaxiDB'
  s.version          = '1.0.0'
  s.summary          = 'A short description of TaxiDB.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/cocomanbar/TaxiDB'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cocomanbar' => '125322078@qq.com' }
  s.source           = { :git => 'https://github.com/cocomanbar/TaxiDB.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '10.0'
  s.source_files = 'TaxiDB/Classes/**/*'
  
end
