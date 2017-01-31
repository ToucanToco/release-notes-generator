github = require './github'

_getPRMergedForRelease = (config) ->
  github.pullRequests.getCommits
    owner: config.owner
    repo: config.repo
    number: config.pr
    per_page: 100
  .then (res) ->
    commitMessages = _.map res, (c) -> c.commit.message
    prNumberRegex = /#\d*/
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

module.exports =
  generate: generateReleaseNotes
