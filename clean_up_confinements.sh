#! /bin/bash

clean_up_confinements() {
  docker rm -f $(docker ps -a -q --filter "ancestor=ai_sandbox")
}
