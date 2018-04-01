# frozen_string_literal: true

module Neo
  module SDK
    # Simulated execution environment for contracts to run in.
    class Simulation
      autoload :Account,         'neo/sdk/simulation/account'
      autoload :Asset,           'neo/sdk/simulation/asset'
      autoload :Attribute,       'neo/sdk/simulation/attribute'
      autoload :Block,           'neo/sdk/simulation/block'
      autoload :Blockchain,      'neo/sdk/simulation/blockchain'
      autoload :Contract,        'neo/sdk/simulation/contract'
      autoload :Enrollment,      'neo/sdk/simulation/enrollment'
      autoload :ExecutionEngine, 'neo/sdk/simulation/execution_engine'
      autoload :Header,          'neo/sdk/simulation/header'
      autoload :Input,           'neo/sdk/simulation/input'
      autoload :Output,          'neo/sdk/simulation/output'
      autoload :Runtime,         'neo/sdk/simulation/runtime'
      autoload :Storage,         'neo/sdk/simulation/storage'
      autoload :Transaction,     'neo/sdk/simulation/transaction'
      autoload :Validator,       'neo/sdk/simulation/validator'

      include VM::Helper

      attr_reader :script, :return_type

      def initialize(script, return_type = nil)
        @script = script
        @return_type = return_type || script.return_type || :Void
        @context = Context.new

        # Not sure how to handle getting the script_hash from
        # the global scope in a way I like yet. However, I don't
        # think we'll have this problem once the compiler is working,
        # making @__script_hash__ a temporary hack.
        if vm_execution?
          @context.instance_variable_set :@__script_hash__, script_hash
          @context.instance_variable_set :@__script_container__, self
        else
          @context.instance_eval script
        end
      end

      def invoke(*parameters)
        result = @context.main(*parameters)
        cast_return result
      end

      def cast_return(result)
        case return_type
        when :Boolean   then unwrap_boolean    result
        when :Integer   then unwrap_integer    result
        when :String    then unwrap_string     result
        when :ByteArray then unwrap_byte_array result
        when :Void      then nil
        # :nocov:
        else raise NotImplementedError, "#{result.inspect} (#{return_type})"
        end
        # :nocov:
      end

      def script_hash
        vm_execution? ? script.hash : Digest::RMD160.hexdigest(script)
      end

      def vm_execution?
        script.is_a? Script
      end

      # :nocov:
      def get_message(*parameters)
        Simulation.get_message(*parameters)
      end
      # :nocov:

      # This is the context our smart contract is exected in.
      # See Simuation#new, main is overriden in ruby script executions
      class Context
        def main(*parameters)
          engine = Neo::VM::Engine.new(@__script_container__)
          engine.load_script Simulation.entry_script(@__script_hash__, parameters)
          engine.execute
          engine.evaluation_stack.pop
        end

        def verify_signature(*parameters)
          Simulation.verify_signature(*parameters)
        end
      end

      class << self
        def load(path, return_type = nil)
          File.open(path, 'rb') do |file|
            script = Script.new ByteArray.new(file.read)
            Simulation.new script, return_type
          end
        end

        def entry_script(script_hash, parameters)
          builder = Builder.new
          builder.emit_app_call script_hash, params: parameters
          Script.new builder.bytes
        end

        # :nocov:
        def verify_signature(*_params)
          raise('Stub or mock required.')
        end

        def check_witness(*_params)
          raise('Stub or mock required.')
        end

        def get_message(*_params)
          raise('Stub or mock required.')
        end
        # :nocov:
      end
    end
  end
end
