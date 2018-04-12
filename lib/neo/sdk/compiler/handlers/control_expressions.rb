# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      module Handlers
        # Handlers for ruby features
        # See https://ruby-doc.org/core-2.3.0/doc/syntax_rdoc.html
        module ControlExpressions
          def on_begin(node)
            node.children.each { |c| process(c) }
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
end
