require 'find'
require 'filemagic'

module CrudeRenamer
  class FileFinder
    def self.file_magic
      @@file_magic ||= FileMagic.new
    end

    def self.file_excluded?(file)
      file.include?(".git/") ||
      file.include?("node_modules") ||
      File.basename(file) == '.git' ||
      file == '.'
    end

    def self.file_considered?(file)
      return true if FileTest.directory?(file)

      fm = file_magic.file(file)
      fm.include?('text') ||
      fm.include?('JSON')
    end

    # Using git ls-files has many advantages but it does not
    # return directories. This method extracts all directories
    # as present for the files found.
    def self.extract_directories(files)
      result = Set.new
      files.each do |f|
        dir = File.dirname(f)

        # File.dirname('foo') => "."
        # File.dirname('/foo') => "/"
        while(dir != '.' && dir != '/' && !result.include?(dir))
          result << dir
          dir = File.dirname(dir)
        end
      end
      result.to_a.sort
    end

    def self.find(path)
      files = []
      Dir.chdir(path) do
        files = `git ls-files`.split
        files = (files + extract_directories(files)).sort

        if block_given?
          files.select { |f| yield(f) }
        else
          files.select do |p|
            !file_excluded?(p) &&
            file_considered?(p)
          end
        end
      end
    end
  end
end
