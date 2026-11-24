# ~/dotfiles/nushell/env.nu  (symlinked from ~/.config/nushell/env.nu)
#
# Bash is the source of truth for the environment. Rather than re-implement
# ~/.bashrc.d (PATH, cargo, nvm, CUDA, secrets, AGENT_PERSONA from the tmux
# session, theme vars, ...), ask an interactive bash what it ends up exporting
# and load that. A new export in bash shows up here with no nu edit.

$env.__NU_T0 = (date now | into int)   # ns; for config.nu's "loaded in" line

const MIRROR = '~/dotfiles/nushell/bash-mirror.py'

# Exports that belong to the shell instance, not the environment.
let skip = [PWD OLDPWD SHLVL _ PATH TERM_PROGRAM STARSHIP_SHELL STARSHIP_SESSION_KEY
            FILE_PWD CURRENT_FILE PROCESS_PATH LAST_EXIT_CODE CMD_DURATION_MS
            config ENV_CONVERSIONS NU_LIB_DIRS NU_PLUGIN_DIRS NU_VERSION]

# fd 3 carries the JSON; the rc chain's own stdout ("Bashrc loaded in ..") is dropped.
let bash_env = try {
    ^bash -c 'bash -ic "exec jq -n env >&3" 3>&1 >/dev/null 2>/dev/null </dev/null'
    | from json
} catch { {} }

if ($bash_env | is-not-empty) {
    $bash_env
    | transpose key value
    | where {|r| not ($r.key in $skip) and not ($r.key | str starts-with 'BASH_FUNC_') }
    | transpose -rd
    | load-env
    $env.PATH = ($bash_env.PATH | split row (char esep) | uniq)
}

# Keep the generated alias/function mirror in step with bash. Autoload files
# are parsed after config.nu, so regenerating here takes effect this session.
# Content hash, not mtime: generate-agent-aliases rewrites its .gen.sh on every
# interactive bash start (including the import above), unchanged or not.
let mirror_nu = ($nu.default-config-dir | path join autoload bash-mirror.nu)
let mirror_hash = ($nu.data-dir | path join bash-mirror sources.sha256)
let bash_hash = (
    [~/.bashrc ~/.bash_profile]
    | append (glob ~/dotfiles/bash/**/*.sh)
    | append (glob ~/dotfiles/private/bash/**/*.sh)
    | path expand | uniq | sort
    | where {|p| $p | path exists }
    | each {|p| open --raw $p }
    | str join | hash sha256
)
if not ($mirror_nu | path exists) or (try { open $mirror_hash | str trim } catch { '' }) != $bash_hash {
    ^/usr/bin/python3 ($MIRROR | path expand) --quiet
    $bash_hash | save -f $mirror_hash
}

# Prompt + jumping: same tools bash uses (55-prompt.sh, 97-zox-init.sh), via
# their native nushell integrations. Re-generated if the init file is missing.
let vendor = ($nu.data-dir | path join vendor autoload)
mkdir $vendor
if (which starship | is-not-empty) and not ($vendor | path join starship.nu | path exists) {
    ^starship init nu | save -f ($vendor | path join starship.nu)
}
if (which zoxide | is-not-empty) and not ($vendor | path join zoxide.nu | path exists) {
    ^zoxide init nushell | save -f ($vendor | path join zoxide.nu)
}
