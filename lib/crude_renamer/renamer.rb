module CrudeRenamer
  class Renamer
    def initialize(options)
      @options = options
    end

    def rename!
      puts @options.inspect
    end
  end
end
