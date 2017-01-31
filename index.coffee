_ = require 'lodash'
fp = require 'lodash/fp'

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

  else
    throw 'Needs a command !'
