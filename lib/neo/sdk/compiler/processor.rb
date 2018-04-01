# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      # Process an AST and convert it to bytecode, creates a local closure for variable scope
      class Processor < Parser::AST::Processor
        include Handlers

        attr_reader :logger,
                    :parent,
                    :definitions,
                    :locals,
                    :first,
                    :last

        def initialize(node, parent, logger = nil)
          @parent      = parent
          @logger      = logger
          @locals      = []
          @definitions = {}
          @first       = nil
          @last        = nil

          process node if node
        end

        def builder
          parent.builder
        end

        # TODO: include parent depth?
        def depth
          @locals.size
        end

        def process(node)
          return unless node.is_a? Parser::AST::Node
          handler = "on_#{node.type}".to_sym
          defined = Handlers.instance_methods.include? handler
          logger.warn "missing handler: #{handler}" unless defined
          super
        end

        def find_local(name)
          position = locals.index(name)
          return position if position
          parent.find_local name
        end

        def find_definition(method_name)
          definition = definitions[method_name]
          return definition if definition
          parent.find_definition method_name
        end

        def emit(name, param = nil)
          record builder.emit(name, param)
        end

        def emit_push(data)
          record builder.emit_push(data)
        end

        def record(op)
          op.scope = self
          @first ||= op
          @last = op
        end

        def emit_method(name)
          if OPERATORS.key? name
            emit OPERATORS[name]
          elsif (position = find_local name)
            emit :FROMALTSTACK
            emit :DUP
            emit :TOALTSTACK
            emit_push position
            emit :PICKITEM
          else
            emit :CALL, name
          end
        end
      end
    end
  end
end
