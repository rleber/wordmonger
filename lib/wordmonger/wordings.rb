module WordMonger
  class Wordings < Equivalents
    def initialize(*phrases, attributes: {}, remember: true)
      phrases = phrases.flatten
      expanded_phrases = []
      phrases.each do |phrase|
        wording = WordMonger.active_dictionary.wording(phrase)
        if wording
          expanded_phrases += wording.strings
          wording.unregister if remember
        else
          expanded_phrases << phrase.text
        end
      end
      # strings = expanded_phrases.map { |phrase| phrase.text }
      super(expanded_phrases.uniq, attributes: attributes)
      register if remember
    end

    def add(phrase, preferred: false)
      synonymized_text = phrase.synonymize
      super(synonymized_text, preferred)
    end

    def register
      WordMonger.active_dictionary.add_wording(self)
    end

    def unregister
      WordMonger.active_dictionary.delete_wording(self)
    end

    def make_preferred!(string)
      WordMonger.active_dictionary.delete_wording(self)
      super(string)
      WordMonger.active_dictionary.add_wording(self)
    end
  end
end