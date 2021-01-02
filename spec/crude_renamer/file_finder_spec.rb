require 'tmpdir'
require 'fileutils'

RSpec.describe CrudeRenamer::FileFinder do
  def with_file_in_tmpdir(path, content)
    Dir.mktmpdir do |dir|
      Dir.chdir dir do
        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'w') do |f|
          f.puts content
        end
        `git init`
        `git add .`
        `git commit -m 'commit tempory directory'`
      end
      yield(dir)
    end
  end

  it "includes ruby file in root of directory" do
    with_file_in_tmpdir 'can_of_worms.rb', 'c=1' do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq(["can_of_worms.rb"])
    end
  end

  it "includes ruby file in a directory a few levels deep" do
    with_file_in_tmpdir 'some/where/deep/can_of_worms.rb', 'c=1' do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq(["some/where/deep/can_of_worms.rb"])
    end
  end

  it "includes json js file in a file system" do
    with_file_in_tmpdir 'items/cupboard_items.js', '[]' do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq(['items/cupboard_items.js'])
    end
  end

  it "does not include .git directory or files in it" do
    with_file_in_tmpdir '.git/foo', 'xxx' do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq([])
    end
  end

  it "does not include empty files" do
    with_file_in_tmpdir 'empty.rb', '' do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq([])
    end
  end

  it "includes text file with UTF-8" do
    with_file_in_tmpdir 'utf8.rb', '🥳' do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq(['utf8.rb'])
    end
  end

  it "includes directory with matching dasherized name" do
    with_file_in_tmpdir 'dir-with-dashes/some_file', 'Hi' do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq(['dir-with-dashes/some_file'])
    end
  end

  it "does not include file with binary content" do
    with_file_in_tmpdir 'binary.rb', "\1" do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq([])
    end
  end

  it "does not include files in node_modules" do
    with_file_in_tmpdir 'node_modules/foo/bar.js', "a = 1;" do |dir|
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq([])
    end
  end

  it "can read files in a git repo if we are not currently in it" do
    with_file_in_tmpdir 'pooh_bear.rb', 'b=1' do |dir|
      Dir.chdir CrudeRenamer.root
      expect(CrudeRenamer::FileFinder.find(dir)).
      to eq(["pooh_bear.rb"])
    end
  end
end
