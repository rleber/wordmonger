# Equivalents are a set of text texts with equivalent meaning
# Equivalents have a preferred value, which is the first in the list
module WordMonger
  class Equivalents
    class PreferredNotFound < StandardError; end

    def self.normalize_text(text)
      text.downcase
    end

    attr_reader :texts
    attr_accessor :attributes
    def initialize(*texts, attributes: nil)
      texts = texts.flatten # In case someone passes an array
      @texts = texts.map { |text| normalize_text(text) }
      @attributes = nil
    end

    def normalize_text(text)
      self.class.normalize_text(text)
    end

    def add(text, preferred: false)
      text = normalize_text(text)
      if preferred
        @texts.unshift(text)
      else
        @texts << text
      end
    end

    def has_attributes?
      attributes && attributes.size > 0
    end


    def add_attribute(name, value)
      @attributes ||= {}
      @attributes[name] ||= []
      @attributes[name] << value
    end

    def preferred_text
      @texts.first
    end

    def include?(text)
      text = normalize_text(text)
      @texts.include?(text)
    end

    def index(text)
      @texts.index(text)
    end

    def make_preferred!(text)
      text = normalize(text)
      i = index(text)
      raise PreferredNotFound, "#{text.inspect} is not in #{self.inspect}" unless i
      @texts.delete_at(i)
      @texts.unshift(text)
    end

    def merge!(other_equivalent)
      @texts += other_equivalent.texts
    end

    def to_hash
      WordMonger.object_to_hash(self, :texts)
    end

    def serialize
      serialized_texts = WordMonger.serialize_array(@texts)
      serialized_hash = {texts: serialized_texts}
      serialized_hash[:attributes] = attributes if has_attributes?
      WordMonger.serialize_hash(serialized_hash, flatten: true)
    end
  end
end