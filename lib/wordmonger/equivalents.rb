# Equivalents are a set of text strings with equivalent meaning
# Equivalents have a preferred value, which is the first in the list
module WordMonger
  class Equivalents
    class EmptyError < StandardError; end
    class PreferredNotFound < StandardError; end

    def self.normalize_string(string)
      string.downcase
    end

    attr_reader :strings
    attr_accessor :attributes
    def initialize(*strings, attributes: {})
      strings = strings.flatten # In case someone passes an array
      raise EmptyError, "#{self.class} cannot be empty" if strings.size == 0
      @strings = strings.map { |string| normalize_string(string) }
      @attributes = {}
    end

    def normalize_string(string)
      self.class.normalize_string(string)
    end

    def add(string, preferred: false)
      string = normalize_string(string)
      if preferred
        @strings.unshift(string)
      else
        @strings << string
      end
    end

    def add_attribute(name, value)
      attributes[name] ||= []
      attributes[name] << value
    end

    def preferred
      @strings.first
    end

    def include?(string)
      string = normalize_string(string)
      @strings.include?(string)
    end

    def index(string)
      @strings.index(string)
    end

    def make_preferred!(string)
      string = normalize(string)
      i = index(string)
      raise PreferredNotFound, "#{string.inspect} is not in #{self.inspect}" unless i
      @strings.delete_at(i)
      @strings.unshift(string)
    end

    def merge!(other_equivalent)
      @strings += other_equivalent.strings
    end

    def serialize
      serialized_strings = @strings.map do |string|
        if string.respond_to?(:serialize)
          string.serialize
        else
          string
        end
      end
      {
        strings: @strings,
        attributes: @attributes
      }
    end
  end
end