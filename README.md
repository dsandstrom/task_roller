# Task Roller
###### Issue and Task Manager
[![dsandstrom](https://circleci.com/gh/dsandstrom/task_roller.svg?style=svg)](https://circleci.com/gh/dsandstrom/task_roller)

## Local Setup

### System dependencies
* Ruby
* rbenv, rvm, or similar
* PostgreSQL

### Configuration

#### Install Ruby, Rails, and gems

Clone from GitHub and `cd` into project directory

```sh
# install ruby version set in .ruby-version
rbenv install # or `rvm install`
gem install bundler
bundle install --without production
```

#### Install Frontend Dependencies
I use [Node Version Manager](https://github.com/nvm-sh/nvm) to maintain a more
consistent node version.  The version number is stored in *./.nvmrc*. Please
use that version of NodeJS or use nvm to install it.

```sh
# using nvm
# cd into project directory
nvm install
nvm use
```

Install frontend packages with yarn
```sh
yarn install
```

#### Setup secrets

```sh
bin/rails secrets:edit
```

* Copy config/secrets.yml.example and paste in open window
* Add secret key bases (Use `bin/rails secret` to generate them)
* Set db username and password to match your PostgreSQL database

### Database creation/initialization

```sh
bin/rails db:setup
```

### How to run the test suite

```sh
bin/rails rspec spec/
```

### Services (job queues, cache servers, search engines, etc.)

I use guard to automate local development
```sh
bundle exec guard -g backend # start rspec and bundler watchers
bundle exec guard -g frontend # start server (port 3000) and livereload watcher
```

### Deployment instructions

WIP
