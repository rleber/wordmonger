module WordMonger
  class Synonyms < Equivalents
    def initialize(*words, attributes: {}, remember: true)
      words = words.flatten
      expanded_words = []
      words.each do |word|
        word = word.text if word.respond_to?(:text)
        word = Equivalents.normalize_text(word)
        synonym = WordMonger.active_dictionary.synonym(word)
        if synonym
          expanded_words += synonym.words
          synonym.unregister if remember
        else
          expanded_words << word
        end
      end
      super(*expanded_words.uniq, attributes: attributes)
      register if remember
    end

    def add(word, preferred: false)
      super(word, preferred: preferred)
      word.synonyms = self
      word
    end

    alias words texts
    alias preferred_word preferred_text

    def register
      WordMonger.active_dictionary.add_synonym(self)
    end

    def unregister
      WordMonger.active_dictionary.delete_synonym(self)
    end

    def make_preferred!(word)
      unregister
      super(word)
      register
    end

    def merge!(other_synonym)
      other_synonym.unregister
      super(other_synonym)
    end
  end
end