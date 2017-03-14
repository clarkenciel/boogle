##
# Simple inverted index
class Index
  attr_reader :pages
  def initialize
    @store = {}
    @pages = Set.new
    @cleaner = Cleaners::AlphaOnly
  end

  def insert(page_id, page_contents)
    with_processed_contents(page_contents) do |contents|
      @pages.add(page_id)
      contents.each do |word| 
        if @store.include? word
          @store[word].add(page_id)
        else
          @store[word] = Set.new([page_id])
        end
      end
    end
  end

  def words
    @store.keys.to_set
  end

  private

  def with_processed_contents(contents)
    raise(EmptyContentsError, "Provided content is empty") if contents.size == 0
    processed = @cleaner.clean(contents.downcase)
    raise(NoWordsError, "Provided content contains no alphanumeric text" if processed.size == 0
    yield(processed) if block_given?
  end
end
