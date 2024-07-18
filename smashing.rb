# frozen_string_literal: true

require "./lib/argument_parser"

class SmashingCLI
  class << self
    def run
      arguments = ArgumentParser.new.parse
      link = LinkFinder.new(arguments[:month], arguments[:year]).find
      image_links = ImageLinkFinder.new(link).find
      verified_image_links = ImageAnalyzer.new(image_links, arguments[:theme]).analyze
      ImageDownloader.new(verified_image_links, link).download
    rescue OutOfRangeError, CliArgumentError, LinkNotFoundError => e
      puts e.message
    end
  end
end

SmashingCLI.run
