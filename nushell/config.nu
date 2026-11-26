# ~/dotfiles/nushell/config.nu  (symlinked from ~/.config/nushell/config.nu)
#
# Mirrors ~/.bashrc.d. Most of it is generated, not written here:
#   env         env.nu imports what interactive bash exports
#   aliases     autoload/bash-mirror.nu, from bash-mirror.py (all ~420 aliases
#   functions   and the bash functions; regenerated when bash rc files change)
# This file holds only what must be native: things that change nu's own cwd
# or env, which a bash subprocess cannot do. Names defined here take
# precedence over the generated mirror.

$env.config.show_banner = false
$env.config.edit_mode = 'emacs'            # bash/readline default
$env.config.history.max_size = 100_000
$env.config.history.file_format = 'sqlite'
$env.config.completions.algorithm = 'fuzzy'
$env.config.buffer_editor = 'nvim'

# --- shell lifecycle (alias/alphabet.sh) -------------------------------------
alias r = exec nu                          # bash: exec bash
alias c = clear
def --env h [] { cd ~ }
def --env home [] { cd ~ }
# Nu-native listings for the ls aliases: you get tables, not text.
alias l = ls
alias la = ls -a

# Regenerate the alias/function mirror now (normally automatic on change).
def bash-mirror [] { ^/usr/bin/python3 ~/dotfiles/nushell/bash-mirror.py; print "restart with r to load" }

# --- python venvs (alias/python.sh) ------------------------------------------
# bash `source .venv/bin/activate`; overlays can't take a runtime path, so
# activate by hand. Starship reads VIRTUAL_ENV just the same.
def --env venv-activate [dir: path] {
    let dir = ($dir | path expand)
    if not ($dir | path join bin python | path exists) { error make {msg: $"no venv at ($dir)"} }
    if 'VIRTUAL_ENV' in $env { deactivate }
    $env.VIRTUAL_ENV = $dir
    $env.PATH = ($env.PATH | prepend ($dir | path join bin))
    hide-env -i PYTHONHOME
}
def --env deactivate [] {
    if 'VIRTUAL_ENV' not-in $env { return }
    let bin = ($env.VIRTUAL_ENV | path join bin)
    $env.PATH = ($env.PATH | where $it != $bin)
    hide-env VIRTUAL_ENV
}
def --env vv [] { venv-activate .venv }
def --env gv [] { venv-activate ~/.venv }
def --env vg [] { venv-activate ~/.venv }

# --- fzf keys (60-fzf.sh: key-bindings.bash) ---------------------------------
$env.config.keybindings ++= [
    {   # Ctrl-R: fuzzy history, like fzf's bash binding
        name: fzf_history, modifier: control, keycode: char_r, mode: [emacs vi_insert vi_normal]
        event: { send: executehostcommand, cmd: "commandline edit --replace (
            history | get command | reverse | uniq | str join (char nl)
            | fzf --scheme=history --height=40% --reverse --query (commandline)
            | str trim)" }
    }
    {   # Ctrl-T: insert a fuzzy-picked path at the cursor
        name: fzf_file, modifier: control, keycode: char_t, mode: [emacs vi_insert vi_normal]
        event: { send: executehostcommand, cmd: "commandline edit --insert (fzf --height=40% --reverse | str trim)" }
    }
    {   # Alt-C: fuzzy cd into a subdirectory
        name: fzf_cd, modifier: alt, keycode: char_c, mode: [emacs vi_insert vi_normal]
        event: { send: executehostcommand, cmd: "cd (fd --type d | fzf --height=40% --reverse | str trim | if ($in | is-empty) { '.' } else { $in })" }
    }
]

# bash: "Bashrc loaded in Nms" (99-post.sh). Measured at the first prompt so it
# includes the autoloaded mirror, then the hook disarms itself.
$env.config.hooks.pre_prompt ++= [{||
    if '__NU_T0' in $env {
        print $"Nushell loaded in (((date now | into int) - ($env.__NU_T0 | into int)) / 1_000_000 | math round)ms"
        hide-env __NU_T0
    }
}]
