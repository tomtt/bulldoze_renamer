require "active_support"
require "forwardable"

module BulldozeRenamer
  class StringInflector
    class StringDoesNotInflectToItselfError < ArgumentError; end

    extend Forwardable

    def self.active_support_inflections
      [:underscore]
    end

    def self.inflections
      active_support_inflections + [:camelize, :dasherize, :upcase, :js_camelize]
    end

    def_delegators ActiveSupport::Inflector, *StringInflector.active_support_inflections

    def initialize(current, target)
      @current = current
      @target = target
    end

    def upcase(w)
      underscore(w).upcase
    end

    def camelize(w)
      # Wrapping AR camelize because it would return 'dr-who' as 'Dr-who', we want 'DrWho'
      ActiveSupport::Inflector.camelize(underscore(w))
    end

    def dasherize(w)
      # Wrapping AR dasherize because it would return 'DrWho' as 'DrWho', we want 'dr-who'
      ActiveSupport::Inflector.dasherize(underscore(w))
    end

    def js_camelize(w)
      c = camelize(w).dup
      c[0] = c[0].downcase
      c
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

        unless result[:inflections].
          values.
          map { |i| i[:current] }.
          include?(mapping[:current])
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
