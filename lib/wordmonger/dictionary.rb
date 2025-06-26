module WordMonger
  class Dictionary
    attr_reader :name, :phrases, :words
    attr_accessor :abbreviations
    def initialize(name, abbreviations: {}, scanner: nil)
      @name = name
      self.scanner = scanner
      @phrases = {}
      @words = {}
      @abbreviations = abbreviations
      WordMonger.add_dictionary(self)
    end

    def scanner
      unless @scanner
        self.scanner = WordMonger.default_scanner
      end
      @scanner
    end

    def scanner=(scanner)
      @scanner = scanner.dup
      @scanner.dictionary = self if @scanner
    end

    def activate
      WordMonger.activate(self)
    end

    def add(phrase)
      @phrases[phrase.text] = phrase
    end

    def delete(phrase)
      text = phrase.is_a?(WordMonger::Phrase) ? phrase.text : phrase
      @phrases.delete(text)
    end

    def serialize
      @phrases.values.map { |value| value.serialize }
    end

    def add_abbreviation(abbreviation, abbreviates)
      @abbreviations[abbreviation] = abbreviates
    end

    def delete_abbreviation(abbreviation)
      @abbreviations.delete(abbreviation)
    end

    def add_word(word)
      @words[word.text] = word
    end

    def delete_word(word)
      text = word.is_a?(WordMonger::Word) ? word.text : word
      @words.delete(text)
    end
  end
end