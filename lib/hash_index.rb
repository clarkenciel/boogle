##
# Simple in-memory inverted index
class HashIndex
  attr_reader :pages
  def initialize
    @store = {}
    @pages = Set.new
    @cleaner = Cleaners::AlphaOnly
  end

  def insert(page_id, page_contents)
    with_tokens(page_contents) do |contents|
      @pages.add(page_id)
      contents.each do |word| 
        @store.merge!({ word => Set.new([page_id]) }) { |_, o, n| o + n }
      end
    end
  end

  def words
    @store.keys.to_set
  end

  def fetch_matches(phrase)
    # require 'byebug'
    with_tokens(phrase) do |toks|
      searchable_words = Set.new(toks).intersection(words)
      pages = searchable_words.lazy.flat_map { |tok| @store[tok].to_a }
      results = pages.reduce({}) do |result, page|
        result.merge({ page => 1 }) { |_, o, n| o + n }
      end
      results.map { |p, s| Result.new(p, s) }.sort { |r1, r2| r2.score <=> r1.score }
    end
  end

  private

  def with_tokens(contents)
    raise(EmptyContentsError, "Provided content is empty") if contents.size == 0
    processed = @cleaner.clean(contents.downcase)
    raise(NoWordsError, "Provided content contains no alphanumeric text") if processed.size == 0
    yield(processed) if block_given?
  end
end
