module WordMonger
  class Dictionary
    attr_reader :name, :phrases, :words
    attr_accessor :preferred_synonyms, :normalized_wordings
    def initialize(name, preferred_synonyms: {}, normalized_wordings: {}, scanner: nil)
      @name = name
      self.scanner = scanner
      @phrases = {}
      @words = {}
      @preferred_synonyms = preferred_synonyms
      @normalized_wordings = normalized_wordings
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

    def add_preferred_synonym(synonym, preferred_synonym)
      @preferred_synonyms[synonym] = preferred_synonym
    end

    def delete_preferred_synonym(synonym)
      @preferred_synonyms.delete(synonym)
    end

    def add_normalized_wording(wording, normalized_wording)
      synonymized_wording = Phrase.new(wording.downcase, remember: false).synonymize
      synonymized_normalized_wording = Phrase.new(normalized_wording.downcase, remember: false).synonymize
      @normalized_wordings[synonymized_wording] = synonymized_normalized_wording
    end

    def delete_normalized_wording(wording)
      synonymized_wording = Phrase.new(wording.downcase, remember: false).synonymize
      @normalized_wordings.delete(synonymized_wording)
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