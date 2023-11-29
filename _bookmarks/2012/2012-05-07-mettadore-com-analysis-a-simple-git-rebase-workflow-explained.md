---
link: http://mettadore.com/analysis/a-simple-git-rebase-workflow-explained/
date: 2012-05-07 15:00 UTC
published: true
title: A Simple Git Rebase Workflow, Explained - MettaProgramming | MettaProgramming
tags:
- development
- git
---

There’s a lot more that rebase can do, a look at the man page or The Git Book can tell you a lot more.

As a summary:

checkout a local private branch and work in it.
Use ‘git rebase’ frequently to keep up to date with the master repo
Merge changes into master from your rebased local repo
Furthermore, when you merge your changes, you have three choices:

git merge {branch}: brings in all commits/history from branch
git rebase {branch}: same as above, basically
git merge –squash {branch}: brings in changes as one commit, throws away history
git rebase -i {branch}: brings in changes as one commit, condenses all history into a single log entry
Git rebase takes some getting used to, but the results are worth it. I highly recommend giving it a try.
