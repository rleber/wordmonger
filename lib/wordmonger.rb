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
  end
end