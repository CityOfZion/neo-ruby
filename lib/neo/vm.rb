# frozen_string_literal: true

module Neo
  # Neo Virtual Machine
  module VM
    autoload :Context,     'neo/vm/context'
    autoload :Engine,      'neo/vm/engine'
    autoload :Helper,      'neo/vm/helper'
    autoload :Interop,     'neo/vm/interop'
    autoload :OpCode,      'neo/vm/op_code'
    autoload :Operations,  'neo/vm/operations'
    autoload :Stack,       'neo/vm/stack'
  end
end
