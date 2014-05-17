lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require "mech_warrior/version"

Gem::Specification.new do |s|
  s.name        = "mech_warrior"
  s.version     = MechWarrior::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Glusman"]
  s.email       = ["brian@glusman.me"]
  s.summary     = "Crawler and asset list/sitemap generator"
  s.licenses    = ["MIT", "BSD"]
  s.extensions = ["Rakefile"]

  s.description = <<-DESC
      Spider a web host with many mechanize agents concurrently, and generate an asset JSON
      and/or an XML sitemap of the result
  DESC


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "mechanize", '~> 2.7'
  s.add_runtime_dependency "xml-sitemap", '~> 1.3'
  s.add_runtime_dependency "celluloid", '~> 0'
  s.add_development_dependency "rake", '~> 0'
  s.add_development_dependency "rspec", '~> 2.14'
  s.add_development_dependency "fakeweb", '~> 1.3'
end