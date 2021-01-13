#!/usr/bin/env bash
service docker start
git config --global user.email "buildagent@teamcity"
git config --global user.name "TC BuildAgent"
exec $@
