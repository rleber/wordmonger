module WordMonger

  class Error < StandardError; end
  class DuplicateDictionary < Error; end
  class UndefinedDictionary < Error; end

  class << self
    def dictionaries
      @@dictionaries ||= {}
    end

    def dictionary(name=nil)
      self.dictionaries[name]
    end

    def add_dictionary(dictionary)
      raise Error, "Can't add a nil dictionary" unless dictionary
      name = dictionary.name
      raise DuplicateDictionary if self.dictionary(name)
      @@dictionaries[name] = dictionary
    end
  end

end

require_relative 'wordmonger/version'
require_relative 'wordmonger/equivalents'
require_relative 'wordmonger/synonyms'
require_relative 'wordmonger/wordings'
require_relative 'wordmonger/phrase'
require_relative 'wordmonger/word'
require_relative 'wordmonger/dictionary'
require_relative 'wordmonger/scanner'

module WordMonger
  @@active_dictionary = WordMonger::Dictionary.new(nil)

  class << self

    def default_scanner
      @@default_scanner
    end

    def active_dictionary
      @@active_dictionary
    end

    def active_scanner
      @@active_dictionary.scanner
    end

    def default_scanner
      @@default_scanner ||= WordMonger::Scanner.default
    end

    def activate(name=nil)
      dictionary = dictionary(name)
      raise UndefinedDictionary unless dictionary
      @@active_dictionary = dictionary
    end

    def serialize_array(ary)
      serialized_array = ary.map do |element|
        element = element.serialize if element.respond_to?(:serialize)
        element
      end
      serialized_array
    end

    def object_to_hash(object, *keys)
      keys = keys.flatten
      hash = {}
      keys.each do |key|
        value = object.send(key)
        hash[key] = value if value
      end
      hash
    end

    def serialize_hash(hsh, flatten: false)
      serialized_hash = hsh.inject({}) do |hsh, (key, value)|
        value = value.serialize if value.respond_to?(:serialize)
        hsh[key] = value
        hsh
      end
      if flatten
        serialized_hash.size != 1 ? serialized_hash : serialized_hash.values.first
      else
        serialized_hash
      end
    end
  end
end