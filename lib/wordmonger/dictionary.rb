module WordMonger
  class Dictionary

    attr_reader :name, :phrases, :words
    attr_reader :synonyms, :synonym_substitutions 
    attr_reader :wordings, :wording_substitutions
    def initialize(name, scanner: nil)
      @name = name
      self.scanner = scanner
      reset!
      WordMonger.add_dictionary(self)
    end

    def reset!
      @phrases = {}
      @words = {}
      @synonyms = {}
      @synonym_substitutions = {}
      @wordings = {}
      @wording_substitutions = {}
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

    def add_phrase(phrase)
      @phrases[phrase.text] = phrase
    end

    def add_word(word)
      @words[word.text] = word
    end

    def delete_word(word)
      text = word.is_a?(WordMonger::Word) ? word.text : word
      @words.delete(text)
    end

    def delete_phrase(phrase)
      text = phrase.is_a?(WordMonger::Phrase) ? phrase.text : phrase
      @phrases.delete(text)
    end

    # Serialize words, synonyms, and wordings
    def serialize
      {
        words: @words.values.map { |value| value.serialize },
        phrases: @phrases.values.map { |value| value.serialize },
        synonyms: @synonyms.values.map { |value| value.serialize },
        wordings: @wordings.values.map { |value| value.serialize }
      }
    end

    def synonym(synonym)
      synonym = synonym.preferred if synonym.respond_to?(:preferred)
      @synonyms[Equivalents.normalize_string(synonym)]
    end

    def add_synonym(synonym)
      @synonyms[synonym.preferred] = synonym
      synonym.strings[1..].each do |syn|
        @synonym_substitutions[syn] = synonym.preferred
      end
    end

    def delete_synonym(synonym)
      synonym = synonym.preferred if synonym.respond_to?(:preferred)
      synonym_object = @synonyms[synonym]
      if synonym_object
        @synonyms.delete(synonym)
        synonym_object.strings[1..].each do |syn|
          @synonym_substitutions.delete(syn)
        end
      end
    end

    def wording(wording)
      wording = wording.preferred if wording.respond_to?(:preferred)
      wording = wording.text if wording.respond_to?(:text)
      @wordings[Equivalents.normalize_string(wording)]
    end

    def add_wording(wording)
      @wordings[wording.preferred] = wording
      wording.strings[1..].each do |wd|
        @wording_substitutions[wd] = wording.preferred
      end
    end

    def delete_wording(wording)
      wording = wording.preferred if wording.respond_to?(:preferred)
      wording_object = @wordings[wording]
      if wording_object
        @wordings.delete(wording)
        wording_object.strings[1..].each do |wd|
          @wording_substitutions.delete(wd)
        end
      end
    end

    def matching_phrases(phrase, in_lexicon: false, in_order: true)
      search_phrase = Phrase.new(phrase, remember: false)
      matches = []
      if in_order
        search_text = search_phrase.normalized(remember: false).text
        binding.pry
        matching_phrase = wording(search_text)
        if matching_phrase
          if matching_phrase.lexicon == search_phrase.lexicon || !in_lexicon
            matches << matching_phrase
          end
        end
      else
        search_text = search_phrase.normalized_words(remember: false).sort
        @wordings.find do |wording|
          comparison_text = wording.preferred.normalized_words(remember: false).sort
          if comparison_text == search_text
            if matching_phrase.lexicon == search_phrase.lexicon || !in_lexicon
              matches << wording
            end
          end
        end
      end
      matches
    end
  end
end