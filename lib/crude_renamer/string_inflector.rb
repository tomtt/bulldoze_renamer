require "active_support"
require "forwardable"

module CrudeRenamer
  class StringInflector
    extend Forwardable

    def self.active_support_inflections
      [:underscore, :camelize, :dasherize]
    end

    def_delegators ActiveSupport::Inflector, *StringInflector.active_support_inflections

    def self.camel_to_snake_case(camel_case)
      ActiveSupport::Inflector.underscore(camel_case)
    end

    def initialize(current, target)
      @current = current
      @target = target
    end

    def upcase(w)
      underscore(w).upcase
    end

    def js_camelize(w)
      w[0].downcase + camelize(w)[1..-1]
    end

    def self.inflections
      active_support_inflections + [:upcase, :js_camelize]
    end

    def mappings
      result = {
        current_inflection: nil,
        inflections: {}
      }
      StringInflector.inflections.each do |i|
        unless result[:current_inflection]
          if @current == send(i, @current)
            result[:current_inflection] = i
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
      result
    end
  end
end
