module WordMonger
  class Dictionary

    class DuplicatePhrase < StandardError; end

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

    def delete_phrase(phrase)
      text = phrase.is_a?(WordMonger::Phrase) ? phrase.text : phrase
      @phrases.delete(text)
    end

    def add_word(word)
      @words[word.text] = word
    end

    def delete_word(word)
      text = word.is_a?(WordMonger::Word) ? word.text : word
      @words.delete(text)
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
      @synonyms[Equivalents.normalize_text(synonym)]
    end

    def add_synonym(synonym)
      @synonyms[synonym.preferred_word] = synonym
      synonym.words[1..].each do |syn|
        @synonym_substitutions[syn] = synonym.preferred_word
      end
    end

    def delete_synonym(synonym)
      synonym = synonym.preferred_word if synonym.respond_to?(:preferred_word)
      synonym_object = @synonyms[synonym]
      if synonym_object
        @synonyms.delete(synonym)
        synonym_object.words[1..].each do |syn|
          @synonym_substitutions.delete(syn)
        end
      end
    end

    def wording(wd)
      wd = wd.preferred_phrase if wd.respond_to?(:preferred_phrase)
      wd = wd.text if wd.respond_to?(:text)
      @wordings[Equivalents.normalize_text(wd).downcase]
    end

    def add_wording(new_wording)
      existing_wording = wording(new_wording)
      if existing_wording
        existing_wording.merge!(new_wording)
      else
        @wordings[new_wording.preferred_phrase.normalized_text.downcase] = new_wording
        new_wording.texts[1..].each do |wd|
          @wording_substitutions[wd] = new_wording.preferred_text
        end
      end
    end

    def delete_wording(wording)
      wording = wording.preferred_text if wording.respond_to?(:preferred_text)
      wording_key = Equivalents.normalize_text(wording).downcase
      wording_object = @wordings[wording_key]
      if wording_object
        @wordings.delete(wording_key)
        wording_object.texts[1..].each do |wd|
          @wording_substitutions.delete(wd)
        end
      end
    end

    def matching_phrases(phrase, case_insensitive: true, in_lexicon: false, in_order: true)
      search_phrase = Phrase.new(phrase, remember: false)
      search_text = search_phrase.normalized_text
      unless in_order
        search_text = search_phrase.get_words_for_text(search_text).sort.join(' ')
      end
      search_text = search_text.downcase if case_insensitive
      @wordings.select do |text, wording|
        comparison_text = wording.preferred_phrase.normalized_text
        unless in_order
          comparison_text = wording.preferred_phrase.get_words_for_text(comparison_text).sort.join(' ')
        end
        comparison_text = comparison_text.downcase if case_insensitive
        (comparison_text == search_text) &&
          (!in_lexicon || wording.lexicons.include?(search_phrase.lexicon))
      end
    end
  end
end