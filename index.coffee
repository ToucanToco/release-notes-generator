args = require('yargs').argv

github = require './github'
PARAMETERS = require './parameters'

OWNER = args.owner
REPO = args.repo

throw 'Need a owner!' unless OWNER
throw 'Need a repo!' unless REPO

releaseNotes = require './release-notes'


_getPullRequestBase = (config) ->
  github.pullRequests.get
    owner: config.owner
    repo: config.repo
    number: config.pr
  .then (pr) -> pr.base.ref


updatePullRequestBody = (config) ->
  _getPullRequestBase config
  .then (base) ->
    github.pullRequests.update
      owner: config.owner
      repo: config.repo
      number: config.pr
      body: config.body
      base: base

###
Available commands:
- release-notes

###
COMMAND = args._[0]

switch COMMAND
  when 'release-notes'
    PR = args.pr
    LOG = args.log
    throw 'Need a pr!' unless PR

    releaseNotes.generate
      owner: OWNER
      repo: REPO
      pr: PR
      categories: PARAMETERS.categories
    .then (releaseNotes) ->
      if LOG
        console.log releaseNotes
      else
        updatePullRequestBody
          owner: OWNER
          repo: REPO
          pr: PR
          body: releaseNotes

  when 'preprare-release'
    BETA = args.beta
    BRANCHES = PARAMETERS.branches
    TITLE = args.title

    throw 'This release should have a title!' unless TITLE?
    throw 'You must define a master branch!' unless BRANCHES.master?
    throw 'You must define a dev branch!' unless BRANCHES.dev?

    if BETA
      throw 'You must define a beta branch!' unless BRANCHES.beta?
      baseBranch = BRANCHES.beta
      targetBranch = BRANCHES.dev
    else
      baseBranch = BRANCHES.master
      # If there is a beta branch, releases should come from there!
      targetBranch = BRANCHES.beta or BRANCHES.dev

    releaseTitle = "Release #{TITLE}"
    releaseTitle += ' beta' if BETA

    # Is there already a PR?
    github.pullRequests.create
      owner: OWNER
      repo: REPO
      title: releaseTitle
      head: targetBranch
      base: baseBranch
    .catch (e) ->
      # Check if a PR already exists
      github.pullRequests.getAll
        owner: OWNER
        repo: REPO
        head: targetBranch
        base: baseBranch
      .then (prs) ->
        github.pullRequests.update
          owner: OWNER
          repo: REPO
          number: prs[0].number
          title: releaseTitle
    .then (pr) ->
      releaseNotes.generate
        owner: OWNER
        repo: REPO
        pr: pr.number
        categories: PARAMETERS.categories
      .then (releaseNotes) ->
        updatePullRequestBody
          owner: OWNER
          repo: REPO
          pr: pr.number
          body: releaseNotes

  else
    throw 'Needs a command !'
