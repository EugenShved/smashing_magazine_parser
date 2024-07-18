# frozen_string_literal: true

require_relative "html_document_parser"

class ImageDownloader
  attr_reader :ref_image_links, :page_link

  BASE_URL = "https://smashingmagazine.com"

  def initialize(image_links, page_link)
    @ref_image_links = image_links
    @page_link = "#{BASE_URL}#{page_link}"
  end

  def download
    image_link_storage = parse_urls(fetch_doc(page_link))
    ref_image_links.each do |ref_link|
      pattern = extract_pattern(ref_link)
      save_images(filter_urls_by_pattern(image_link_storage, pattern))
    end
  end

  private

  def save_images(urls)
    return if urls.empty?

    urls.each do |url|
      file_name = File.basename(OpenURI.open_uri(url.to_s).read)
      File.open(file_name, "wb") do |file|
        file.write(OpenURI.open_uri(url.to_s).read)
      end
      puts "Downloaded #{file_name}"
    end
  end

  def parse_urls(doc)
    doc.css("a[href]")
      .map { |a| a["href"] }
      .select { |url| url.include?("wallpapers") && url.include?("files") }
      .uniq
  end

  def extract_pattern(url)
    url.split("/").last.split("-preview").first
  end

  def filter_urls_by_pattern(urls, pattern)
    urls.select { |url| url.include?(pattern) }
  end
end
