module CrudeRenamer
  class StringInflector
    def self.camel_to_snake_case(camel_case)
      parts = camel_case.split(/([A-Z][^A-Z]*)/).select { |s| !s.empty? }
      parts.map(&:downcase).join('_')
    end
  end
end
