require 'set'
require 'yaml'

#:nodoc:
module Neo
  class << self
    attr_accessor :config
  end

  # Stores the Neo configuration.
  class Configuration
    DEFAULT_RPC_LIST = YAML.load_file(File.join(File.dirname(__FILE__), 'default_rpc_list.yml'))

    def initialize
      self.node_list = Set.new
      self.network = 'TestNet'
    end

    attr_accessor :node_list

    attr_reader :network

    def network=(net)
      @network = net
      node_list.merge DEFAULT_RPC_LIST[net] if DEFAULT_RPC_LIST.key? net
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
