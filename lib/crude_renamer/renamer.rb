module CrudeRenamer
  class Renamer
    def initialize(path:, current_name:, target_name:, force:, out:, err:)
      @path = path
      @current_name = current_name
      @target_name = target_name
      @force = force
      @out = out
      @err = err
    end

    def rename!
      files = FileFinder.find(@path) do |p|
        !p.include?(".git/") &&
        !FileTest.directory?(p)
      end
      puts files
    end
  end
end
