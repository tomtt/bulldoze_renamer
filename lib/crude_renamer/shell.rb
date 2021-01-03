require 'optparse'

module CrudeRenamer
  class Shell
    BANNER = <<"EOT"
usage: #{$0} path CurrentNameInCamelCase TargetName

Will do a crude renaming of everything in the current directory. It
uses `git ls-files` to find the files so only things checked into
git are subject to change.

This script is still potentially dangerous, use with caution.

By default only an overview is shown of what changes will be made
in what files. To actually perform those changes, pass the '-p'
option.
EOT

    def self.usage(err: STDERR)
      err.puts BANNER
      exit 1
    end

    def self.start(argv, out: STDOUT, err: STDERR)
      options = {
        current_name: nil,
        target_name: nil,
        perform: false
      }

      OptionParser.new do |parser|
        parser.banner = BANNER

        parser.on("-p", "--perform", "Perform the substitutions on the files") do |perform|
          options[:perform] = perform
        end
      end.parse! argv

      unless argv.size == 3
        self.usage(err: err)
      end

      options[:path] = argv[0]
      options[:current_name] = argv[1]
      options[:target_name] = argv[2]

      RenamingOrchestrator.rename_with_options(options, out: out, err: err)
    end
  end
end
