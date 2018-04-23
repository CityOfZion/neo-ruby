# frozen_string_literal: true

require 'yaml'

#:nodoc:
module Neo
  class << self
    attr_accessor :config
  end

  # Stores the Neo configuration.
  class Configuration
    DEFAULT_RPC_LIST = YAML.load_file(File.join(File.dirname(__FILE__), 'default_rpc_list.yml'))
    DEFAULT_P2P_LIST = YAML.load_file(File.join(File.dirname(__FILE__), 'default_p2p_list.yml'))
    DEFAULT_MAGIC = {
      'MainNet' => 'Ant',
      'TestNet' => 'Antt'
    }.freeze

    DEFAULT_DB_PATH = File.join(__dir__, '..', '..', '.data')

    def initialize
      self.rpc_nodes = Set.new
      self.p2p_nodes = Set.new
      self.network = 'TestNet'
      self.magic_word = DEFAULT_MAGIC[network]
      self.db_path = DEFAULT_DB_PATH
    end

    attr_accessor :rpc_nodes, :p2p_nodes, :magic_word, :db_path

    attr_reader :network

    def network=(net)
      @network = net
      rpc_nodes.merge DEFAULT_RPC_LIST[net] if DEFAULT_RPC_LIST.key? net
      p2p_nodes.merge DEFAULT_P2P_LIST[net] if DEFAULT_P2P_LIST.key? net
      self.magic_word = DEFAULT_MAGIC[net] if DEFAULT_MAGIC.key? net
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
