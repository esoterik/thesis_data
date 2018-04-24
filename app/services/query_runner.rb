class QueryRunner
  def initialize(query_class, repo, start_point: nil)
    @query_class = query_class
    @repo = repo
    generate_next_querier(start_point)
  end

  def run
    calculate_next_reset_time
    result = querier.run
    while result != 'Complete'
      time = reset_time - Time.zone.now + 60.seconds
      puts "Completed a run, starting the next one in #{time} seconds"
      generate_next_querier(result)
      sleep(time)
      calculate_next_reset_time
      result = querier.run
    end
    puts 'Done!'
  end

  private

  attr_reader :repo, :querier, :reset_time, :query_class

  def calculate_next_reset_time
    time = Github.rate_limit_check.original_hash.dig(*%w(data rateLimit resetAt))
    @reset_time = Time.iso8601(time)
  end

  def generate_next_querier(start_point)
    @querier = query_class.send(:new, repo, start_point: start_point)
  end
end
