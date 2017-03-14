Result = Struct.new(:page_id, :score) do
  def to_json(a)
    { pageId: page_id, score: score }.to_json(a)
  end
end
