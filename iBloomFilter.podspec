Pod::Spec.new do |s|
    s.name         = 'iBloomFilter'
    s.version      = '0.1'
    s.summary      = 'Bloom Filter Library for iOS/macOS'
    s.license      = 'MIT License'
    s.author       = { 'Stephen Lind' }
    s.source       = { :git => 'https://github.com/stephenlind/iBloomFilter.git', :tag => "v#{s.version}" }
    s.requires_arc = true
    s.ios.deployment_target = '12.0'
    s.ios.source_files  = 'iBloomFilter/**/*.swift'
    s.osx.deployment_target = '10.13'
    s.osx.source_files  = 'iBloomFilter/**/*.swift'
end
