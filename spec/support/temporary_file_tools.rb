require 'tmpdir'
require 'fileutils'

def within_tmpdir
  Dir.mktmpdir do |dir|
    yield(dir)
  end
end

def add_file_to_dir(dir, path, content)
  Dir.chdir dir do
    FileUtils.mkdir_p File.dirname(path)
    File.open(path, 'w') do |f|
      f.puts content
    end
    `git init`
    `git add .`
    `git commit -m 'Added #{File.basename(path)} file'`
  end
end

def with_file_in_tmpdir(path, content)
  within_tmpdir do |dir|
    add_file_to_dir(dir, path, content)
    yield(dir)
  end
end

def with_directory_in_tmpdir(path)
  within_tmpdir do |dir|
    FileUtils.mkdir_p File.join(dir, path)
    yield(dir)
  end
end
