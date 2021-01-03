require 'support/temporary_file_tools'

RSpec.describe BulldozeRenamer::FileFinder do
  describe "find" do
    it "includes ruby file in root of directory" do
      with_file_in_tmpdir 'can_of_worms.rb', 'c=1' do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq(["can_of_worms.rb"])
      end
    end

    it "includes ruby file in a directory a few levels deep" do
      with_file_in_tmpdir 'some/where/deep/can_of_worms.rb', 'c=1' do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq(["some", "some/where", "some/where/deep", "some/where/deep/can_of_worms.rb"])
      end
    end

    it "includes json js file in a file system" do
      with_file_in_tmpdir 'items/cupboard_items.js', '[]' do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq(['items', 'items/cupboard_items.js'])
      end
    end

    it "does not include .git directory or files in it" do
      with_file_in_tmpdir '.git/foo', 'xxx' do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq([])
      end
    end

    it "does not include empty files" do
      with_file_in_tmpdir 'empty.rb', '' do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq([])
      end
    end

    it "includes text file with UTF-8" do
      with_file_in_tmpdir 'utf8.rb', '🥳' do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq(['utf8.rb'])
      end
    end

    it "includes directory with matching dasherized name" do
      with_file_in_tmpdir 'dir-with-dashes/some_file', 'Hi' do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq(['dir-with-dashes', 'dir-with-dashes/some_file'])
      end
    end

    it "does not include file with binary content" do
      with_file_in_tmpdir 'binary.rb', "\1" do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq([])
      end
    end

    it "does not include files in node_modules" do
      with_file_in_tmpdir 'node_modules/foo/bar.js', "a = 1;" do |dir|
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq([])
      end
    end

    it "can read files in a git repo if we are not currently in it" do
      with_file_in_tmpdir 'pooh_bear.rb', 'b=1' do |dir|
        Dir.chdir BulldozeRenamer.root
        expect(BulldozeRenamer::FileFinder.find(dir)).
        to eq(["pooh_bear.rb"])
      end
    end
  end

  describe "extract_directories" do
    it "is empty for no files" do
      expect(BulldozeRenamer::FileFinder.extract_directories([])).to be_empty
    end

    it "has the directory of the single file" do
      expect(BulldozeRenamer::FileFinder.extract_directories(['a/b'])).to eq(['a'])
    end

    it "has the same directory of the multiple file once" do
      expect(BulldozeRenamer::FileFinder.extract_directories(['d/f1', 'd/f2'])).to eq(['d'])
      expect(BulldozeRenamer::FileFinder.extract_directories(['foo/bar', 'foo/baz'])).to eq(['foo'])
    end

    it "has and entry for every subdirectory of a single file" do
      expect(BulldozeRenamer::FileFinder.extract_directories(['one/two/three/file'])).
      to eq(['one', 'one/two', 'one/two/three'])

      expect(BulldozeRenamer::FileFinder.extract_directories(['/one/two/three/file'])).
      to eq(['/one', '/one/two', '/one/two/three'])
    end

    it "only does not traverse directories multiple times" do
      # by using an array to act as the set we can check how many times
      # a directory was added
      allow(Set).to receive(:new).and_return([])
      result = BulldozeRenamer::FileFinder.extract_directories(
        [
          'one/file1',
          'one/file2',
          'one/file3'
        ]
      )
      expect(result).to eq(['one'])
    end
  end
end
