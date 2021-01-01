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

        yield(dir)
      end
    end
  end

  it "includes ruby file in a file system" do
    with_file_in_tmpdir 'can_of_worms.rb', 'c=1' do |dir|
      expect(CrudeRenamer::FileFinder.find('.')).
      to eq(["./can_of_worms.rb"])
    end
  end

  it "includes json js file in a file system" do
    with_file_in_tmpdir 'cupboard_items.js', '[]' do |dir|
      expect(CrudeRenamer::FileFinder.find('.')).
      to eq(['./cupboard_items.js'])
    end
  end

  it "does not include .git directory or files in it" do
    with_file_in_tmpdir '.git/foo', 'xxx' do |dir|
      expect(CrudeRenamer::FileFinder.find('.')).
      to eq([])
    end
  end

  it "does not include empty files" do
    with_file_in_tmpdir 'empty.rb', '' do |dir|
      expect(CrudeRenamer::FileFinder.find('.')).
      to eq([])
    end
  end

  it "includes text file with UTF-8" do
    with_file_in_tmpdir 'utf8.rb', '🥳' do |dir|
      expect(CrudeRenamer::FileFinder.find('.')).
      to eq(['./utf8.rb'])
    end
  end

  it "does not include file with binary content" do
    with_file_in_tmpdir 'binary.rb', "\1" do |dir|
      expect(CrudeRenamer::FileFinder.find('.')).
      to eq([])
    end
  end
end
