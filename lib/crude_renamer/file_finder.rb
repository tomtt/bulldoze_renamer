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

    def self.find(path)
      files = `git ls-files #{path}`.split
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
