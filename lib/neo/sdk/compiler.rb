# frozen_string_literal: true

require 'logger'
require 'parser/current'

module Neo
  module SDK
    # Compile ruby source code into neo Bytecode
    class Compiler
      autoload :Handlers,  'neo/sdk/compiler/handlers'
      autoload :Processor, 'neo/sdk/compiler/processor'

      attr_reader :root,
                  :tree,
                  :return_type,
                  :param_types,
                  :logger,
                  :builder

      def initialize(source, logger = nil)
        @source  = source
        @tree    = Parser::CurrentRuby.parse source
        @builder = Builder.new
        @logger  = logger || default_logger

        main_node = extract_main
        _name, args_node, = *main_node

        entry = @builder.emit :NOP
        @builder.emit :NEWARRAY
        @builder.emit :TOALTSTACK
        @root = Processor.new(nil, self, @logger)
        @root.process args_node
        @root.process @tree

        raise NotImplementedError if @root.depth > 16
        entry.update name: "PUSH#{@root.depth}".to_sym

        extract_parameters
        link_method_calls
        resolve_jump_targets
      end

      def link_method_calls
        builder.operations.each do |op|
          next unless op.name == :CALL
          method_name = op.data
          target = op.scope.find_definition(method_name)
          logger.error "No method: #{method_name}" unless target
          op.data = target.first
        end
      end

      def resolve_jump_targets
        builder.operations.each do |operation|
          target = operation.data
          next unless target.is_a? Operation
          jump_target = target.address - operation.address
          operation.data = ByteArray.from_int16(jump_target)
        end
      end

      def extract_parameters
        magic        = @source.scan(/^# ([[:alnum:]\-_]+): (.*)/).to_h
        @return_type = magic['return'].to_sym
        @param_types = magic['params'] ? magic['params'].split(', ').map(&:to_sym) : []
      end

      def bytes
        ByteArray.new builder.operations.flat_map(&:bytes)
      end

      def length
        @entry_point.length
      end

      def find_local(*)
        nil
      end

      def find_definition(*)
        nil
      end

      def extract_main
        main_node = nil

        if @tree.type == :def
          main_node = @tree if @tree.children.first == :main
        else
          main_node = @tree.children.find { |node| node.type == :def && node.children.first == :main }
        end

        logger.warn 'No main method' unless main_node
        main_node
      end

      # :nocov:
      def default_logger
        logger = Logger.new STDOUT
        colors = { 'WARN' => 31, 'INFO' => 32, 'DEBUG' => 33 }
        logger.formatter = proc do |severity, _datetime, _progname, msg|
          "#{"\e[#{colors[severity]}m#{severity}\e[0m".ljust(9)} #{msg}\n"
        end
        logger
      end
      # :nocov:

      class << self
        def load(path, logger = nil)
          File.open(path, 'r') do |file|
            source = file.read
            compiler = Compiler.new source, logger
            Script.new compiler.bytes, source, compiler.return_type, compiler.param_types
          end
        end
      end
    end
  end
end
