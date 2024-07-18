# frozen_string_literal: true

require "nokogiri"
require "open-uri"

module HtmlDocumentParser
  def fetch_doc(url)
    html = OpenURI.open_uri(url.to_s).read
    Nokogiri::HTML(html)
  end
end
