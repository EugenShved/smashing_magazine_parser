# frozen_string_literal: true

require "open-uri"
require "openai"

class ImageAnalyzer
  API_KEY = "CHAT GPT API KEY"
  attr_reader :urls, :theme

  def initialize(urls, theme)
    @urls = urls
    @theme = theme
  end

  def analyze
    url_analytics = []
    urls.each do |url|
      verify_status = verify_image_by_theme(url)
      url_analytics << url if verify_status
    end
    url_analytics
  end

  private

  def verify_image_by_theme(url)
    content = "Check the image #{url} and say me in one number 1 or 0 does it similar for theme - #{theme}"
    response = chat_gpt_client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{ role: "user", content: content }],
        temperature: 0.2,
      },
    )
    response["choices"][0]["message"]["content"].to_i == 1
  end

  def chat_gpt_client
    @chat_gpt_client ||= OpenAI::Client.new(access_token: API_KEY)
  end
end
