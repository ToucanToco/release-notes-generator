GitHubApi = require 'github'

AUTH = require './auth.json'
throw 'Generate a GitHub token first!' unless AUTH.token?

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
  token: AUTH.token

module.exports = github
