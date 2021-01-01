require 'find'
require 'filemagic'

module CrudeRenamer
  class FileFinder
    def self.find(path)
      files = Find.find(path)
      if block_given?
        files.select { |f| yield(f) }
      else
        fm = FileMagic.new
        files.select do |p|
          !p.include?(".git/") &&
          (
            FileTest.directory?(p) ||
            fm.file(p).include?('text')
          )
        end
      end
    end
  end
end
