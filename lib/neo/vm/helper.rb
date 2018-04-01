# frozen_string_literal: true

module Neo
  module VM
    # Helper methods
    module Helper
      module_function

      def unwrap_array(value)
        case value
        when Array then value
        # :nocov:
        else value raise NotImplementedError, value.inspect
        end
        # :nocov:
      end

      def unwrap_boolean(value)
        case value
        when TrueClass, FalseClass then value
        when Integer then !value.zero?
        # :nocov:
        else value raise NotImplementedError, value.inspect
        end
        # :nocov:
      end

      def unwrap_byte_array(value)
        case value
        when ByteArray then value
        when String then ByteArray.from_string(value)
        when Integer then ByteArray.from_integer(value)
        # :nocov:
        else value raise NotImplementedError, value.inspect
        end
        # :nocov:
      end

      def unwrap_integer(value)
        case value
        when Integer then value
        when TrueClass, FalseClass then value ? 1 : 0
        when ByteArray then value.to_integer
        # :nocov:
        else value raise NotImplementedError, value.inspect
        end
        # :nocov:
      end

      def unwrap_string(value)
        case value
        when String then value
        when ByteArray then value.to_string
        # :nocov:
        else value raise NotImplementedError, value.inspect
        end
        # :nocov:
      end
    end
  end
end
