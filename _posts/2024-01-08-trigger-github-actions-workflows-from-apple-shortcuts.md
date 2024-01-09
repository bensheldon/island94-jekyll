---
title: "Trigger GitHub Actions workflows with inputs from Apple Shortcuts"
date: 2024-01-08 15:18 PST
published: true
tags: []
---

I've been using Apple Shortcuts to invoke GitHub Actions workflows to create webpage bookmarks. It's been great! (disclosure: I do work at GitHub)

My use case: I've been wanting to quit Pinboard.in, so I needed an alternative way to create and host my web bookmarks, some of which date back to ~2005 del.icio.us vintage. It’s been easy enough for me to export of all my bookmarks (`settings -> backup -> JSON`) and [convert them to YAML files](https://github.com/bensheldon/bookmarks/blob/bc85a68ea61844ad0b11b823bef355a1879b0462/script/import_pinboard.rb#L7-L20) to be served by Jekyll and GitHub Pages. But I also needed an easy way to create new bookmarks that would work on all my Apple devices. I ended up with:

1. Bookmarks are organized as individual yaml files, in this [blog's repository](https://github.com/bensheldon/island94-jekyll/tree/a524b8fce50bb315d1a1f1e9c27e572a7af31ccc/_bookmarks).
2. A [Ruby script](https://github.com/bensheldon/island94-jekyll/blob/a524b8fce50bb315d1a1f1e9c27e572a7af31ccc/scripts/bookmark.rb) to take some simple inputs (url, title, notes), generate a new yaml file, and commit it to the repo using Octokit.
3. A GitHub Actions [workflow that accepts those same inputs](https://github.com/bensheldon/island94-jekyll/blob/a524b8fce50bb315d1a1f1e9c27e572a7af31ccc/.github/workflows/bookmark.yml#L3-L20)  and can be manually triggered, that runs the script. One thing to note is that I echo the inputs to `$GITHUB_STEP_SUMMARY` early in the workflow in case a later step errors, so I won't lose the bookmark details and can go back later and manually fix it up.
4. An Apple Shortcut that asks for those inputs (either implicitly via the Share Sheet or via text inputs) and then manually triggers the GitHub Actions workflow via the GitHub API.

The only difficult part for me was getting Apple Shortcuts to work nicely with the GitHub REST API. Here's what worked for me:

Use `Get Contents of URL` Action:

- URL: `https://api.github.com/repos/USER/REPOSITORY/actions/workflows/WORKFLOW.yml/dispatches`
- Method: `POST`
- Headers:
    - `Accept: application/vnd.github.v3+jsonp`
    - `Authorization: Bearer GITHUB_ACCESS_TOKEN`
- Request Body: `JSON`
    - `ref: main` (or whatever branch you're using)
    - `inputs (Dictionary):`
        - `INPUT: VALUE`
        - ... and your other GitHub Actions workflow inputs

Here's what it looks like all together (btw, [Dictionary-type inputs were broken in iOS 16 / Mac 13](https://www.reddit.com/r/shortcuts/comments/zlhva2/dictionaries_broken_in_162/) 😨) :

[![Screenshot of Apple Shortcut with the previous configuration](/uploads/2024-01/apple-shortcut.png)](/uploads/2024-01/apple-shortcut.png)
