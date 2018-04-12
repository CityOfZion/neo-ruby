# frozen_string_literal: true

module Neo
  module SDK
    class Compiler
      module Handlers
        # Handlers for ruby features
        # See https://ruby-doc.org/core-2.3.0/doc/syntax_rdoc.html
        module Literals
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
        end
      end
    end
  end
end
