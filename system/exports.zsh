# export DOCKER_BUILDKIT=1
# export COMPOSE_DOCKER_CLI_BUILD=1

# Claude Code only emits OSC 8 links for terminals it knows; herdr isn't one (herdrdev/herdr#4748)
[ "$TERM_PROGRAM" = herdr ] && export FORCE_HYPERLINK=1
