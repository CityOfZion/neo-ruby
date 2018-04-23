# frozen_string_literal: true

require 'set'
require 'sdbm'
require 'neo/configuration'
require 'neo/version'

# Neo Smart Economy
module Neo
  autoload :ByteArray, 'neo/byte_array'
  autoload :Account, 'neo/account'
  autoload :Asset, 'neo/asset'
  autoload :Block, 'neo/block'
  autoload :Contract, 'neo/contract'
  autoload :Key, 'neo/key'
  autoload :Network, 'neo/network'
  autoload :Node, 'neo/node'
  autoload :RemoteNode, 'neo/remote_node'
  autoload :Script, 'neo/script'
  autoload :Transaction, 'neo/transaction'
  autoload :Utils, 'neo/utils'
end
