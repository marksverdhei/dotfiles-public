alias cy='claude --dangerously-skip-permissions'
alias cry='claude --resume --dangerously-skip-permissions'

alias ch='aichat'
alias cl='claude'
alias clr='claude --resume'
alias lcc='claude-local'
alias clc='claude --continue'

# Codex with fzf profile picker + full-auto
cx() {
  local profile
  profile=$(awk '/^\[profiles\./ { gsub(/\[profiles\.|]/, ""); print }' ~/.codex/config.toml | fzf --prompt="codex profile> ") || return
  codex --profile "$profile" --full-auto "$@"
}
