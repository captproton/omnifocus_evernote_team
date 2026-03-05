#!/bin/bash
. "$HOME/.asdf/asdf.sh"
cd "$(dirname "$0")/.."  # Move to project root directory
bundle exec ruby bin/project_action.rb generate "$1"