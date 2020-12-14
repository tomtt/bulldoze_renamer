RSpec.describe CrudeRenamer do
  it "has a version number" do
    expect(CrudeRenamer::VERSION).not_to be nil
  end

  it "knows its root" do
    expect(CrudeRenamer::root).to eq Pathname.new(Dir.pwd)
  end

  it "contains the files of itself in its root directory" do
    expect(File).to be_exist File.join(CrudeRenamer::root, 'lib', 'crude_renamer', 'version.rb')
  end
end
