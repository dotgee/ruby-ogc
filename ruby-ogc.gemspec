# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rogc/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Philippe HUET"]
  gem.email         = ["philippe@dotgee.fr"]
  gem.description   = %q{Ruby lib for OGC manipulations}
  gem.summary       = %q{Ruby lib for OGC manipulations}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ruby-ogc"
  gem.require_paths = ["lib"]
  gem.version       = Ruby::Ogc::VERSION
end
