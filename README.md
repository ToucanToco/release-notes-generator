# Release notes
Generates a changelog using merged PRs and their labels for categorization.

## Install

    npm install

## Authentification

[Generate a new token](https://github.com/settings/tokens/new) and put it in
the `auth.json` file.

## Customization

Put your desired tags in `categories.coffee`.

## Usage

    npm start -- --repo [tucana/laputa] --pr [pr number] [--log]

Options:
- `--log`: only log the release notes, don't update the PR description

Example: generates the changelog for the release PR #736 of ToucanToco/tucana
and only displays it

  npm start -- --owner ToucanToco --repo tucana --pr 736 --log
