module WordMonger
  class Word

    attr_reader :text, :dictionary, :synonyms
    def initialize(text, dictionary: nil)
      self.text = text
      @dictionary = dictionary || WordMonger.active_dictionary
      @synonyms = Synonyms.new(self.text)
      @dictionary.add_word(self)
    end

    def to_s
      @text
    end

    def serialize
      @text
    end

    def scanner
      @dictionary.scanner
    end

    def attributes
      @synonyms.attributes
    end

    def add_attribute(name, value)
      @synonyms.add_attribute(name, value)
    end

    def text=(text)
      @text = text
      @words = nil
      @expanded = nil
    end

    # TODO Make words first-class objects?
    private def get_words
      return [] unless @text
      @scanner.scan(@text)
    end

    def words
      @words ||= get_words
    end

    private def case_preserving_sub(text, from, to)
      match_regexp = Regexp.new(Regexp.escape(from), Regexp::IGNORECASE)
      from_text = text[match_regexp]
      to_text = to.downcase
      first_from_char = from_text[0]
      if first_from_char == first_from_char.upcase
        to_text = (to_text[0].upcase) + to_text[1..]
      end
      text.sub(from_text, to_text)
    end

    private def get_expanded
      expanded_name = self.text
      self.words.each do |word|
        lowercase_word = word.downcase
        substitute = dictionary.preferred_synonyms[lowercase_word]
        if substitute
          expanded_name = case_preserving_sub(expanded_name, word, substitute)
        end
      end
      expanded_name
    end

    def expanded
      @expanded ||= self.class.new(get_expanded)
    end

    def expanded_name
      expanded.phrase
    end

    def expanded_words
      self.expanded.words
    end
  end
end