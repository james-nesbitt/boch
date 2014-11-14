#!/bin/sh
[ ! -f "~/.platform" ] && touch ~/.platform
docker run --rm -ti -v ~/.platform:/home/platform/.platform -v `pwd`:/home/platform/app platformsh
