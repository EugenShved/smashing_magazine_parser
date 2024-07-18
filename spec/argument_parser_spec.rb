# frozen_string_literal: true

require "rspec"
require_relative "../lib/argument_parser"

RSpec.describe(ArgumentParser) do
  subject { described_class.new }
  context "when 2 arguments provided" do
    let(:args) { %w[--month 022024 --theme animals] }
    before { ARGV.replace(args) }

    it "parses the arguments correctly" do
      result = subject.parse
      expect(result).to(eq({ month: "02", year: "2024", theme: "animals" }))
    end
  end

  context "when month argument is missing" do
    let(:args) { %w[--theme animals] }
    before { ARGV.replace(args) }

    it "raises a CliArgumentError" do
      expect { subject.parse }.to(raise_error(
        CliArgumentError,
        "Please include the --month argument",
      ))
    end
  end

  context "when theme argument is missing" do
    let(:args) { %w[--month 022024] }
    before { ARGV.replace(args) }

    it "raises a CliArgumentError" do
      expect { subject.parse }.to(raise_error(
        CliArgumentError,
        "Please include the --theme argument",
      ))
    end
  end

  context "when arguments are missing" do
    let(:args) { [] }
    before { ARGV.replace(args) }

    it "raises a CliArgumentError" do
      expect { subject.parse }.to(raise_error(
        CliArgumentError,
        "Please include the --month argument",
      ))
    end
  end
end
