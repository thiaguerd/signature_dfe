lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'signature_dfe/version'

Gem::Specification.new do |spec|
  repo = 'https://github.com/thiaguerd/signature_dfe'
  spec.name          = 'signature_dfe'
  spec.version       = SignatureDfe::VERSION
  spec.authors       = ['Thiago Feitosa']
  spec.email         = ['mail@thiago.pro']
  spec.summary       = 'Assinatura digital de documentos fiscais eletrônicos'
  spec.description   = 'Assinatura digital de NF-e NFC-e NFA-e CT-e MDF-e BP-e'
  spec.homepage      = repo
  spec.license       = 'MIT'

  req_mgs = 'RubyGems >= 2.0 is required to protect against public gem pushes.'
  raise req_mgs unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = repo
  spec.metadata['changelog_uri'] = "#{repo}/blob/master/CHANGELOG"
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    rx = %r{^(test|spec|features)/}
    `git ls-files -z`.split("\x0").reject { |f| f.match(rx) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_development_dependency 'bundler', '~> 2.1.2'
  spec.add_development_dependency 'nokogiri', '~> 1.10.7'
  spec.add_development_dependency 'openssl', '~> 2.1.2'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.required_ruby_version = '>= 2.4'
end
