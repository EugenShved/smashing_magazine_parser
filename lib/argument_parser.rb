require 'optparse'

class CliArgumentError < StandardError; end

class ArgumentParser
  CLI_ARGUMENTS = %i[month theme].freeze

  def initialize
    @options = {}
  end

  def parse
    OptionParser.new do |parser|
      parser.on('--month MONTH', 'Specify the month') { |month| @options[:month] = month }
      parser.on('--theme THEME', 'Specify the theme') { |theme| @options[:theme] = theme }
    end.parse!
    check_arguments
    parse_date(@options[:month]).merge({theme: @options[:theme]})
  end

  private

  def parse_date(date)
    { month: date[0..1], year: date[2..] }
  end

  def check_arguments
    CLI_ARGUMENTS.each do |arg|
      error_message = "Please include the --#{arg} argument"
      raise CliArgumentError, error_message unless @options.keys.include?(arg)
    end
  end
end

