module WordMonger
  class Synonyms < Equivalents
    def initialize(*strings, attributes: {}, remember: true)
      strings = strings.flatten
      expanded_strings = []
      strings.each do |string|
        string = Equivalents.normalize_string(string)
        synonym = WordMonger.active_dictionary.synonym(string)
        if synonym
          expanded_strings += synonym.strings
          synonym.unregister if remember
        else
          expanded_strings << string
        end
      end
      super(*expanded_strings.uniq, attributes: attributes)
      register if remember
    end

    def register
      WordMonger.active_dictionary.add_synonym(self)
    end

    def unregister
      WordMonger.active_dictionary.delete_synonym(self)
    end

    def make_preferred!(string)
      unregister
      super(string)
      register
    end

    def merge!(other_synonym)
      other_synonym.unregister
      super(other_synonym)
    end
  end
end