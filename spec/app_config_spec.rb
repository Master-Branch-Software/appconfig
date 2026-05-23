# frozen_string_literal: true

require "tempfile"

describe AppConfig do
  after { AppConfig.reset! }

  describe "with string values" do
    it "returns an environment variable when present" do
      env_variable = "MY_VARIABLE"
      value = "expected_value"

      ClimateControl.modify(env_variable => value) do
        expect(AppConfig.send(env_variable.downcase)).to eq value
      end
    end

    it "returns an empty string when missing" do
      expect(AppConfig.missing_variable).to eq ""
    end

    it "returns an empty string when empty" do
      env_variable = "MY_VARIABLE"
      value = nil

      ClimateControl.modify(env_variable => value) do
        expect(AppConfig.send(env_variable.downcase)).to eq ""
      end
    end
  end

  describe "with boolean values" do
    it "returns an environment variable when present" do
      env_variable = "MY_VARIABLE"
      value = true

      ClimateControl.modify(env_variable => value.to_s) do
        expect(AppConfig.send("#{env_variable.downcase}?")).to eq value
      end
    end

    it "returns false when missing" do
      expect(AppConfig.missing_bool?).to be false
    end

    it "returns false when empty" do
      env_variable = "MY_VARIABLE"
      value = nil

      ClimateControl.modify(env_variable => value) do
        expect(AppConfig.send("#{env_variable.downcase}?")).to be false
      end
    end

    describe "and conversions" do
      it "returns a bool properly" do
        env_variable = "MY_VARIABLE"
        value = "false"

        ClimateControl.modify(env_variable => value) do
          expect(AppConfig.send("#{env_variable.downcase}?", conversion: :to_bool)).to be false
        end

        value = "FALSE"

        ClimateControl.modify(env_variable => value) do
          expect(AppConfig.send("#{env_variable.downcase}?", conversion: :to_bool)).to be false
        end
      end

      it "returns a string conversion to numeric properly" do
        env_variable = "MY_VARIABLE"
        value = 1234

        ClimateControl.modify(env_variable => value.to_s) do
          expect(AppConfig.send("#{env_variable.downcase}", conversion: :to_i)).to eq value
        end
      end
    end

    describe "default values" do
      it "returns a value if it exists" do
        env_variable = "MY_VARIABLE"
        value = 1234

        ClimateControl.modify(env_variable => value.to_s) do
          expect(AppConfig.send("#{env_variable.downcase}", default: value.to_s.reverse, conversion: :to_i)).to eq value
        end
      end

      it "returns a default if a value is missing" do
        env_variable = "MY_VARIABLE"
        value = 1234

        ClimateControl.modify(env_variable => nil) do
          expect(AppConfig.send("#{env_variable.downcase}", default: value, conversion: :to_i)).to eq value
        end
      end
    end
  end

  describe "with YAML config" do
    let(:yaml_content) do
      {
        "test" => {
          "aws_secret" => "yaml-secret",
          "feature_enabled" => true,
          "port" => 5432,
          "database" => {
            "host" => "localhost",
            "port" => 5432
          },
          "servers" => [
            { "name" => "web1" },
            { "name" => "web2" }
          ]
        }
      }.to_yaml
    end

    let(:config_file) do
      file = Tempfile.new(["app_config", ".yml"])
      file.write(yaml_content)
      file.close
      file
    end

    before do
      ENV["RAILS_ENV"] = "test"

      AppConfig.configure do |config|
        config.config_file = config_file.path
      end
    end

    after { config_file.unlink }

    it "returns a string value from YAML" do
      expect(AppConfig.aws_secret).to eq "yaml-secret"
    end

    it "returns a boolean value from YAML" do
      expect(AppConfig.feature_enabled?).to be true
    end

    it "returns a numeric value from YAML" do
      expect(AppConfig.port).to eq 5432
    end

    it "returns nested values via dot notation" do
      expect(AppConfig.database.host).to eq "localhost"
      expect(AppConfig.database.port).to eq 5432
    end

    it "converts arrays of hashes to OpenStructs" do
      expect(AppConfig.servers.first.name).to eq "web1"
      expect(AppConfig.servers.last.name).to eq "web2"
    end

    it "takes precedence over ENV" do
      ClimateControl.modify("AWS_SECRET" => "env-secret") do
        expect(AppConfig.aws_secret).to eq "yaml-secret"
      end
    end

    it "falls back to ENV when key is not in YAML" do
      ClimateControl.modify("OTHER_VALUE" => "from-env") do
        expect(AppConfig.other_value).to eq "from-env"
      end
    end

    it "exposes the loaded config via .config" do
      expect(AppConfig.config).to be_a OpenStruct
      expect(AppConfig.config.aws_secret).to eq "yaml-secret"
    end
  end

  describe ".reset!" do
    it "clears the loaded YAML config" do
      AppConfig.reset!

      expect(AppConfig.config).to be_nil
    end
  end
end
