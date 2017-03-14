require_relative '../spec_helper'

RSpec.describe Index do

  context 'basic insertion' do
    before :each do
      @index = Index.new
    end

    it 'accepts pairs of content/pageId' do
      page = 1
      content = "the quick brown fox jumped over the lazy dog"
      @index.insert(page, content)
      expect(@index.pages.size).to eq(1)
      expect(@index.words.size).to eq(content.split(' ').to_set.size)
    end

    it 'throws error if content is empty' do
      page = 1
      content = ''
      expect { @index.insert(page, content) }.to(
        raise_error(
          EmptyContentsError,
          'Provided content is empty'
        )
      )
    end

    it 'throws error if content is only punctuation' do
      page = 1
      content = ' -!@#$%^&*()_+=,./;\'\\<>?:"[]{}\|`~'
      expect { @index.insert(page, content) }. to(
        raise_error(
          NoWordsError,
          "Provided content contains no alphanumeric text"
        )
      )
    end

    it 'removes punctuation' do
      page = 1
      content = "the quick, & brown(?) fox jumped[!] over the lazy dog."
      @index.insert(page, content)
      check = content.split(' ').map { |w| w.gsub(/\W/, '') }.reject { |s| s.size == 0 } 
      expect(@index.words).not_to eq(content.split(' ').to_set)
      expect(@index.words).to eq(check.to_set)
    end

    it 'downcases inputs' do
      page = 1
      content = "The Quick Brown Fox Jumped Over The Lazy Dog"
      @index.insert(page, content)
      expect(@index.words).not_to eq(content.split(' ').to_set)
      expect(@index.words).to eq(content.downcase.split(' ').to_set)
    end
  end

  context 'duplication' do
    before :each do
      @index = Index.new
      @index.insert(1, "the quick brown fox jumped over the lazy dog")
    end

    context 'words' do
      it 'does not duplicate word entries' do
        words_before = @index.words
        content = "the quick brown fox jumped over the lazy dog"
        @index.insert(2, content)

        expect(@index.words).to eq(words_before)
        expect(@index.words.size).to eq(words_before.size)
      end

      it 'does not duplicate regardless of capitalization' do
        words_before = @index.words
        content =  "The Quick Brown Fox Jumped Over The Lazy Dog"
        @index.insert(2, content)

        expect(@index.words).to eq(words_before)
        expect(@index.words.size).to eq(words_before.size)
      end
    end

    context 'page entries' do
      it 'does not duplicate page entries' do
        pages_before = @index.pages
        @index.insert(1,  "Elementary, my dear Watson.")

        expect(@index.pages).to eq(pages_before)
        expect(@index.pages.size).to eq(pages_before.size)
      end
    end
  end
end
