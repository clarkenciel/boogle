require 'sinatra'

here = File.absolute_path(File.dirname(__FILE__))
lib = File.join(here, 'lib')
Dir.entries(lib).reject {|fn| fn.start_with? '.'}.select {|fn| fn.end_with? '.rb'}.
  each {|fn| require_relative File.join(lib, fn) }
