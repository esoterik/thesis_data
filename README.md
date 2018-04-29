# Thesis data

Requirements to run: Ruby version 2.5.1, bundler, postgreSQL. It also requires a GitHub API access token (place in `github_access_token`).

To set-up:
```
% bundle install
% rails db:create db:schema:load
```

To download information about a particular repository:
```
% rails c
> RepoQuery.new('repo_owner/repo_name')
> repo = Repo.find_by(name: 'repo_name')
> CommitsFetcherGraphql.new(repo).save_commits
> QueryRunner.new(IssuesFetcher, repo).run
> QueryRunner.new(PullRequestFetcher, repo).run
```
