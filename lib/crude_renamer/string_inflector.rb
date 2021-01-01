require "active_support"
require "forwardable"

module CrudeRenamer
  class StringInflector
    class StringDoesNotInflectToItselfError < ArgumentError; end

    extend Forwardable

    def self.active_support_inflections
      [:underscore, :camelize, :dasherize]
    end

    def_delegators ActiveSupport::Inflector, *StringInflector.active_support_inflections

    def initialize(current, target)
      @current = current
      @target = target
    end

    def upcase(w)
      underscore(w).upcase
    end

    def js_camelize(w)
      c = camelize(w).dup
      c[0] = c[0].downcase
      c
    end

    def self.inflections
      active_support_inflections + [:upcase, :js_camelize]
    end

    def mappings
      result = {
        current_inflection: nil,
        target_inflection: nil,
        inflections: {}
      }
      StringInflector.inflections.each do |i|
        unless result[:current_inflection]
          if @current == send(i, @current)
            result[:current_inflection] = i
          end
        end

        unless result[:target_inflection]
          if @target == send(i, @target)
            result[:target_inflection] = i
          end
        end

        mapping = {
          current: send(i, @current),
          target: send(i, @target)
        }

        unless result[:inflections].values.include? mapping
          result[:inflections][i] = mapping
        end
      end

      unless result[:current_inflection]
        raise StringDoesNotInflectToItselfError.new(@current)
      end

      unless result[:target_inflection]
        raise StringDoesNotInflectToItselfError.new(@target)
      end
      result
    end
  end
end
