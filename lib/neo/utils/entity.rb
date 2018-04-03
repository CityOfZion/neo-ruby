module Neo
  module Utils
    module Entity
      def initialize(attrs = {})
        attrs.each_pair do |attr, value|
          if respond_to?("#{attr}=", true)
            send("#{attr}=", value)
          else
            instance_variable_set(:"@#{attr}", value)
          end
        end
      end
    end
  end
end
