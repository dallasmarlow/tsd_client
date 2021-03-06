Gem::Specification.new do |gem|
  gem.name     = 'tsd_client'
  gem.version  = '0.1.1'
  gem.authors  = ['Dallas Marlow', 'Shangpeng Sun']
  gem.email    = ['dallasmarlow@gmail.com']
  gem.summary  = 'OpenTSDB client'
  gem.homepage = 'https://github.com/dallasmarlow/tsd_client'

  gem.files = [
    'lib/tsd_client.rb',
    'lib/tsd_client/format.rb',
  ]

  gem.require_paths = ['lib']
end
