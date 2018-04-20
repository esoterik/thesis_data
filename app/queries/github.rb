require 'graphql/client/http'

module Github
  HTTPAdapter = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
    def headers(context)
      token = File.read('github_access_token').chomp
      { 'Authorization' => "Bearer #{token}" }
    end
  end

  Schema = GraphQL::Client.load_schema('github_graphql_schema.json')

  Client = GraphQL::Client.new(schema: Schema, execute: HTTPAdapter)
end
