# frozen_string_literal: true

require "rspec"
require "nokogiri"
require "open-uri"
require "date"

require_relative "../lib/link_finder"

describe LinkFinder do
  let(:current_date) { Date.today }
  let(:href_html) { '<a href="https://www.foo.com/2024/05/desktop-wallpaper-calendars-may/"></a>' }
  let(:invalid_href_html) { '<a href="https://www.foo.com/2024/04/desktop-wallpaper-calendars-march/"></a>' }
  let(:expected_href) { "https://www.foo.com/2024/05/desktop-wallpaper-calendars-may/" }

  describe "#validate_date_range" do
    it "raises OutOfRangeError for date before July 2008" do
      finder = described_class.new(6, 2008)
      expect { finder.find }.to(raise_error(
        OutOfRangeError,
        LinkFinder::EDGE_CASE_ERROR,
      ))
    end

    it "raises OutOfRangeError for date in the future" do
      future_date = current_date.next_month
      finder = described_class.new(future_date.month, future_date.year)
      expect { finder.find }.to(raise_error(
        OutOfRangeError,
        LinkFinder::EDGE_CASE_ERROR,
      ))
    end

    it "do not raise an error" do
      finder = described_class.new(7, 2023)
      expect { finder.send(:validate_date_range) }.not_to(raise_error)
    end
  end

  describe "#find_links" do
    it "parses URLs correctly" do
      finder = described_class.new(current_date.month, current_date.year)
      allow(finder).to(receive(:fetch_doc).and_return(Nokogiri::HTML(href_html)))
      urls = finder.send(:find_links)
      expect(urls).to(include(expected_href))
    end
  end

  describe "#filter_links" do
    let(:urls_with_first_month) do
      [
        "https://www.foo.com/2021/12/desktop-wallpaper-calendars-december-2022/",
        "https://www.foo.com/2022/01/desktop-wallpaper-calendars-january-2023/",
      ]
    end
    let(:urls) do
      [
        "https://www.foo.com/2023/06/desktop-wallpaper-calendars-june-2023/",
        "https://www.foo.com/2023/07/desktop-wallpaper-calendars-july-2023/",
      ]
    end

    it "returns correct link for the first month" do
      finder = described_class.new(1, 2022)
      link = finder.send(:filter_links, urls_with_first_month)
      expect(link).to(eq("https://www.foo.com/2022/01/desktop-wallpaper-calendars-january-2023/"))
    end

    it "returns the correct link" do
      finder = described_class.new(7, 2023)

      link = finder.send(:filter_links, urls)
      expect(link).to(eq("https://www.foo.com/2023/07/desktop-wallpaper-calendars-july-2023/"))
    end
  end

  describe "#find" do
    let(:finder) { described_class.new(5, 2024) }

    it "returns the correct link" do
      allow(finder).to(receive(:fetch_doc).and_return(Nokogiri::HTML(href_html)))
      link = finder.find
      expect(link).to(eq(expected_href))
    end

    it "raises LinkNotFoundError if no link is found" do
      allow(finder).to(receive(:fetch_doc).and_return(Nokogiri::HTML(invalid_href_html)))
      expect { finder.find }.to(raise_error(LinkNotFoundError, LinkFinder::LINK_NOT_FOUND_ERROR))
    end
  end
end
