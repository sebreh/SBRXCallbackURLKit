Pod::Spec.new do |s|
  s.name         = "SBRXCallbackURLParser"
  s.version      = "1.0.0"
  s.summary      = "Dead simple way to implement x-callback-url support in your app."
  s.homepage     = "https://github.com/sebreh/SBRXCallbackURLParser"
  s.license      = 'MIT'
  s.author       = { "Sebastian Rehnby" => "sebastian@rehnby.com" }

  s.source       = { :git => "https://github.com/sebreh/SBRXCallbackURLParser.git", :tag => s.version.to_s }
  s.source_files = 'SBRXCallbackURLParser/**/*.{h,m}'
  
  s.platform     = :ios, '5.0'
  s.requires_arc = true
end
