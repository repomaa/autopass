module Autopass
  module CoreExt
    # Extensions for core Hash class
    module Hash
      def deep_symbolize_keys
        each_with_object({}) do |(key, value), result|
          if value.is_a?(::Hash)
            value = value.deep_symbolize_keys
          else
            value
          end

          result[key.to_sym] = value
        end
      end

      ::Hash.prepend(self)
    end
  end
end
