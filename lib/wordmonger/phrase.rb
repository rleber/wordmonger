module WordMonger
  class Phrase

    attr_reader :text, :dictionary
    def initialize(text, dictionary: nil, remember: true)
      self.text = text
      @dictionary = dictionary || WordMonger.active_dictionary
      @dictionary.add(self) if remember
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
      @synonymized = nil
    end

    def get_words_for_text(text)
      return [] unless text
      self.scanner.scan(text)
    end

    def get_words
      get_words_for_text(@text)
    end

    def words
      @words ||= self.get_words
    end

    private def is_downcase?(word)
      word.downcase == word
    end

    private def is_upcase?(word)
      word.upcase == word
    end

    private def is_capitalized?(word)
      word.capitalize == word
    end

    private def case_preserving_sub(text, from, to)
      match_regexp = Regexp.new(Regexp.escape(from), Regexp::IGNORECASE)
      from_text = text[match_regexp]
      if is_upcase?(from_text)
        to_text = to.upcase
      elsif is_capitalized?(from_text)
        to_text = to.capitalize
      else # Not sure what it is -- downcase it
        to_text = to.downcase
      end
      res = text.sub(from_text, to_text)
      res
    end

    # Synonymize replaces all synonyms with their preferred synonym
    def synonymize_text(text)
      synonymized_text = text
      get_words_for_text(text).each do |word|
        lowercase_word = word.text.downcase
        substitute = dictionary.preferred_synonyms[lowercase_word]
        if substitute
          synonymized_text = case_preserving_sub(synonymized_text, word.text, substitute)
        end
      end
      synonymized_text
    end

    def synonymize
      synonymize_text(self.text)
    end

    def synonymized
      @synonymized ||= self.class.new(synonymize)
    end

    def synonymized_name
      synonymized.phrase
    end

    def synonymized_words
      self.synonymized.words
    end

    # Normalize replaces the phrase with the normalized wording of its synonymized text
    def normalize_text(text)
      synonymized_phrase = synonymize_text(text)
      words = get_words_for_text(synonymized_phrase)
      text_case = if words.all? { |word| is_upcase?(word.text) }
        :upcase
      elsif words.all? { |word| is_capitalized?(word.text) }
        :capitalize
      else
        :downcase
      end
      search_phrase = synonymized_phrase.downcase
      substitute_phrase = dictionary.normalized_wordings[search_phrase]
      synonymized_phrase = substitute_phrase if substitute_phrase
      normalized_phrase = synonymized_phrase
      get_words_for_text(normalized_phrase).each do |word|
        normalized_phrase.sub!(word.text, word.text.send(text_case))
      end
      normalized_phrase
    end

    def normalize
      normalize_text(self.text)
    end

    def normalized
      @normalized ||= self.class.new(normalize)
    end

    def normalized_name
      normalized.phrase
    end

    def normalized_words
      self.normalized.words
    end
  end
end