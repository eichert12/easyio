require 'helper'

class TestEasyio < Test::Unit::TestCase
  should "use file system when running in development" do
    EasyIO.file_source == :filesystem
  end

  should "use provided source when specified in options" do
    EasyIO.file_source(:source => :foo) == :foo
  end
end
