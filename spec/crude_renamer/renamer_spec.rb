require 'tmpdir'
require 'fileutils'

RSpec.describe CrudeRenamer::Renamer do
  def within_tmpdir
    Dir.mktmpdir do |dir|
      yield(dir)
    end
  end

  def add_file_to_dir(dir, path, content)
    Dir.chdir dir do
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') do |f|
        f.puts content
      end
      `git init`
      `git add .`
      `git commit -m 'Added #{File.basename(path)} file'`
    end
  end

  def within_dummy_directory
    within_tmpdir do |dir|
      add_file_to_dir(dir, 'json-lists/cupboard_items.js', <<~EOT
          [
            "can-of-worms",
            "pecan-icecream"
          ]
        EOT
      )

      add_file_to_dir(dir, 'ruby-items/can_of_worms.rb', <<~EOT
          class CanOfWorms
            WORMS_IN_CAN_OF_WORMS = 3
          end
        EOT
      )
      yield(dir)
    end
  end

  it "shows occurences in a file system" do
    within_dummy_directory do |dir|
      renamer = CrudeRenamer::Renamer.new(
        path: dir,
        current_name: 'can_of_worms',
        target_name: 'piece_of_cake'
      )

      report = renamer.report_header_file_occurences + renamer.report_file_occurences
      expected_report = <<~EOT
      camelize
        | dasherize
        |   | upcase
        |   |   | filename
        |   |   |   |
        _   1   _   _ json-lists/cupboard_items.js
        1   _   1   1 ruby-items/can_of_worms.rb
      EOT

      expect(report).to eq(expected_report)
    end
  end

  it "shows only inflections that occur in a file system" do
    within_dummy_directory do |dir|
      renamer = CrudeRenamer::Renamer.new(
        path: dir,
        current_name: 'PecanIcecream',
        target_name: 'CaramelIcecream'
      )

      report = renamer.report_header_file_occurences + renamer.report_file_occurences

      expected_report = <<~EOT
      dasherize
        |
        1 json-lists/cupboard_items.js
      EOT

      expect(report).to eq(expected_report)
    end
  end
end
