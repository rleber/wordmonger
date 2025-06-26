# frozen_string_literal: true

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

      it 'contains no abbreviations' do
        expect(@new_dictionary.abbreviations.size).to eq(0)
      end
    end

    describe 'abbreviations' do
      describe 'addition' do
        before :context do
          @text = 'Trans-Blue Green'
          @new_phrase = WordMonger::Phrase.new(@text)
          @dictionary = WordMonger.active_dictionary
          @dictionary.add_abbreviation('trans-', 'transparent')
        end

        it 'increases the size of the abbreviation list' do
          expect(@dictionary.abbreviations.size).to eq(1)
        end

        it 'adds the new abbreviation to the dictionary' do
          expect(@dictionary.abbreviations['trans-']).to eq('transparent')
        end

        after :context do
          WordMonger.active_dictionary.delete(@text)
        end
      end

      describe 'expanding' do
        before :context do
          @text = 'Trans-Blue Green'
          @new_phrase = WordMonger::Phrase.new(@text)
          @dictionary = WordMonger.active_dictionary
          @dictionary.add_abbreviation('trans', 'transparent')
        end

        it 'works' do
          expect(@new_phrase.expanded.text).to eq('Transparent-Blue Green')
        end

        after :context do
          @dictionary.delete(@text)
          @dictionary.delete('Transparent-Blue Green')
          @dictionary.delete_abbreviation('trans-')
        end
      end
    end

    describe 'serialization' do
      before :context do
        @text = 'Trans-Blue Green'
        @new_phrase = WordMonger::Phrase.new(@text)
        @dictionary = WordMonger.active_dictionary
      end

      it 'produces an array of text phrases' do
        expect(@dictionary.serialize).to eq([@text])
      end

      after :context do
        @dictionary.delete(@text)
      end
    end

    describe 'scanners' do
      before :context do
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

      after :context do
        @dictionary.delete(@text)
      end
    end
  end

  describe 'phrases' do
    describe 'addition' do
      before :context do
        @text = 'the quick, Brown fox'
        @new_phrase = WordMonger::Phrase.new(@text)
        @dictionary = WordMonger.active_dictionary
      end

      it 'creates a phrase' do
        expect(@new_phrase).to be_kind_of(WordMonger::Phrase)
      end

      it 'remembers its text' do
        expect(@new_phrase.text).to eq(@text)
      end

      it 'respohds to to_s' do
        expect(@new_phrase.to_s).to eq(@text)
      end

      it 'respohds to serialize' do
        expect(@new_phrase.serialize).to eq(@text)
      end

      it 'increases the size of the dictionary' do
        expect(@dictionary.phrases.size).to eq(1)
      end

      it 'adds the new phrase to the dictionary' do
        expect(@dictionary.phrases[@text]).to eq(@new_phrase)
      end

      after :context do
        WordMonger.active_dictionary.delete(@text)
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
  end
end
