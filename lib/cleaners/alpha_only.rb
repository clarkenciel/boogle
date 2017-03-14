module Cleaners
  module AlphaOnly
    def self.clean(text)
      text.split(' ').map {|t| t.gsub(/[\W_]/, '') }.reject(&:empty?)
    end
  end
end
