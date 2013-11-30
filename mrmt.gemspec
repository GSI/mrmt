Gem::Specification.new do |s|
  s.name        = 'mrmt'
  s.version     = '0.0.1'
  s.date        = '2013-10-22'
  s.summary     = 'MediaWiki to Redmine Migration Tool'
  s.description = 'Scripts to migrate MediaWiki XML exports to Textile-formatted Redmine Wiki'
  s.authors     = ['GSI']
  s.email       = '2013@groovy-skills.com'
  s.files       = Dir.glob('lib/**/*') # `git ls-files`.split($/)
  s.homepage    = 'https://github.com/GSI/' + s.name
  s.license     = 'MIT'
end
