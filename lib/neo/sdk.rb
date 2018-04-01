# frozen_string_literal: true

require 'neo'
require 'neo/utils'
require 'neo/vm'

module Neo
  # Software Development Kit
  module SDK
    autoload :Builder,    'neo/sdk/builder'
    autoload :Compiler,   'neo/sdk/compiler'
    autoload :Operation,  'neo/sdk/operation'
    autoload :Script,     'neo/sdk/script'
    autoload :Simulation, 'neo/sdk/simulation'
    autoload :VERSION,    'neo/sdk/version'
  end
end
