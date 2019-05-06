Pod::Spec.new do |s|
  s.name = 'ReactiveFirebase'
  s.version = '0.1.3'
  s.summary = 'ReactiveSwift extensions for Firebase.'

  s.homepage = 'https://github.com/edc1591/ReactiveFirebase'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Evan Coleman' => 'e@edc.me' }
  s.source = { :git => 'https://github.com/edc1591/ReactiveFirebase.git', :tag => "v#{s.version.to_s}" }
  s.social_media_url = 'https://twitter.com/edc1591'

  s.ios.deployment_target = '8.0'

  s.source_files  = 'Sources/**/*'
  s.dependency 'ReactiveSwift', '1.0.0-rc.3'
  
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase/Analytics'
  s.dependency 'Firebase/Database'
  s.dependency 'Firebase/Firestore'
  s.dependency 'Firebase/Messaging'
  s.dependency 'Firebase/Storage'

  s.frameworks = 'FirebaseCore', 'FirebaseDatabase', 'FirebaseAuth', 'FirebaseStorage', 'FirebaseFirestore', 'GoogleSymbolUtilities', 'GoogleInterchangeUtilities'
end
