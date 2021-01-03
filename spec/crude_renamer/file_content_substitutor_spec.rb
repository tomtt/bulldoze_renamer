require 'support/temporary_file_tools'

RSpec.describe CrudeRenamer::FileContentSubstitutor do
  describe "substitute_in" do
    it "preserves file content if there are no mappings" do
      content = <<~EOT
      This should remain in tact
      EOT
      with_file_in_tmpdir 'some_file', content do |dir|
        CrudeRenamer::FileContentSubstitutor.new(dir).substitute_in('some_file', 'some_file', [])
        expect(File.read(dir + '/some_file')).to eq(content)
      end
    end

    it "updates the mapped strings" do
      original_content = <<~EOT
      Dr Who
      dr_who dr_who
      drWho
      DR_WHO
      EOT

      expected_content = <<~EOT
      Dr Who
      bugs_bunny bugs_bunny
      bugsBunny
      BUGS_BUNNY
      EOT

      mappings = [
        ["dr_who", "bugs_bunny"],
        ["drWho", "bugsBunny"],
        ["DR_WHO", "BUGS_BUNNY"],
        ["dr-who", "bugs-bunny"]
      ]

      with_file_in_tmpdir 'some_file', original_content do |dir|
        CrudeRenamer::FileContentSubstitutor.new(dir).substitute_in('some_file', 'some_file', mappings)
        expect(File.read(dir + '/some_file')).to eq(expected_content)
      end
    end

    it "renames the filename, mapping strings and retaining file permissions" do
      original_content = "Some content before\n"
      expected_content = "Some content after\n"
      mappings = [["before", "after"]]

      with_file_in_tmpdir 'before_file', original_content do |dir|
        `chmod 755 #{File.join(dir, 'before_file')}`
        expect(FileTest.exist?(File.join(dir, 'before_file'))).to be true
        expect(`ls -al #{File.join(dir, 'before_file')}|cut -d ' ' -f 1`.strip).to eq '-rwxr-xr-x'

        CrudeRenamer::FileContentSubstitutor.new(dir).
        substitute_in('before_file', 'after_file', mappings)

        expect(FileTest.exist?(File.join(dir + '/before_file'))).to be false
        expect(File.read(dir + '/after_file')).to eq(expected_content)
        expect(`ls -al #{File.join(dir, 'after_file')}|cut -d ' ' -f 1`.strip).to eq '-rwxr-xr-x'
      end
    end

    it "does not add a newline to a file that does not have it" do
      original_content = "Some content before"
      expected_content = "Some content after"
      mappings = [["before", "after"]]

      with_file_in_tmpdir 'before_file', original_content do |dir|
        CrudeRenamer::FileContentSubstitutor.new(dir).
        substitute_in('before_file', 'after_file', mappings)

        expect(File.read(dir + '/after_file')).to eq(expected_content)
      end
    end
  end

  describe "move_directory" do
    it "moves a directory" do
      with_directory_in_tmpdir 'ducks/fictive/mallards' do |dir|
        expect(FileTest.directory?(File.join(dir, 'ducks/fictive/mallards'))).to be true

        CrudeRenamer::FileContentSubstitutor.new(dir).
        move_directory('ducks/fictive', 'ducks/cartoon')

        expect(FileTest.directory?(File.join(dir, 'ducks/fictive/mallards'))).to be false
        expect(FileTest.directory?(File.join(dir, 'ducks/cartoon/mallards'))).to be true
      end
    end
  end
end
