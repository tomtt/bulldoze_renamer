require 'support/temporary_file_tools'

RSpec.describe BulldozeRenamer::RenamingOrchestrator do
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

  describe "reports" do
    it "shows occurences in a file system" do
      within_dummy_directory do |dir|
        orchestrator = BulldozeRenamer::RenamingOrchestrator.new(
          path: dir,
          current_name: 'can_of_worms',
          target_name: 'piece_of_cake'
        )

        report = orchestrator.report_header_file_occurences + orchestrator.report_file_occurences
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
        orchestrator = BulldozeRenamer::RenamingOrchestrator.new(
          path: dir,
          current_name: 'PecanIcecream',
          target_name: 'CaramelIcecream'
        )

        report = orchestrator.report_header_file_occurences + orchestrator.report_file_occurences

        expected_report = <<~EOT
        dasherize
          |
          1 json-lists/cupboard_items.js
        EOT

        expect(report).to eq(expected_report)
      end
    end

    it "shows inflection for name of directory" do
      within_dummy_directory do |dir|
        orchestrator = BulldozeRenamer::RenamingOrchestrator.new(
          path: dir,
          current_name: 'json-lists',
          target_name: 'js-content'
        )

        report = orchestrator.report_header_file_occurences + orchestrator.report_file_occurences

        expected_report = <<~EOT
        filename
          |
          1 json-lists
        EOT

        expect(report).to eq(expected_report)
      end
    end
  end

  describe "perform" do
    it "renames file and replaces content" do
      path_before = 'lib/bears/pooh_bear/pooh_bear.rb'
      content_before = <<~EOT
        class PoohBear
          POOH_BEAR_ACTIONS = [:eat]
        end
      EOT

      path_after = 'lib/bears/honey_bear/honey_bear.rb'
      content_after = <<~EOT
        class HoneyBear
          HONEY_BEAR_ACTIONS = [:eat]
        end
      EOT

      with_file_in_tmpdir path_before, content_before do |dir|
        orchestrator = BulldozeRenamer::RenamingOrchestrator.new(
          path: dir,
          current_name: 'PoohBear',
          target_name: 'HoneyBear',
          perform: true
        )

        perform_report = StringIO.new
        orchestrator.perform!(out: perform_report)

        expected_perform_report = <<~EOT
          Performing:
          R lib/bears/pooh_bear/pooh_bear.rb -> lib/bears/pooh_bear/honey_bear.rb
          d lib/bears/pooh_bear -> lib/bears/honey_bear
        EOT

        perform_report.rewind
        expect(perform_report.read).to eq expected_perform_report
        expect(File.read(File.join(dir, path_after))).to eq(content_after)
      end
    end
  end
end
