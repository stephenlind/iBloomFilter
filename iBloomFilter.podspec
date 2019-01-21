Pod::Spec.new do |s|
    s.name         = 'iBloomFilter'
    s.version      = '0.1'
    s.summary      = 'Bloom Filter Library for iOS/macOS'
    s.license      = 'MIT License'
    s.homepage     = 'https://github.com/stephenlind/iBloomFilter'
    s.authors      = { 'Stephen Lind' => 'stephen.lind@gmail.com' }
    s.source       = { :git => 'https://github.com/stephenlind/iBloomFilter.git' }
    s.requires_arc = true
    s.ios.deployment_target = '10.0'
    s.ios.source_files  = 'iBloomFilter/**/*.swift'
    s.osx.deployment_target = '10.10'
    s.osx.source_files  = 'iBloomFilter/**/*.swift'
end
