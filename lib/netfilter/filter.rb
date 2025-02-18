class NetfilterManager
  class Filter
    attr_accessor :chain
    attr_accessor :type
    attr_accessor :definition

    delegate :namespace, :to => :chain

    def self.import(chain, data)
      data = data.symbolize_keys
      new(chain, data[:type], data[:definition])
    end

    def initialize(chain, type, definition)
      self.chain = chain
      self.type = type
      self.definition = definition
    end

    def to_s
      args*" "
    end

    def args
      [].tap do |args|
        definition.each_pair do |key, value|
          key = object_to_argument(key)
          value = object_to_argument(value)
          value = "#{namespace}-#{value}" if key == "jump" && namespace && !NATIVE_TARGETS.include?(value.downcase)
          args << "--#{key} #{value}"
        end
      end
    end

    def export
      {
        :type => type,
        :definition => definition,
      }
    end

    private

    def object_to_argument(data)
      data = data.to_s
      data = data.gsub("_", "-")
      data = data.upcase if NATIVE_TARGETS.include?(data.downcase)
      data = data.downcase if %w(arpreply mark).include?(data.downcase)
      data
    end
  end
end
