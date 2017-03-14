module Cleaners
  %w(alpha_only).each {|fn| require_relative "./cleaners/#{fn}" }
end
