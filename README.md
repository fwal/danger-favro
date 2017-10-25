# danger-favro
[![Build Status](https://img.shields.io/travis/fwal/danger-favro.svg)](https://travis-ci.org/fwal/danger-favro)
[![Coveralls](https://img.shields.io/coveralls/fwal/danger-favro.svg)](https://coveralls.io/github/fwal/danger-favro)

A [Danger](http://danger.systems) plugin that detect [Favro](https://favro.com) tickets referenced in code or PR title and displays basic information about them.

## Installation

    $ gem install danger-favro

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `favro` namespace.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
