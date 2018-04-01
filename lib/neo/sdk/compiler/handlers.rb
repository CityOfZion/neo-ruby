# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module Neo
  module SDK
    class Compiler
      # Handle ruby features, emit Neo bytecode
      module Handlers
        OPERATORS = {
          :+      => :ADD,
          :-      => :SUB,
          :*      => :MUL,
          :/      => :DIV,
          :%      => :MOD,
          :~      => :INVERT,
          :&      => :AND,
          :|      => :OR,
          :"^"    => :XOR,
          :"!"    => :NOT,
          :>      => :GT,
          :>=     => :GTE,
          :<      => :LT,
          :<=     => :LTE,
          :<<     => :SHL,
          :>>     => :SHR,
          :-@     => :NEGATE,
          :"eql?" => :EQUAL,
          :"verify_signature" => :CHECKSIG
        }.freeze

        NAMESPACES = [
          :Account,
          :Asset,
          :Attribute,
          :Block,
          :Blockchain,
          :Contract,
          :Enrollment,
          :ExecutionEngine,
          :Header,
          :Input,
          :Output,
          :Runtime,
          :Storage,
          :Transaction,
          :Validator
        ].freeze

        def on_begin(node)
          node.children.each { |c| process(c) }
        end

        def on_def(node)
          name, args_node, body_node = *node
          if name == :main
            process body_node
            emit :FROMALTSTACK
            emit :DROP
            emit :RET
          else
            method_body = Processor.new nil, self, logger
            method_body.emit :NOP
            method_body.emit :NEWARRAY
            method_body.emit :TOALTSTACK
            method_body.process args_node
            method_body.process body_node
            method_body.emit :FROMALTSTACK
            method_body.emit :DROP
            method_body.emit :RET
            raise NotImplementedError if method_body.depth > 16
            method_body.first.update name: "PUSH#{method_body.depth}".to_sym
            definitions[name] = method_body
          end
          logger.info "Method `#{name}` defined."
        end

        def on_return(node)
          super
          emit :RET
        end

        def on_if(node)
          condition_node, then_node, else_node = *node
          process condition_node

          jump_a = emit :JMPIFNOT, :nil
          Processor.new then_node, self, logger
          if else_node
            jump_b = emit :JMP, :nil
            else_clause = Processor.new else_node, self, logger
            else_end = emit :NOP
            jump_a.update data: else_clause.first
            jump_b.update data: else_end
          else
            then_end = emit :NOP
            jump_a.update data: then_end
          end
        end

        def on_while(node)
          condition_node, body_node = *node
          jump = emit :JMP, :nil
          body = Processor.new body_node, self, logger
          condition = Processor.new condition_node, self, logger
          emit :JMPIF, body.first
          jump.update data: condition.first
        end

        # TODO: I think this is where I need to handle optional/default args
        def on_args(node)
          node.children.each.with_index do |arg, position|
            name, = *arg
            @locals << name
            emit :FROMALTSTACK
            emit :DUP
            emit :TOALTSTACK
            emit_push position
            emit_push 2
            emit :ROLL
            emit :SETITEM
          end
        end

        def on_lvar(node)
          super
          name, = *node
          position = find_local name

          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push position
          emit :PICKITEM
        end

        def on_const(node)
          super
          _mod, klass = *node
          position = find_local klass

          if position
            emit :FROMALTSTACK
            emit :DUP
            emit :TOALTSTACK
            emit_push position
            emit :PICKITEM
          end
        end

        # TODO: Refactor to remove duplication with on_args
        def on_lvasgn(node)
          super
          name, = *node
          position = find_local name
          # TODO: should be able to shadow variable scope
          unless position
            position = locals.length
            @locals << name
          end

          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push position
          emit_push 2
          emit :ROLL
          emit :SETITEM
        end

        # TODO: Refactor to remove duplication with on_lvasgn
        def on_casgn(node)
          super
          _scope, name, = *node
          position = find_local name
          if position
            # TODO: raise error, can't re-assign contstant
          else
            position = locals.length
            @locals << name
          end

          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push position
          emit_push 2
          emit :ROLL
          emit :SETITEM
        end

        def on_op_asgn(node)
          receiver, name, *args = *node
          position = find_local receiver.children.first
          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push position
          emit :PICKITEM
          process_all args
          emit OPERATORS[name] if OPERATORS.key? name
          process receiver
          emit :FROMALTSTACK
          emit :DUP
          emit :TOALTSTACK
          emit_push position
          emit :PICKITEM
        end

        def on_send(node)
          super
          receiver, name, *_args = *node

          case name
          when :==
            emit receiver.type == :int ? :NUMEQUAL : :EQUAL
          when :!=
            if receiver.type == :int
              emit :NUMNOTEQUAL
            else
              emit :EQUAL
              emit :NOT
            end
          else
            if receiver && receiver.type == :const
              mod, klass = *receiver
              if !mod && NAMESPACES.include?(klass)
                prefix = klass == :ExecutionEngine ? 'System' : 'Neo'
                method = name.to_s.capitalize.gsub(/_([a-z])/) { $1.capitalize }
                emit :SYSCALL, [prefix, klass, method].join('.')
              end
            else
              emit_method name
            end
          end
        end

        def on_str(node)
          value, = *node
          emit_push value
        end

        def on_int(node)
          value, = *node
          emit_push value
        end

        def on_false(*)
          emit_push false
        end

        def on_true(*)
          emit_push true
        end

        def on_or(*)
          super
          emit :BOOLOR
        end

        def on_and(*)
          super
          emit :BOOLAND
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
