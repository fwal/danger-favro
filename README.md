> **Warning**
> This repository is no longer maintained

---

# danger-favro
[![Build Status](https://img.shields.io/travis/fwal/danger-favro.svg)](https://travis-ci.org/fwal/danger-favro)
[![Coveralls](https://img.shields.io/coveralls/fwal/danger-favro.svg)](https://coveralls.io/github/fwal/danger-favro)
[![Gem](https://img.shields.io/gem/v/danger-favro.svg)](http://rubygems.org/gems/danger-favro)

A [Danger](http://danger.systems) plugin that detect [Favro](https://favro.com) cards referenced in code or PR title and displays basic information about them.

### Example

<img alt="Example" src="docs/comment-example.png" />

### Usage

<blockquote>Initiate the check
  <pre>
favro.check(
  user_name: "api-user",
  api_token: "api-token",
  organization_id: "org-id",
  key: "Test"
)</pre>
</blockquote>

<blockquote>Environment variables can also be used.
  <pre>
ENV["DANGER_FAVRO_USER_NAME"] = "api-user"
ENV["DANGER_FAVRO_API_TOKEN"] = "api-token"
ENV["DANGER_FAVRO_ORGANIZATION_ID"] = "org-id"

favro.check(key: "Test")</pre>
</blockquote>


#### Methods

`check` - Check for cards.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
