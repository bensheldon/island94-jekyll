#! /usr/bin/env ruby
require 'bundler/setup'

require 'optparse'
require 'octokit'
require_relative 'models/bookmark'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: bookmark.rb [options]"

  opts.on("--link BOOKMARK_LINK", String)
  opts.on("--title [BOOKMARK_TITLE]", String)
  opts.on("--tags [BOOKMARK_TAGS]", String)
  opts.on("--notes [BOOKMARK_NOTES]", String)
  opts.on("--commit [REPOSITORY#BRANCH]", String)
  opts.on("--save")
end.parse!(into: options)

options[:link] ||= ENV['BOOKMARK_LINK']
raise ArgumentError, "--link BOOKMARK_LINK is required" unless options[:link]

options[:link] = options[:link].strip

options[:title] ||= ENV['BOOKMARK_TITLE']
options[:title] = options[:title]&.strip

options[:tags] ||= ENV['BOOKMARK_TAGS']
options[:tags] = Array(options[:tags]&.split(",")&.map(&:strip))

if $stdin.stat.pipe?
  options[:notes] ||= $stdin.read&.strip
end
options[:notes] = ENV['BOOKMARK_NOTES'] if options[:notes].nil? || options[:notes].empty?

bookmark = Bookmark.new(link: options[:link], title: options[:title], notes: options[:notes], tags: options[:tags])
puts bookmark.to_s

if bookmark.title.nil? || bookmark.title.empty?
  puts "\n\n=== Fetching title \n\n"
  bookmark.fetch_title
  puts bookmark.title
end

puts "\n\n========================\n\n"

if options[:save]
  bookmark.save
  puts "Saved to #{bookmark.filepath}"
end

if options[:commit]
  require 'octokit'
  raise "GITHUB_TOKEN is required" unless ENV['GITHUB_TOKEN']
  github = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  repo, branch = options[:commit].strip.split("#")

  raise ArgumentError, "--commit argument is missing value in form of: 'user/repo#branch' " unless repo && branch

  # Use the GitHub API to create a new commit
  result = github.create_contents(
    repo,
    bookmark.filepath,
    "Add bookmark for #{bookmark.link}",
    bookmark.to_s,
    branch: branch
  )

  puts "Committed to #{result.content.html_url}"
end
