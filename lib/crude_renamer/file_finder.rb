require 'find'

module CrudeRenamer
  class FileFinder
    def self.find(path)
      Find.find(path).select { |f| yield(f) }
    end
  end
end
