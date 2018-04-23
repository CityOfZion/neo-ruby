# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      module Handlers
        # Handlers for ruby features
        # See https://ruby-doc.org/core-2.3.0/doc/syntax_rdoc.html
        module Assignments
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
            return unless position

            emit :FROMALTSTACK
            emit :DUP
            emit :TOALTSTACK
            emit_push position
            emit :PICKITEM
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
        end
      end
    end
  end
end
