require 'set'
require 'yaml'

#:nodoc:
module Neo
  class << self
    attr_accessor :config
  end

  # Stores the Neo configuration.
  class Configuration
    DEFAULT_SEEDS = YAML.load_file(File.join(File.dirname(__FILE__), 'default_seeds.yml'))

    def initialize
      self.seeds = Set.new
      self.network = 'TestNet'
    end

    attr_accessor :seeds

    attr_reader :network

    def network=(net)
      @network = net
      seeds.merge DEFAULT_SEEDS[net] if DEFAULT_SEEDS.key? net
    end
  end

  self.config ||= Configuration.new

  # Used to configure the Neo library.
  #
  # @example
  #    Neo.configure do |c|
  #      c.network = 'MainNet'
  #    end
  #
  # @yield the configuration block
  # @yieldparam config [Neo::Configuration] the configuration object
  # @return [void]
  def self.configure
    yield config
  end
end
