require 'tmpdir'

RSpec.describe CrudeRenamer::Renamer do
  def within_dummy_directory
    Dir.mktmpdir do |dir|
      Dir.chdir dir do
        File.open('cupboard_items.js', 'w') do |f|
          f.puts <<-EOT
            [
              "can-of-worms",
              "pecan-icecream"
            ]
          EOT
        end

        File.open('can_of_worms.rb', 'w') do |f|
          f.puts <<-EOT
            class CanOfWorms
              WORMS_IN_CAN_OF_WORMS = 3
            end
          EOT
        end

        yield(dir)
      end
    end
  end

  it "shows occurences in a file system" do
    within_dummy_directory do |dir|
      renamer = CrudeRenamer::Renamer.new(
        path: '.',
        current_name: 'can_of_worms',
        target_name: 'piece_of_cake'
      )

      report = renamer.header_file_occurences + renamer.report_file_occurences
      expected_report = <<~EOT
      camelize
        | dasherize
        |   | upcase
        |   |   | filename
        |   |   |   |
        1   _   1   1 ./can_of_worms.rb
        _   1   _   _ ./cupboard_items.js
      EOT

      expect(report).to eq(expected_report)
    end
  end

  it "shows only inflections that occur in a file system" do
    within_dummy_directory do |dir|
      renamer = CrudeRenamer::Renamer.new(
        path: '.',
        current_name: 'PecanIcecream',
        target_name: 'CaramelIcecream'
      )

      report = renamer.header_file_occurences + renamer.report_file_occurences

      expected_report = <<~EOT
      dasherize
        |
        1 ./cupboard_items.js
      EOT

      expect(report).to eq(expected_report)
    end
  end
end
