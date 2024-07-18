# frozen_string_literal: true

require "./lib/argument_parser"

class SmashingCLI
  class << self
    def run
      ArgumentParser.new.parse
    rescue CliArgumentError => e
      puts e.message
    end
  end
end

SmashingCLI.run
