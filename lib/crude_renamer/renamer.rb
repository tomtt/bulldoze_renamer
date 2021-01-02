require 'pp'

module CrudeRenamer
  class Renamer
    def initialize(path:, current_name:, target_name:, force: nil)
      @path = path
      @current_name = current_name
      @target_name = target_name
      @force = force
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

    def inflections_mapping
      @inflections_mapping ||= StringInflector.new(@current_name, @target_name).mappings
    end

    def files
      @files ||= FileFinder.find(@path)
    end

    def file_occurences
      return @file_occurences if @file_occurences

      result = {}

      files.each do |file|
        result[file] = find_occurences(file, inflections_mapping)
      end

      @file_occurences = result
    end

    def inflections_that_are_present
      @inflections_that_are_present ||=
        StringInflector.inflections + [:filename] &
        file_occurences.values.inject({}) { |a,h| h.each { |k,v| v > 0 && (a[k] ||= 0 ; a[k] += v) };a }.keys
    end

    def report_header_file_occurences
      result = ""
      inflections_that_are_present.each_with_index do |inflection, index|
        result += ("   |" * index + ' ' + inflection.to_s + "\n")[1..-1]
      end
      result += ("   |" * inflections_that_are_present.size + "\n")[1..-1]
      result
    end

    def report_file_occurences_line(file)
      result = ""
      inflections_that_are_present.each_with_index do |inflection, index|
        result += format_number(file_occurences[file][inflection])
      end
      result + ' ' + file + "\n"
    end

    def report_file_occurences
      result = ""
      files.select { |f| was_found(file_occurences[f]) }.each do |f|
        result += report_file_occurences_line(f)[1..-1]
      end
      result
    end

    def report_inflections_mapping
      longest_current = inflections_mapping[:inflections].values.map { |v| v[:current].size }.max

      result = ""
      inflections_mapping[:inflections].each do |i, v|
        result += "%-11s: %-#{longest_current}s -> %s\n" % [i, v[:current], v[:target]]
      end
      result + "\n"
    end

    def reports
      report_inflections_mapping +
      report_header_file_occurences +
      report_file_occurences
    end

    def rename!
      raise "TODO"
    end
  end
end
