require 'uri'
require 'yajl'
require 'octokit'

def github_issues_count_by_repo_and_labels(repo, labels)
  Octokit.configure do |c|
    c.auto_paginate = true
    c.access_token = "31d0e90cb5c2154e49e0247d7823aa768ba7c346"
  end
  #Octokit.auto_paginate = true
  
  issues = Octokit.issues(repo, {labels: labels, state: 'closed'})
  issues += Octokit.issues(repo, {labels: labels, state: 'open'})
  issues.count
end

def bithub_events_count_by_tags(tags, endpoint=nil)
  endpoint = endpoint || 'http://bithub.com/api/events/'
  tags = tags.split(',') if tags.is_a? String
  
  url = endpoint + '?'
  url += tags.reduce('') {|m,tag| m += "tag[]=#{tag}&"}
  url += 'count=*'

  response = Net::HTTP.get_response(URI(url))
  parsed = Yajl::Parser.parse(response.body, :symbolize_keys => true)
  parsed[:count]
end

describe "Bugs and features counts integrity" do
  @repos = ['canjs','funcunit','testee.js','jquerypp','documentjs','steal']
  # skipped: javascriptmvc, donejs, canui

  # Bugs
  @repos.each do |repo|
    it "matches 'bug' counts for '#{repo}' from Github with ones from Bithub" do
      github_count = github_issues_count_by_repo_and_labels('bitovi/'+repo, 'bug')
      bithub_count = bithub_events_count_by_tags('issues_event,bug,'+repo)

      puts "'bug' counts for '#{repo}' => github: #{github_count}, bithub: #{bithub_count}"      
      expect(github_count).to eq bithub_count
    end    
  end

  # Features
  @repos.each do |repo|
    it "matches 'feature' counts for '#{repo}' from Github with ones from Bithub" do
      github_count = github_issues_count_by_repo_and_labels('bitovi/'+repo, 'feature')
      github_count += github_issues_count_by_repo_and_labels('bitovi/'+repo, 'feature request')
      github_count += github_issues_count_by_repo_and_labels('bitovi/'+repo, 'enhancement')
      
      bithub_count = bithub_events_count_by_tags('issues_event,feature,'+repo)

      puts "'feature' counts for '#{repo}' => github: #{github_count}, bithub: #{bithub_count}"      
      expect(github_count).to eq bithub_count
    end    
  end
  
end
