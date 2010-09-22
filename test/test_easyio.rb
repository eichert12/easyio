require 'helper'

class TestEasyio < Test::Unit::TestCase
  context "file_source" do
    should "use file system when running in development" do
      assert_equal EasyIO.file_source, :file_system
    end

    should "use provided source when specified in options" do
      assert_equal EasyIO.file_source(:source => :foo), :foo
    end
  end
  
  context "get_s3_bucket" do
    should "get bucket from options when available" do
      assert_equal EasyIO.get_s3_bucket(:bucket => "my-awesome-bucket"), "my-awesome-bucket"
    end

    should "use bucket from options before default bucket" do
      EasyIO.default_s3_bucket "foobar"
      assert_equal EasyIO.get_s3_bucket(:bucket => "my-awesome-bucket"), "my-awesome-bucket"
    end

    should "get use default_s3_bucket when set" do
      EasyIO.default_s3_bucket "foobar"
      assert_equal EasyIO.get_s3_bucket, "foobar"
    end
  end

  context "parse" do
    should "yield each row" do
      csv = "first,second,third\n1,2,3"
      EasyIO.parse(csv) do |row|
        assert_equal row[:first], "1"
        assert_equal row[:second], "2"
        assert_equal row[:third], "3"
      end
    end
  end
end
