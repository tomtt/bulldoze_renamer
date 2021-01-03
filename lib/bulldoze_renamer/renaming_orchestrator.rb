require 'pp'

module BulldozeRenamer
  class RenamingOrchestrator
    def initialize(path:, current_name:, target_name:, perform: nil)
      @path = path
      @current_name = current_name
      @target_name = target_name
      @perform = perform
    end

    def count_in_content(target, content)
      ('~' + content + '~').split(target).size - 1
    end

    def find_occurences(file, mappings)
      result = {}
      Dir.chdir @path do
        occurs_in_filename =
        mappings[:inflections][:underscore] &&
        File.basename(file).include?(mappings[:inflections][:underscore][:current])
        occurs_in_filename ||=
        mappings[:inflections][:dasherize] &&
        File.basename(file).include?(mappings[:inflections][:dasherize][:current])
        result[:filename] = occurs_in_filename ? 1 : 0

        unless FileTest.directory?(file)
          mappings[:inflections].each do |inflection, values|
            result[inflection] = count_in_content(values[:current], File.read(file))
          end
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

    def files_that_have_occurences
      files.select { |f| was_found(file_occurences[f]) }
    end

    def report_file_occurences
      result = ""
      files_that_have_occurences.each do |f|
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

    def reports_for_files
      report_header_file_occurences +
      report_file_occurences
    end

    def new_filename_for(filename)
      dirname = File.dirname(filename)
      basename = File.basename(filename)
      inflections_mapping[:inflections].each do |m, v|
        if basename.include?(v[:current])
          return File.join(dirname, basename.gsub(v[:current], v[:target]))
        end
      end
      filename
    end

    def perform_directory!(dirname, out)
      new_dirname = new_filename_for(dirname)
      out.puts "d #{dirname} -> #{new_dirname}"
      FileContentSubstitutor.new(@path).move_directory(dirname, new_dirname)
    end

    def perform_file!(filename, occurences, out)
       new_filename = if occurences[:filename] > 0
         x = new_filename_for(filename)
         mode = 'r'
         unless occurences.select { |k,v| k != :filename && v > 0 }.empty?
           mode = 'R'
         end

         out.puts "#{mode} #{filename} -> #{x}"
         x
       else
         out.puts "f #{filename}"
         filename
       end

       present_mappings = occurences.select { |k,v| k != :filename && v > 0 }
       mappings = present_mappings.map do |m,c|
         inflections_mapping[:inflections][m].values
       end

       FileContentSubstitutor.new(@path).
       substitute_in(filename, new_filename, mappings)
    end

    def perform!(out:)
      out.puts "Performing:"
      directories = []
      files_that_have_occurences.each do |filename|
        occurences = file_occurences[filename]
        if FileTest.directory?(File.join(@path, filename))
          directories << filename
        else
          perform_file!(filename, occurences, out)
        end
      end

      directories.reverse.each do |dir|
        perform_directory!(dir, out)
      end

    end

    def self.rename_with_options(options, out:, err:)
      orch = RenamingOrchestrator.new(options)
      out.puts orch.report_inflections_mapping

      if orch.files_that_have_occurences.empty?
        out.puts "'#{options[:current_name]}' can not be found in any of the files in '#{options[:path]}'"
      else
        out.puts orch.reports_for_files
        if options[:perform]
          puts
          orch.perform!(out: out)
        else
          out.puts "\nThis is an overview of changes that would be made\nRun same command with -p option to perform"
        end
      end
    end
  end
end
