# frozen_string_literal: true

require_relative "html_document_parser"

class ImageLinkFinder
  include HtmlDocumentParser
  BASE_URL = "https://www.smashingmagazine.com/"
  attr_reader :link

  def initialize(link)
    @link = "#{BASE_URL}#{link}"
  end

  def find
    parse_urls(fetch_doc(link))
  end

  private

  def parse_urls(doc)
    doc.css("a[href]")
      .map { |a| a["href"] }
      .select do |link|
      link.include?("preview") &&
        !link.include?("-opt") &&
        !link.include?("archive.")
    end.uniq
  end
end
