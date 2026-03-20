
. "$DOTFILES/bootstrap/tools.bash"

if [[ -L "$HOME/.bashrc.d" ]]; then
  unlink "$HOME/.bashrc.d"
fi

ln -s "$DOTFILES/bash/" "$HOME/.bashrc.d"

inject_bashrc
inject_zshrc

source "$HOME/.bashrc"
touch "$HOME/.cache/hf.env"

cp "$DOTFILES/nvim/lua/_chadrc.lua" "$DOTFILES/nvim/lua/chadrc.lua"
cp "$DOTFILES/ghostty/default.config" "$DOTFILES/ghostty/config"

# Generate and link OMP config for current hostname
omp_config="$DOTFILES/omp/${HOSTNAME}.omp.json"
if [[ ! -f "$omp_config" ]]; then
  echo "Generating OMP configs..."
  "$DOTFILES/omp/generate.py"
fi
if [[ -f "$omp_config" ]]; then
  slink "$omp_config" "$HOME/.config/omp.json"
else
  echo "Warning: No OMP config for hostname '$HOSTNAME'"
fi
