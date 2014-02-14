require 'simplecov'
require 'metric_fu'
require_relative 'external_client'
require_relative 'rcov_format_coverage'

class SimpleCov::Formatter::MetricFu

  def format(result)
    rcov_text = FormatLikeRCov.new(result).format
    client = MetricFu::RCovTestCoverageClient.new(coverage_file_path)
    client.post_results(rcov_text)
  end

  attr_writer :coverage_file_path

  def coverage_file_path
    @coverage_file_path || self.coverage_file_path = default_coverage_file_path
  end

  def default_coverage_file_path
    File.join(SimpleCov.root, 'coverage', 'rcov', output_file_name)
  end

  # TODO: make the coverage path more sane
  # def output_path
  #   metric = :rcov
  #   MetricFu::Metric.get_metric(metric).run_options[:output_directory] ||
  #   begin
  #     metric_directory = MetricFu::Io::FileSystem.scratch_directory('coverage')
  #     MetricFu::Utility.mkdir_p(metric_directory, :verbose => false)
  #   end
  # end

  def output_file_name
    'rcov.txt'
  end

  class FormatLikeRCov
    def initialize(result)
      @result = result
    end

    def format
      content = "metric_fu shift the first line\n"
      @result.source_files.each do |source_file|
        content << "=" * 80
        content << "\n #{simple_file_name(source_file)}\n"
        content << "=" * 80
        content << "\n"
        source_file.lines.each do |line|
          content << (line.missed? ? '!!'  : '  ')
          content << " #{line.src.chomp}\n"
        end
        content << "\n"
      end
      content
    end

    def simple_file_name(source_file)
      source_file.filename.gsub(SimpleCov.root, '.')
    end
  end

end