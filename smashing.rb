# frozen_string_literal: true

require "./lib/argument_parser"

class SmashingCLI
  class << self
    def run
      arguments = ArgumentParser.new.parse
      LinkFinder.new(arguments[:month], arguments[:year]).find
    rescue CliArgumentError => e
      puts e.message
    end
  end
end

SmashingCLI.run
