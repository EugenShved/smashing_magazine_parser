# frozen_string_literal: true

require "rspec"
require_relative "../lib/image_analyzer"

RSpec.describe(ImageAnalyzer) do
  let(:api_key) { "XX-XX" }
  let(:urls) { ["http://foo.com/image1.jpg", "http://foo.com/image2.jpg"] }
  let(:theme) { "animals" }
  let(:analyzer) { described_class.new(urls, theme) }
  let(:mock_openai_client) { instance_double(OpenAI::Client) }

  before do
    allow(OpenAI::Client).to(receive(:new).and_return(mock_openai_client))
  end

  describe "#initialize" do
    it "initializes with urls and theme" do
      expect(analyzer.urls).to(eq(urls))
      expect(analyzer.theme).to(eq(theme))
    end
  end

  describe "#analyze" do
    let(:response) do
      {
        "choices" => [
          { "message" => { "content" => "1" } },
        ],
      }
    end

    before do
      allow(mock_openai_client).to(receive(:chat).and_return(response))
    end

    it "returns the list of URLs that match the theme" do
      expect(analyzer.analyze).to(eq(urls))
    end

    context "when URL match the theme" do
      let(:first_response) do
        {
          "choices" => [
            { "message" => { "content" => "1" } },
          ],
        }
      end

      let(:content) do
        "Check the image http://foo.com/image1.jpg and say me in one number 1 or 0 does it similar for theme - animals"
      end

      before do
        allow(mock_openai_client).to(receive(:chat).with(hash_including(messages: [{
          role: "user",
          content: content,
        }])).and_return(response))
      end

      it "returns only the URLs that match the theme" do
        expect(analyzer.analyze).to(eq(["http://foo.com/image1.jpg", "http://foo.com/image2.jpg"]))
      end
    end

    context "when URL does not match the theme" do
      let(:response) do
        {
          "choices" => [
            { "message" => { "content" => "0" } },
          ],
        }
      end

      let(:content) do
        "Check the image http://foo.com/image2.jpg and say me in one number 1 or 0 does it similar for theme - animals"
      end

      before do
        allow(mock_openai_client).to(receive(:chat).with(hash_including(messages: [{
          role: "user",
          content: content,
        }])).and_return(response))
      end

      it "returns only the URLs that match the theme" do
        expect(analyzer.analyze).to(eq([]))
      end
    end
  end
end
