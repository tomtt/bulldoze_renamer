require 'pp'

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

    def count_in_content(target, content)
      ('~' + content + '~').split(target).size - 1
    end

    def find_occurences(file, mappings)
      occurs_in_filename =
        mappings[:inflections][:underscore] &&
        File.basename(file).include?(mappings[:inflections][:underscore][:current])
      occurs_in_filename ||=
        mappings[:inflections][:dasherize] &&
        File.basename(file).include?(mappings[:inflections][:dasherize][:current])
      result = {
        filename: occurs_in_filename ? 1 : 0
      }
      unless FileTest.directory?(file)
        mappings[:inflections].each do |inflection, values|
          result[inflection] = count_in_content(values[:current], File.read(file))
        end
      end

      result
    end

    def was_found(occ)
      occ.values.sum > 0
    end

    def format_number(number)
      number && number > 0 ? "%4d" % number : '   _'
    end

    def rename!
      files = FileFinder.find(@path)
      file_occurences = {}

      inflections_mapping = StringInflector.new(@current_name, @target_name).mappings
      PP.pp(inflections_mapping, @out)

      files.each do |file|
        file_occurences[file] = find_occurences(file, inflections_mapping)
      end

      inflections = inflections_mapping[:inflections].keys + [:filename]
      inflections_that_are_present =
        StringInflector.inflections + [:filename] &
        file_occurences.values.inject({}) { |a,h| h.each { |k,v| v > 0 && (a[k] ||= 0 ; a[k] += v) };a }.keys

      header = ""
      inflections_that_are_present.each_with_index do |inflection, index|
        header += "   |" * index + ' ' + inflection.to_s + "\n"
      end
      header += "   |" * inflections_that_are_present.size
      @out.puts header

      files.select { |f| was_found(file_occurences[f]) }.each do |f|
        result = ""
        inflections_that_are_present.each_with_index do |inflection, index|
          result += format_number(file_occurences[f][inflection])
        end
        @out.puts result + ' ' + f + "\n"
      end
    end
  end
end
