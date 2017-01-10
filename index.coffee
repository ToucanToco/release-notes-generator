GitHubApi = require 'github'
_ = require 'lodash'
fp = require 'lodash/fp'

args = require('yargs').argv
AUTH = require './auth.json'

OWNER = args.owner
REPO = args.repo
PR = args.pr
LOG = args.log

throw 'Generate a GitHub token first!' unless AUTH.token?
throw 'Need a owner!' unless OWNER
throw 'Need a repo!' unless REPO
throw 'Need a pr!' unless PR

CATEGORIES = require 'categories'

github = new GitHubApi
  # debug: true
  protocol: 'https'
  host: 'api.github.com'
  headers:
    'user-agent': 'Toucan Toco release notes' # GitHub is happy with a unique user agent
  Promise: Promise
  followRedirects: false
  default: true
  timeout: 5000

github.authenticate
  type: 'oauth'
  token: auth.token


_getPRMergedForRelease = (config) ->
  github.pullRequests.getCommits
    owner: config.owner
    repo: config.repo
    number: config.pr
    per_page: 100
  .then (res) ->
    commitMessages = _.map res, (c) -> c.commit.message
    prNumberRegex = /#\d*/gm
    mergedPullRequests = _ commitMessages
      .map (cm) -> prNumberRegex.exec(cm)?[0]
      .without undefined
      .uniq()
      .map (s) -> +s.replace '#', ''
      .value()

_getPR = (config) -> (n) ->
  github.pullRequests.get
    owner: config.owner
    repo: config.repo
    number: n

_getIssue = (config) -> (n) ->
  github.issues.get
    owner: config.owner
    repo: config.repo
    number: n

_formatPRLine = (pr) -> "##{pr.number} #{pr.title}"


_createChangelogLinesForCategory = (label) ->
  if label?
    filter = (pr) -> _.includes pr.labels, label
  else
    filter = (pr) -> _.isEmpty pr.labels

  (prs) ->
    _ prs
    .filter filter
    .map (pr) -> pr.changelogLine
    .join '\n'


generateReleaseNotes = (config) ->
  _getPRMergedForRelease config
  .then (mergedPRNumbers) ->
    Promise.all _.map mergedPRNumbers, _getIssue config

  .then fp.map (pr) ->
    pr.labels = _.map pr.labels, (l) -> l.name
    pr.changelogLine = _formatPRLine pr
    _.pick pr, ['title', 'labels', 'number', 'changelogLine']

  .then (prs) ->
    config.categories.map (category) ->
      changelogLines = _createChangelogLinesForCategory(category.label) prs
      if _.isEmpty changelogLines
        ""
      else
        """
        ## #{category.title}
        #{_createChangelogLinesForCategory(category.label) prs}


        """
    .join ''


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


generateReleaseNotes
  owner: OWNER
  repo: REPO
  pr: PR
  categories: CATEGORIES
.then (releaseNotes) ->
  if LOG
    console.log releaseNotes
  else
    updatePullRequestBody
      owner: OWNER
      repo: REPO
      pr: PR
      body: releaseNotes
