RSpec.describe BulldozeRenamer do
  it "has a version number" do
    expect(BulldozeRenamer::VERSION).not_to be nil
  end

  it "knows its root" do
    expect(BulldozeRenamer::root).to eq Pathname.new(Dir.pwd)
  end

  it "contains the files of itself in its root directory" do
    expect(File).to be_exist File.join(BulldozeRenamer::root, 'lib', 'bulldoze_renamer', 'version.rb')
  end
end
