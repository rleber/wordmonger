# frozen_string_literal: true
require 'pry-byebug'

RSpec.describe WordMonger do
  it "has a version number" do
    expect(WordMonger::VERSION).not_to be nil
  end

  describe 'dictionary' do
    describe 'default value' do
      it 'exists' do
        expect(WordMonger.dictionaries.size).to eq(1)
      end

      it 'is named nil' do
        expect(WordMonger.dictionary(nil)).not_to be_nil
      end

      it 'is a dictionary' do
        expect(WordMonger.dictionary(nil)).to be_kind_of(WordMonger::Dictionary)
      end

      it 'is the initial active dictionary' do
        expect(WordMonger.dictionary(nil)).to eq(WordMonger.active_dictionary)
      end
    end

    describe 'addition' do
      before :context do
        @new_dictionary = WordMonger::Dictionary.new('foo')
      end

      it 'creates a dictionary' do
        expect(@new_dictionary).to be_kind_of(WordMonger::Dictionary)
      end

      it 'remembers its name' do
        expect(@new_dictionary.name).to eq('foo')
      end

      it 'increases the size of the list of dictionaries' do
        expect(WordMonger.dictionaries.size).to eq(2)
      end

      it 'adds the new dictionary to the list of dictionaries' do
        expect(WordMonger.dictionary(WordMonger.dictionaries.keys.last)).to eq(@new_dictionary)
      end

      it 'contains no phrases' do
        expect(@new_dictionary.phrases.size).to eq(0)
      end

      it 'contains no words' do
        expect(@new_dictionary.words.size).to eq(0)
      end

      it 'contains no synonyms' do
        expect(@new_dictionary.synonyms.size).to eq(0)
      end

      it 'contains no wordings' do
        expect(@new_dictionary.wordings.size).to eq(0)
      end
    end

    describe 'scanner' do
      before :example do
        @text = 'Trans-Blue Green'
        @dictionary = WordMonger.active_dictionary
        @dictionary.scanner = WordMonger::Scanner.new('hyphenated', /\w+-?/)
        @new_phrase = WordMonger::Phrase.new(@text)
      end

      it 'can be overridden' do
        words = @new_phrase.words
        word_text = words.map { |word| word.text }
        expect(word_text).to eq(%w{Trans- Blue Green})
      end
    end

    describe 'scanning' do
      it 'separates words' do
        phrase = WordMonger::Phrase.new('the quick, Brown fox')
        words = phrase.words
        word_text = words.map { |word| word.text }
        expect(word_text).to eq(%w{the quick Brown fox})
      end
    end

    describe 'matching' do
      before :context do
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @phrase1 = WordMonger::Phrase.new('Trans Blue')
        @synonym = WordMonger::Synonyms.new('transparent','trans', 'tr')
        @phrase2 = WordMonger::Phrase.new('Bricklink::Tr Blue')
      end

      context "vanilla match (not restricted to lexicon or order-independent)" do
        it 'finds a match' do
          expect(@dictionary.matching_phrases('trans Blue').size).to eq(2)
        end
      end

      context "restricted to lexicon" do
        it 'Does not find matches from other lexicons' do
          expect(@dictionary.matching_phrases('tr Blue', in_lexicon: true).size).to eq(1)
        end
      end

    end
  end

  describe 'synonyms' do
    describe 'addition' do
      before :example do
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @text = 'Trans-Blue Green'
        @new_phrase = WordMonger::Phrase.new(@text)
        @synonym_precount = @dictionary.synonyms.size
        @synonym = WordMonger::Synonyms.new('transparent','trans', 'tr')
        @synonym.add_attribute('foo', 'bar')
        @synonym.add_attribute('foo', 'bat')
        @synonym.add_attribute('fuu', 'baz')
      end

      it 'increases the size of the synonym list' do
        expect(@dictionary.synonyms.size - @synonym_precount).to eq(1)
      end

      it 'adds the new synonym to the dictionary' do
        expect(@dictionary.synonyms.keys).to include('transparent')
      end

      it 'defines the new synonyms' do
        expect(@dictionary.synonyms['transparent'].texts).to eq(['transparent','trans', 'tr'])
      end

      it 'adds the synonyms to the substitutions list' do
        expect(@dictionary.synonym_substitutions.size).to eq(2)
      end

      it 'defines the synonym substitutions' do
        expect(@dictionary.synonym_substitutions['trans']).to eq('transparent')
        expect(@dictionary.synonym_substitutions['tr']).to eq('transparent')
      end

      it 'understands attributes' do
        expect(@synonym.attributes).to eq({
          'foo' => ['bar','bat'],
          'fuu' => ['baz']
        })
      end
    end

    describe 'synonymizing' do
      before :example do
        @text = 'Trans Blue Green'
        @new_phrase = WordMonger::Phrase.new(@text)
        @dictionary = WordMonger.active_dictionary
        @synonym = WordMonger::Synonyms.new('transparent','trans')
      end

      it 'works' do
        expect(@new_phrase.synonymized.text).to eq('Transparent Blue Green')
      end
    end

    describe 'serialization' do
      before :example do
        @text = 'Trans-Blue Green'
        @new_phrase = WordMonger::Phrase.new(@text)
        @dictionary = WordMonger.active_dictionary
        @synonym = WordMonger::Synonyms.new('transparent','trans', 'tr')
        @synonym.add_attribute('foo', 'bar')
      end

      it 'works' do
        serialized_value = {
          texts: %w{transparent trans tr},
          attributes: {'foo' => ['bar']}
        }
        expect(@synonym.serialize).to eq(serialized_value)
      end
    end
  end

  describe 'wordings' do
    describe 'addition' do
      before :example do
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @text = 'Trans Blue Green'
        @phrase1 = WordMonger::Phrase.new(@text)
        @phrase2 = WordMonger::Phrase.new('Translucent Aqua')
        @phrase3 = WordMonger::Phrase.new('SeeThrough Aquamarine')
        @wording = WordMonger::Wordings.new(@phrase1, @phrase2, @phrase3)
        @wording.add_attribute('foo', 'bar')
        @wording.add_attribute('foo', 'bat')
        @wording.add_attribute('fuu', 'baz')
      end

      it 'increases the size of the wording list' do
        expect(@dictionary.wordings.size).to eq(1)
      end

      it 'adds the new wording to the dictionary' do
        expect(@dictionary.wordings.keys.first).to eq('trans blue green')
      end

      it 'increases the size of the wording substitutions list' do
        expect(@dictionary.wording_substitutions.size).to eq(2)
      end

      it 'defines the wording substitution' do
        expect(@dictionary.wording_substitutions['translucent aqua']).to eq('trans blue green')
        expect(@dictionary.wording_substitutions['seethrough aquamarine']).to eq('trans blue green')
      end

      it 'understands attributes' do
        expect(@wording.attributes).to eq({
          'foo' => ['bar','bat'],
          'fuu' => ['baz']
        })
      end
    end

    describe 'normalizing' do
      before :example do
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @text = 'Trans Blue Green'
        @phrase1 = WordMonger::Phrase.new(@text)
        @phrase2 = WordMonger::Phrase.new('Translucent Aqua')
        @wording = WordMonger::Wordings.new(@phrase1, @phrase2)
      end

      it 'works' do
        expect(@phrase2.normalized.text).to eq('Trans Blue Green')
      end
    end

    describe 'serialization' do
      before :example do
        @text = 'Trans Blue Green'
        @phrase1 = WordMonger::Phrase.new(@text)
        @phrase2 = WordMonger::Phrase.new('Translucent Aqua')
        @phrase3 = WordMonger::Phrase.new('SeeThrough Aquamarine')
        @dictionary = WordMonger.active_dictionary
        @wording = WordMonger::Wordings.new(@phrase1, @phrase2, @phrase3)
        @wording.add_attribute('foo', 'bar')
      end

      it 'works' do
        serialized_value = {
          texts: [@phrase1,@phrase2,@phrase3].map { |phrase| phrase.text.downcase },
          attributes: {'foo' => ['bar']}
        }
        expect(@wording.serialize).to eq(serialized_value)
      end
    end
  end

  describe 'serialization' do
    describe 'with full set of values' do
      before :example do
        @text = 'Trans Blue Green'
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @word = WordMonger::Word.new('foo')
        @synonym = WordMonger::Synonyms.new('transparent','trans')
        @phrase1 = WordMonger::Phrase.new(@text)
        @phrase2 = WordMonger::Phrase.new('Translucent Aqua')
        @wording = WordMonger::Wordings.new(@phrase1, @phrase2)
        @serialized_hash = {
          words: ['foo'],
          synonyms: [['transparent', 'trans']],
          phrases: ['Trans Blue Green', 'Translucent Aqua'],
          wordings: [['transparent blue green', 'translucent aqua']]
        }
      end

      it 'produces a hash' do
        expect(@dictionary.serialize).to be_a(Hash)
      end

      it 'has the expected keys' do
        expect(@dictionary.serialize.keys).to eq(%i{words phrases synonyms wordings})
      end

      it 'has the right content' do
        expect(@dictionary.serialize).to eq(@serialized_hash)
      end
    end

    describe 'with partial set of values' do
      before :example do
        @text = 'Trans Blue Green'
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @phrase1 = WordMonger::Phrase.new(@text)
        @phrase2 = WordMonger::Phrase.new('Translucent Aqua')
        @wording = WordMonger::Wordings.new(@phrase1, @phrase2)
      end

      it 'produces a hash' do
        expect(@dictionary.serialize).to be_a(Hash)
      end

      it 'has the expected keys' do
        expect(@dictionary.serialize.keys).to eq(%i{phrases wordings})
      end
    end
  end

  describe 'deserialization' do
    before :example do
      @dictionary = WordMonger.active_dictionary
      @serialized_hash = {
        words: ['foo'],
        synonyms: [['transparent', 'trans']],
        phrases: ['Trans Blue Green', 'Translucent Aqua'],
        wordings: [['transparent blue green', 'translucent aqua']]
      }
    end

    it 'works' do
      expect {@dictionary.deserialize(@serialized_hash)}.not_to raise_error
    end

    it 'defines the word' do
      @dictionary.deserialize(@serialized_hash)
      expect(@dictionary.words['foo']).not_to be(nil)
    end

    it 'defines the synonyms' do
      @dictionary.deserialize(@serialized_hash)
      expect(@dictionary.synonyms['transparent']).not_to be(nil)
    end

    it 'defines all the phrases' do
      @dictionary.deserialize(@serialized_hash)
      expect(@dictionary.phrases['Trans Blue Green']).not_to be(nil)
      expect(@dictionary.phrases['Translucent Aqua']).not_to be(nil)
    end

    it 'defines the wordings' do
      @dictionary.deserialize(@serialized_hash)
      expect(@dictionary.wordings['transparent blue green']).not_to be(nil)
    end
  end

  describe 'phrases' do
    describe 'addition' do
      before :context do
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @text = 'the quick, Brown fox'
        @new_phrase = WordMonger::Phrase.new(@text)
        @new_phrase.add_attribute('foo', 'bar')
      end

      it 'creates a phrase' do
        expect(@new_phrase).to be_kind_of(WordMonger::Phrase)
      end

      it 'remembers its text' do
        expect(@new_phrase.text).to eq(@text)
      end

      it 'responds to to_s' do
        expect(@new_phrase.to_s).to eq(@text)
      end

      it 'responds to serialize' do
        expect(@new_phrase.serialize).to eq(@text)
      end

      it 'increases the size of the dictionary' do
        expect(@dictionary.phrases.size).to eq(1)
      end

      it 'understands attributes' do
        expect(@new_phrase.attributes).to eq({'foo' => ['bar']})
      end
    end
  end

  describe 'words' do
    describe 'addition' do
      before :context do
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @text = 'the'
        @new_word = WordMonger::Word.new(@text)
        @new_word.add_attribute('foo', 'bar')
      end

      it 'creates a word' do
        expect(@new_word).to be_kind_of(WordMonger::Word)
      end

      it 'remembers its text' do
        expect(@new_word.text).to eq(@text)
      end

      it 'responds to to_s' do
        expect(@new_word.to_s).to eq(@text)
      end

      it 'responds to serialize' do
        serialized_text = {
          text: @text,
          attributes: {'foo' => ['bar']}
        }
        expect(@new_word.serialize).to eq(serialized_text)
      end

      it 'increases the size of the dictionary' do
        expect(@dictionary.words.size).to eq(1)
      end

      it 'adds the new word to the dictionary' do
        expect(@dictionary.words[@text]).to eq(@new_word)
      end

      it 'understands attributes' do
        expect(@new_word.attributes).to eq({'foo' => ['bar']})
      end

      it 'sets the generated flag off by default' do
        expect(@new_word.generated).to be_nil
      end
    end

    describe ':generated flag' do
      before :context do
        @dictionary = WordMonger.active_dictionary
        @dictionary.reset!
        @text = 'the'
        @new_word = WordMonger::Word.new(@text, generated: true)
        @new_word.add_attribute('foo', 'bar')
      end

      it 'is remembered' do
        expect(@new_word.generated).to eq(true)
      end
    end
  end
end
