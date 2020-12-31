RSpec.describe CrudeRenamer::StringInflector do
  describe "camel_to_snake_case" do
    it "downcases a single word" do
      expect(::CrudeRenamer::StringInflector.
        camel_to_snake_case('Foo')
      ).to eq 'foo'
    end

    it "downcases and underscores a multiple word" do
      expect(::CrudeRenamer::StringInflector.
        camel_to_snake_case('FooBar')
      ).to eq 'foo_bar'
    end
  end
end
