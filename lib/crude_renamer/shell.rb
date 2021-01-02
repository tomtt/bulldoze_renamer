require 'optparse'

module CrudeRenamer
  class Shell
    BANNER = <<"EOT"
usage: #{$0} path CurrentNameInCamelCase TargetName

Will do a crude renaming of everything in the current directory
you better be sure everything you run it on is checked into source
control since this script is potentially destructive.
EOT

    def self.usage(err: STDERR)
      err.puts BANNER
      exit 1
    end

    def self.rename_with_options(options, out, err)
      renamer = Renamer.new(options)
      out.puts renamer.reports
      renamer.rename! if options[:force]
    end

    def self.start(argv, out: STDOUT, err: STDERR)
      options = {
        current_name: nil,
        target_name: nil,
        force: false
      }

      OptionParser.new do |parser|
        parser.banner = BANNER

        parser.on("-f", "--force", "Ignore any warnings and perform crude rename regardless") do |force|
          options[:force] = force
        end
      end.parse! argv

      unless argv.size == 3
        self.usage(err: err)
      end

      options[:path] = argv[0]
      options[:current_name] = argv[1]
      options[:target_name] = argv[2]

      rename_with_options(options, out, err)
    end
  end
end
