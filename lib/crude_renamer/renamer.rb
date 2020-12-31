module CrudeRenamer
  class Renamer
    def initialize(current_name:, target_name:, force:, out:, err:)
      @current_name = current_name
      @target_name = target_name
      @force = force
      @out = out
      @err = err
    end

    def rename!
      puts self.inspect
    end
  end
end
