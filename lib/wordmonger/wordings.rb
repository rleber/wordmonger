module WordMonger
  class Wordings < Equivalents

    attr_reader :phrases
    def initialize(*phrases, attributes: {}, remember: true)
      super(attributes: attributes)
      phrases = phrases.flatten
      @phrases = []
      expanded_phrases = phrases.inject({}) do |hsh, phrase| 
        hsh[phrase.synonymized_text.downcase] = phrase; hsh
      end
      phrases.each do |phrase|
        normalized_text = phrase.synonymized_text.downcase
        wording = WordMonger.active_dictionary.wording(normalized_text)
        if wording
          expanded_phrases = wording.phrases.inject(expanded_phrases) do |hsh, phrase|
             hsh[phrase.synonymized_text.downcase] = phrase; hsh
          end
          wording.unregister if remember
        end
      end
      expanded_phrases.each do |name, phrase|
        add phrase
      end
      register if remember
    end

    def lexicons
      phrases.map { |phrase| phrase.lexicon }.uniq
    end

    def add(phrase, preferred: false)
      synonymized_text = phrase.synonymized_text
      unless self.index(synonymized_text)
        super(synonymized_text, preferred: preferred)
        if preferred
          @phrases.unshift(phrase.synonymized)
        else
          @phrases << phrase
        end
      end
    end

    def merge!(wording)
      wording.phrases.each do |phrase|
        add phrase
      end
      WordMonger.active_dictionary.delete_wording(wording)
    end

    def preferred_phrase
      @phrases.first
    end

    def register
      WordMonger.active_dictionary.add_wording(self)
    end

    def unregister
      WordMonger.active_dictionary.delete_wording(self)
    end
  end
end