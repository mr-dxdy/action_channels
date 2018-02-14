
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "action_channels/version"

Gem::Specification.new do |spec|
  spec.name          = "action_channels"
  spec.version       = ActionChannels::VERSION
  spec.authors       = ["German Antsiferov"]
  spec.email         = ["dxdy@bk.ru"]

  spec.summary       = %q{Easy server on websockets.}
  spec.description   = %q{Easy server on websockets.}
  spec.homepage      = "https://github.com/mr-dxdy/action_channels"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|examples)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'nio4r-websocket'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
