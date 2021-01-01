
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

    def find_occurences(file)
      snake_case = StringInflector.camel_to_snake_case(@current_name)
      if FileTest.directory?(file)
        {
          camel_case: 0,
          snake_case: 0,
          filename: File.basename(file).include?(snake_case)
        }
      else
        content = File.read(file)
        {
          camel_case: count_in_content(@current_name, content),
          snake_case: count_in_content(snake_case, content),
          filename: File.basename(file).include?(snake_case)
        }
      end
    end

    def was_found(occ)
      occ[:camel_case] > 0 || occ[:snake_case] > 0 || occ[:filename]
    end

    def format_number(number)
      number > 0 ? "%2d" % number : ' _'
    end

    def rename!
      files = FileFinder.find(@path)
      file_occurences = {}
      files.each do |file|
        file_occurences[file] = find_occurences(file)
      end

      files.select { |f| was_found(file_occurences[f]) }.each do |f|
        puts "%s %s %s %-40s" % [
          format_number(file_occurences[f][:camel_case]),
          format_number(file_occurences[f][:snake_case]),
          file_occurences[f][:filename] ? ' 1' : ' _',
          f
        ]
      end
    end
  end
end
