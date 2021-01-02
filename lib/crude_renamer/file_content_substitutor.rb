require 'tmpdir'
require 'fileutils'

module CrudeRenamer
  class FileContentSubstitutor
    def initialize(dir)
      @dir = dir
    end

    def full_path(path)
      File.join(@dir, path)
    end

    def with_content_written_to_temporary_file(content)
      Dir.mktmpdir do |dir|
        filename = File.join(dir, 'replaced_content')
        File.open(filename, 'w') do |f|
          f.puts content
        end
        yield(filename)
      end
    end

    def substitute_in(path, mappings)
      content = File.read(full_path(path))
      mappings.each do |m|
        content.gsub!(m[0], m[1])
      end

      with_content_written_to_temporary_file(content) do |f|
        FileUtils.mv(f, full_path(path))
      end
    end
  end
end
