require 'active_support'
require 'active_support/core_ext'

module WordMonger
  class Phrase
    # Use ActiveSupport's String.demodulize and String.deconstantize
    # Recognize "<lexicon>::<phrase>" syntax, and allow for
    # excaping the colon (i.e. '\:' is not recognized as a separator)
    def self.separate_lexicon(phrase)
      lexicon = phrase.deconstantize
      lexicon = nil if lexicon == ''
      lexicon = lexicon.downcase.to_sym if lexicon
      [lexicon, phrase.demodulize]
    end

    attr_reader :lexicon, :text, :dictionary, :words
    attr_accessor :wordings
    def initialize(text, dictionary: nil, lexicon: nil, remember: true)
      unless lexicon
        lexicon, text = self.class.separate_lexicon(text)
      end
      @dictionary = dictionary || WordMonger.active_dictionary
      @lexicon = lexicon
      @text = text
      @wordings = Wordings.new(self)
      @words = get_words
      @synonymized = nil
      @dictionary.add_phrase(self) if remember
    end

    def to_s
      @text
    end

    def has_attributes?
      attributes && attributes.size > 0
    end

    def attributes
      @wordings.attributes
    end

    def add_attribute(name, value)
      @wordings.add_attribute(name, value)
    end

    def equivalent_to(phrase)
      @wordings.merge!(phrase.wordings)
      phrase.wordings = @wordings
    end

    # Needs to capture wordings
    def serialize
      to_s
    end

    def scanner
      @dictionary.scanner
    end

    def get_words_for_text(text)
      return [] unless text
      self.scanner.scan(text)
    end

    def get_words
      get_words_for_text(@text)
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

    # TODO This should be a method in Dictionary
    # Synonymize replaces all synonyms with their preferred synonym
    def synonymize_text(text)
      synonymized_text = text
      get_words_for_text(text).each do |word|
        lowercase_word = word.text.downcase
        substitute = dictionary.synonym_substitutions[lowercase_word]
        if substitute
          synonymized_text = case_preserving_sub(synonymized_text, word.text, substitute)
        end
      end
      synonymized_text
    end

    def synonymized_text
      synonymize_text(self.text)
    end

    def synonymized
      @synonymized ||= self.class.new(synonymized_text)
    end

    def synonymized_words
      self.synonymized.words
    end

    # TODO This should be a method in Dictionary
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
      substitute_phrase = dictionary.wording_substitutions[search_phrase]
      synonymized_phrase = substitute_phrase if substitute_phrase
      normalized_phrase = synonymized_phrase
      get_words_for_text(normalized_phrase).each do |word|
        normalized_phrase = normalized_phrase.sub(word.text, word.text.send(text_case))
      end
      normalized_phrase
    end

    def normalized_text
      normalize_text(self.text)
    end

    def normalized(remember: true)
      @normalized ||= self.class.new(normalized_text, remember: remember)
    end

    def normalized_words(remember: true)
      self.normalized(remember: remember).words
    end
  end
end