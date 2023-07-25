#!/bin/bash

export PATH=/var/deploy/data/.rbenv/shims:/var/deploy/data/.rbenv/bin:$PATH
bundle exec ruby "$@"
