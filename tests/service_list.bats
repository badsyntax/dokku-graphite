#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:list) with no exposed ports, no linked apps" {
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l     dokku/docker-grafana-graphite:6.4.4  running  -              -"
}

@test "($PLUGIN_COMMAND_PREFIX:list) with exposed ports" {
  dokku "$PLUGIN_COMMAND_PREFIX:expose" l 4242 4243 4244 4245
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l     dokku/docker-grafana-graphite:6.4.4  running  8125->4242 8126->4243 80->4244 2003->4245   -"
}

@test "($PLUGIN_COMMAND_PREFIX:list) with linked app" {
  dokku apps:create my_app
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l     dokku/docker-grafana-graphite:6.4.4  running  -              my_app"
  dokku --force apps:destroy my_app
}

@test "($PLUGIN_COMMAND_PREFIX:list) when there are no services" {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "There are no Graphite services"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}
