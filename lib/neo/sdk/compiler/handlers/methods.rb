# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      module Handlers
        # Handlers for ruby features
        # See https://ruby-doc.org/core-2.3.0/doc/syntax_rdoc.html
        module Methods
          def on_def(node)
            name, args_node, body_node = *node
            if name == :main
              process body_node
              emit :FROMALTSTACK
              emit :DROP
              emit :RET
            else
              on_def_method(name, args_node, body_node)
            end
            logger.info "Method `#{name}` defined."
          end

          def on_send(node)
            super
            receiver, name, *_args = *node

            case name
            when :==
              emit receiver.type == :int ? :NUMEQUAL : :EQUAL
            when :!=
              on_send_not_equal(receiver)
            else
              on_send_other(receiver, name)
            end
          end

          private

          def on_def_method(name, args_node, body_node)
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

          def on_send_not_equal(receiver)
            if receiver.type == :int
              emit :NUMNOTEQUAL
            else
              emit :EQUAL
              emit :NOT
            end
          end

          def on_send_other(receiver, name)
            if receiver && receiver.type == :const
              mod, klass = *receiver
              if !mod && NAMESPACES.include?(klass)
                prefix = klass == :ExecutionEngine ? 'System' : 'Neo'
                method = name.to_s.capitalize.gsub(/_([a-z])/) { Regexp.last_match(1).capitalize }
                emit :SYSCALL, [prefix, klass, method].join('.')
              end
            else
              emit_method name
            end
          end
        end
      end
    end
  end
end
