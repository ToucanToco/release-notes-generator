# Release generator


## Install

    npm install

## Authentification

[Generate a new token](https://github.com/settings/tokens/new) and put it in
the `auth.json` file.

## Customization

Modify `parameters.coffee` according to your needs:
- put branches names
- put your desired tags in categories

## Usage
Available commands:
- `release-notes`
- ....

### Release notes `release-notes`
Generates a changelog using merged PRs and their labels for categorization.

    npm start -- release-notes --owner [owner's account] --repo [repo name] --pr [pr number] [--log]

Options:
- `--log`: only log the release notes, don't update the PR description

Example: generates the changelog for the release PR #736 of ToucanToco/tucana
and only displays it

    npm start -- release-notes --owner ToucanToco --repo tucana --pr 736 --log

## Prepare release `prepare-release`
Creates or update a Pull Request and generate changelog in its body.

    npm start -- preprare-release --owner [owner's account] --repo [repo name] --title [Release codename] [--beta]

Options:
- `--beta`: instead of from dev (or beta) to master branch, creates a PR from
  dev to beta

Example: creates the PR from dev to next for ToucanToco/tucana

    npm start -- preprare-release --owner ToucanToco --repo tucana --title "Purple Lilac Panda" --beta
