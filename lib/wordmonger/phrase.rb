module WordMonger
  class Phrase

    attr_reader :text, :dictionary
    def initialize(text, dictionary: nil)
      self.text = text
      @dictionary = dictionary || WordMonger.active_dictionary
      @dictionary.add(self)
    end

    def to_s
      @text
    end

    def serialize
      to_s
    end

    def scanner
      @dictionary.scanner
    end

    def text=(text)
      @text = text
      @words = nil
      @expanded = nil
    end

    # TODO Make words first-class objects?
    private def get_words
      return [] unless @text
      self.scanner.scan(@text)
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
        lowercase_word = word.text.downcase
        substitute = dictionary.abbreviations[lowercase_word]
        if substitute
          expanded_name = case_preserving_sub(expanded_name, word.text, substitute)
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