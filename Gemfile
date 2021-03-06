source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.5.1"

gem "pg", "~> 0.18"
gem "puma"
gem "rack-canonical-host"
gem "rails", "~> 5.1.4"
gem "recipient_interceptor"
gem "suspenders"
gem "uglifier"
gem 'octokit', '~> 4.8'
gem 'graphql-client', '~> 0.12'
gem 'erubis'
gem 'yaml_db'
gem 'faraday', '~> 0.15'
gem 'sentimental', '~> 1.4'

group :development do
  gem "listen"
  gem "rack-mini-profiler", require: false
  gem "spring"
  gem "web-console"
end

group :development, :test do
  gem "awesome_print"
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "pry-rails"
end

group :test do
  gem 'rspec-rails', '~> 3.7'
  gem "formulaic"
  gem "launchy"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
end

group :production do
  gem "rack-timeout"
end
