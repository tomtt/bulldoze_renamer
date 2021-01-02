require 'support/temporary_file_tools'

RSpec.describe CrudeRenamer::FileContentSubstitutor do
  it "preserves file content if there are no mappings" do
    content = <<~EOT
      This should remain in tact
    EOT
    with_file_in_tmpdir 'some_file', content do |dir|
      CrudeRenamer::FileContentSubstitutor.new(dir).substitute_in('some_file', [])
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
      CrudeRenamer::FileContentSubstitutor.new(dir).substitute_in('some_file', mappings)
      expect(File.read(dir + '/some_file')).to eq(expected_content)
    end
  end

end
