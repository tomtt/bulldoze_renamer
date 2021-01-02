RSpec.describe CrudeRenamer::StringInflector do
  describe "mappings" do
    it "has all mappings for underscored strings" do
      expected_mappings = {
        current_inflection: :underscore,
        target_inflection: :underscore,
        inflections: {
          underscore: { current: "dr_who", target: "roger_rabbit" },
          camelize: { current: "DrWho", target: "RogerRabbit" },
          dasherize: { current: "dr-who", target: "roger-rabbit" },
          upcase: { current: "DR_WHO", target: "ROGER_RABBIT" },
          js_camelize: {current: "drWho", target: "rogerRabbit"}
        }
      }
      expect(CrudeRenamer::StringInflector.new('dr_who', 'roger_rabbit').mappings).to eq(expected_mappings)
    end

    it "omits duplicate mappings for simple strings" do
      expected_mappings = {
        current_inflection: :camelize,
        target_inflection: :camelize,
        inflections: {
          underscore: { current: "rick", target: "morty" },
          camelize: { current: "Rick", target: "Morty" },
          upcase: { current: "RICK", target: "MORTY" }
        }
      }
      expect(CrudeRenamer::StringInflector.new('Rick', 'Morty').mappings).to eq(expected_mappings)
    end

    it "defers inflecting to active_support" do
      allow(ActiveSupport::Inflector).to receive(:underscore).and_return 'mocked_inflector_underscore'
      allow(ActiveSupport::Inflector).to receive(:camelize).and_return 'MockedInflectorCamelize'
      allow(ActiveSupport::Inflector).to receive(:dasherize).and_return 'mocked-inflector-dasherize'

      # Expected is that reflections contain whatever ActiveSupport::Inflector returns
      # additionally :upcase returns upcase of whatever :underscore returns and
      # :js_camelize returns whatever :camelize returns with the first character
      # downcased
      expected_mappings = {
        current_inflection: :js_camelize,
        target_inflection: :upcase,
        inflections: {
          underscore: {
            current: "mocked_inflector_underscore",
            target: "mocked_inflector_underscore"
          },
          camelize: {
            current: "MockedInflectorCamelize",
            target: "MockedInflectorCamelize"
          },
          dasherize: {
            current: "mocked-inflector-dasherize",
            target: "mocked-inflector-dasherize"
          },
          upcase: {
            current: "MOCKED_INFLECTOR_UNDERSCORE",
            target: "MOCKED_INFLECTOR_UNDERSCORE"
          },
          js_camelize: {
            current: "mockedInflectorCamelize",
            target: "mockedInflectorCamelize"
          }
        }
      }

      result = CrudeRenamer::StringInflector.new('mockedInflectorCamelize', 'MOCKED_INFLECTOR_UNDERSCORE').mappings
      expect(result).to eq(expected_mappings)
    end

    it "raises an error if the current string does not map to any of the inflections" do
      expect(-> { CrudeRenamer::StringInflector.new('current does-Not_Reflect', 'whatevs').mappings }).
      to raise_error(CrudeRenamer::StringInflector::StringDoesNotInflectToItselfError, "current does-Not_Reflect")
    end

    it "raises an error if the target string does not map to any of the inflections" do
      expect(-> { CrudeRenamer::StringInflector.new('whatevs', 'target does-Not_Reflect').mappings }).
      to raise_error(CrudeRenamer::StringInflector::StringDoesNotInflectToItselfError, "target does-Not_Reflect")
    end

    it "dasherizes camelcased current" do
      expected_mappings = {
        current_inflection: :camelize,
        target_inflection: :camelize,
        inflections: {
          underscore: { current: "dr_who", target: "roger_rabbit" },
          camelize: { current: "DrWho", target: "RogerRabbit" },
          dasherize: { current: "dr-who", target: "roger-rabbit" },
          upcase: { current: "DR_WHO", target: "ROGER_RABBIT" },
          js_camelize: {current: "drWho", target: "rogerRabbit"}
        }
      }
      expect(CrudeRenamer::StringInflector.new('DrWho', 'RogerRabbit').mappings).to eq(expected_mappings)
    end

    it "excludes mappings that are identical for current but different for target" do
      expected_mappings = {
        current_inflection: :camelize,
        target_inflection: :camelize,
        inflections: {
          underscore: { current: "jerry", target: "roger_rabbit" },
          camelize: { current: "Jerry", target: "RogerRabbit" },
          upcase: { current: "JERRY", target: "ROGER_RABBIT" }
        }
      }
      expect(CrudeRenamer::StringInflector.new('Jerry', 'RogerRabbit').mappings).to eq(expected_mappings)
    end
  end
end
