require 'tmpdir'
require 'fileutils'

module BulldozeRenamer
  class FileContentSubstitutor
    def initialize(dir)
      @dir = dir
    end

    def full_path(path)
      File.join(@dir, path)
    end

    def with_content_written_to_temporary_file(original_path, content)
      Dir.mktmpdir do |dir|
        filename = File.join(dir, 'replaced_content')

        # First copy original file to preserve permissions, even though we will overwrite
        FileUtils.cp_r(File.join(@dir, original_path), filename, preserve: true)

        File.open(filename, 'w') do |f|
          f.print content
        end
        yield(filename)
      end
    end

    def move_directory(original_path, new_path)
      FileUtils.mv(full_path(original_path), full_path(new_path))
    end

    def substitute_in(original_path, new_path, mappings)
      content = File.read(full_path(original_path))
      mappings.each do |m|
        content.gsub!(m[0], m[1])
      end

      with_content_written_to_temporary_file(original_path, content) do |f|
        FileUtils.cp_r(f, full_path(new_path), preserve: true)
        if new_path != original_path
          FileUtils.rm(full_path(original_path))
        end
      end
    end
  end
end
