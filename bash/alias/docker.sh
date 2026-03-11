# Remove dangling (“<none>” repo AND tag) images
docker_prune_none() {
  # Collect dangling image IDs
  local imgs
  imgs=$(docker images --filter "dangling=true" -q)

  if [[ -n $imgs ]]; then
    # --force here is optional; omit if you prefer confirmation
    echo "Removing $(echo "$imgs" | wc -l) dangling image(s)…"
    docker rmi --force $imgs
  else
    echo "No dangling images found — nothing to do."
  fi
}


docker_image_id() {
  # Optional initial query (e.g. "nginx:la" to match "nginx:latest")
  local query="${1:-}"

  # List images as "repo:tag<TAB>imageID", fuzzy-filter with fzf,
  # then strip off everything up to the TAB to leave just the ID.
  docker images --format '{{.Repository}}:{{.Tag}}\t{{.ID}}' \
    | fzf --ansi --no-sort --query="$query" \
    | awk -F'\t' '{print $2}'
}

docker_container_id() {
  # Optional initial query (e.g. "nginx:la" to match "nginx:latest")
  local query="${1:-}"

  # List images as "repo:tag<TAB>imageID", fuzzy-filter with fzf,
  # then strip off everything up to the TAB to leave just the ID.
  docker container list --format '{{.Image}}:{{.Names}}\t{{.ID}}' \
    | fzf --ansi --no-sort --query="$query" \
    | awk -F'\t' '{print $2}'
}

docker_volume_name() {
  # Optional initial query (e.g. "nginx:la" to match "nginx:latest")
  local query="${1:-}"

  # List images as "repo:tag<TAB>imageID", fuzzy-filter with fzf,
  # then strip off everything up to the TAB to leave just the ID.
  docker volume list --format '{{.Name}}' \
    | fzf --ansi --no-sort --query="$query"
}

alias co='docker compose'
alias cou='docker compose up'
alias coud='docker compose up -d'
alias cod='docker compose down'
alias db='docker build'
alias dc='docker compose'
alias di='docker image'
alias dv='docker volume'
alias de='docker exec'
alias dr='docker run'
alias dl='docker logs'

alias dcl='docker container list'
alias dil='docker image list'
alias dvl='docker volume list'
alias dirm='docker rm -vf'
alias dirma='docker rm -vf $(docker ps -aq)'
alias dpl='docker pull'
alias dps='docker ps'
alias drit='docker run -it'
alias drm='docker run --rm'
alias drmit='docker run --rm -it'
alias dif='docker_image_id'
alias dcf='docker_container_id'
alias dvf='docker_volume_name'

alias docd='docker run --rm -it --gpus all -v $PWD:/live -v $MODELS:/root/.cache $(dif)'

# docker enter
alias deit="docker exec -it"
alias deitb='docker exec -it $(dcf) bash'
# alias dent=''

alias lzd='lazydocker'


docker_cleanup() {
  # Stop all running containers
  docker stop $(docker ps -q) 2>/dev/null

  # Remove all containers (including stopped ones)
  docker rm $(docker ps -a -q) 2>/dev/null
}


alias ddc='docker container rm -f $(dcf)'
alias ddi='docker image rm -f $(dif)'
alias dlf='docker logs $(dcf)'

if cmd_exists nvidia-smi; then
  alias drbash='docker run --gpus all -it $(dif) bash'
else
  alias drbash='docker run -it $(dif) bash'
fi

alias debash='docker exec -it $(dcf) bash'
