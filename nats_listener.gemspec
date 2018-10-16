
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nats_listener/version"

Gem::Specification.new do |spec|
  spec.name          = "nats_listener"
  spec.version       = NatsListener::VERSION
  spec.authors       = ["Igor Pavlov"]
  spec.email         = ["gophan1992@gmail.com"]

  spec.summary       = %q{
    This gem is used to simplify interaction between big applications/services via nats.
  }
  spec.description   = %q{
    Once upon a time in faraway company three developers decided to use nats for messaging between services.
    One of them started to integrate nats, met some problems, was fighting with them and as a result he had created this gem.
    This gem can help you to integrate nats and simplify its usage.
  }
  spec.homepage      = "https://github.com/beastia/nats_listener"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_dependency 'nats-pure'
  spec.add_dependency 'google-protobuf'
  spec.add_dependency 'nats-streaming'
end
