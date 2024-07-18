# frozen_string_literal: true

require "nokogiri"
require "open-uri"
require "date"
require_relative "html_document_parser"

class OutOfRangeError < StandardError; end
class LinkNotFoundError < StandardError; end

class LinkFinder
  WALLPAPER_MAIN_PAGE_URL = "https://www.smashingmagazine.com/category/wallpapers/"
  WALLPAPER_PAGES_URL = "https://www.smashingmagazine.com/category/wallpapers/page"
  EDGE_CASE_ERROR = "Edge case: please select another date"
  LINK_NOT_FOUND_ERROR = "Link not found based on month argument"
  YEAR_POSITION_IN_URL = 1..4
  FIRST_RECORDED_YEAR = 2008
  FIRST_RECORDED_MONTH = 7
  MONTH_NAMES = (1..12).map { |month| Date::MONTHNAMES[month].downcase }
  include HtmlDocumentParser

  attr_reader :year, :month, :month_name, :current_date

  def initialize(month, year, current_date = Time.now)
    @month = month.to_i
    @year = year.to_i
    @month_name = MONTH_NAMES[@month - 1]
    @current_date = current_date
  end

  def find
    validate_date_range
    link = filter_links(find_links)
    raise LinkNotFoundError, LINK_NOT_FOUND_ERROR if link.nil?

    link
  end

  private

  def validate_date_range
    if year < FIRST_RECORDED_YEAR ||
        (year == FIRST_RECORDED_YEAR && month < FIRST_RECORDED_MONTH)
      raise OutOfRangeError, EDGE_CASE_ERROR
    end
    if year > current_date.year ||
        (year == current_date.year && current_date.month < month)
      raise OutOfRangeError, EDGE_CASE_ERROR
    end
  end

  def find_links(index = 1, urls_array = [])
    loop do
      fetched_url = index == 1 ? WALLPAPER_MAIN_PAGE_URL : "#{WALLPAPER_PAGES_URL}/#{index}"
      urls_array << parse_urls(fetch_doc(fetched_url))
      break if urls_array[-1][-1][YEAR_POSITION_IN_URL].to_i < year

      index += 1
    end
    urls_array.flatten
  end

  def filter_links(urls)
    link_storage = urls.filter do |url|
      url.include?(year.to_s) || url.include?((year - 1).to_s)
    end
    link_storage = link_storage.filter { |url| url.include?(month_name) }
    link_storage.count == 2 ? edge_case_for_january(link_storage) : link_storage[0]
  end

  def edge_case_for_january(link_storage)
    return link_storage[0] if month == 12

    link_storage[1]
  end

  def date_pattern
    @date_pattern ||= "#{year}/#{month.to_s.rjust(2, "0")}"
  end

  def parse_urls(doc)
    doc.css("a[href]")
      .map { |a| a["href"] }
      .select do |link|
      link.include?("desktop-wallpaper-calendars") && !link.include?("comments")
    end.uniq
  end
end
