create_alias() {
  # envvars: create_alias foo 'echo "$HOME or $TERM"'
  # piping: 
  if [[ $# -lt 2 ]]; then
    echo "Usage: create_alias <name> <command>"
    return 1
  fi
  local file=$1
  local alias_dir="$DOTFILES_PRIVATE/bash/alias"
  local alias_path="$DOTFILES_PRIVATE/bash/alias/$file.sh"

  if [[ -f "$alias_path" ]]; then
    shift
  else
    alias_path="$alias_dir/$(/usr/bin/ls $alias_dir | fzf)"
  fi
  local name=$1
  shift
  local cmd=$@

  echo "alias $name='$cmd'" >> "$alias_path"
  git -C "${DOTFILES_PRIVATE}/" add "$alias_path"
  git -C "${DOTFILES_PRIVATE}/" commit -m "Add alias $name"
  git -C "${DOTFILES_PRIVATE}/" push --set-upstream origin @
  r
}


create_var() {
  # envvars: create_alias foo 'echo "$HOME or $TERM"'
  # piping: 
  if [[ $# -lt 2 ]]; then
    echo "Usage: create_var <name> <command>"
    return 1
  fi
  local file=$1
  local alias_dir="$DOTFILES/bash/vars"
  local alias_path="$DOTFILES/bash/vars/$file.sh"

  if [[ -f "$alias_path" ]]; then
    shift
  else
    alias_path="$alias_dir/$(ls $alias_dir | fzf)"
  fi
  local name=$1
  shift
  local cmd=$@

  echo "export ${name^^}='$cmd'" >> "$alias_path"
  git -C "${DOTFILES}/" add "$alias_path"
  git -C "${DOTFILES}/" commit -m "Add var $name"
  git -C "${DOTFILES}/" push --set-upstream origin @
  r
}

# Git functions for convenience
git_add_commit_push() {
  local msg="$*"
  git add .
  git commit -m "$msg"
  git push --set-upstream origin @
}

git_add_commit_push_all() {
  local msg="$*"
  git add -A
  git commit -m "$msg"
  git push --set-upstream origin @
}

git_commit_local() {
  local msg="$*"
  git commit -m "$msg"
}

git_commit_push() {
  local msg="$*"
  git commit -m "$msg"
  git push
}

git_add_files() {
  local files="$*"
  git add $files
  git status -s
}

ffmpeg_convert_file() {
    # Check if correct number of arguments provided
    if [ $# -ne 2 ]; then
        echo "Usage: ffmpeg_convert_file <input_file> <output_format>"
        echo "Example: ffmpeg_convert_file video.avi mp4"
        return 1
    fi
    
    local input_file="$1"
    local output_format="$2"
    
    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' not found"
        return 1
    fi
    
    # Check if ffmpeg is installed
    if ! command -v ffmpeg &> /dev/null; then
        echo "Error: ffmpeg is not installed or not in PATH"
        return 1
    fi
    
    # Extract filename without extension
    local filename=$(basename "$input_file")
    local name_without_ext="${filename%.*}"
    
    # Create output filename
    local output_file="${name_without_ext}.${output_format}"
    
    # Check if output file already exists
    if [ -f "$output_file" ]; then
        echo "Warning: Output file '$output_file' already exists"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Conversion cancelled"
            return 0
        fi
    fi
    
    echo "Converting '$input_file' to '$output_file'..."
    
    # Run ffmpeg conversion
    ffmpeg -i "$input_file" "$output_file"
    
    # Check if conversion was successful
    if [ $? -eq 0 ]; then
        echo "Conversion completed successfully: $output_file"
    else
        echo "Error: Conversion failed"
        return 1
    fi
}

cancel_queued_runs() {
  for run_id in $(gh run list --status queued --json databaseId -q '.[].databaseId'); do
    gh run cancel "$run_id"
  done
}

# quietly run any command in the background, without output or job notifications
quiet_background_run() {
  # run the command, redirect stdout+stderr to /dev/null, background it, then disown
  [[ -n "$@" ]] && $("$@" &>/dev/null & disown)
}

fully_detach_run() {
  [[ $# -gt 0 ]] || return 1
  setsid nohup "$@" </dev/null &>/dev/null &
}

find_and_set_omp_conf() {
  local cfg
  cfg=$(fd -H --type f --extension omp.json --base-directory "$HOME" 2>/dev/null | fzf) || return

  # reload Oh My Posh with the chosen config
  eval $(oh-my-posh init bash --config "$cfg")
}


# fuzzy‑checkout: list all git branches via fzf and checkout the selection
git_checkout_fzf() {
  # gather all branches (local + remote), strip “origin/” prefix, dedupe & sort
  local branches branch
  branches=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
             | sed 's#^origin/##' \
             | sort -u)
  # launch fzf; if user selects something, git checkout it
  branch=$(printf '%s\n' "$branches" | fzf --height 40% --reverse --border) \
    && git checkout "$branch"
}

matches_any() {
    local target="$1"
    shift
    printf '%s\n' "$@" | grep -Fxq "$target"
}

slink() {
    local target="$1"
    local link_name="$2"

    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$link_name")"

    # Create the symlink
    ln -sfn "$target" "$link_name"
}

copy_root () {
    local source="$1"
    local dest="$2"
    sudo mkdir -p "$dest"
    sudo cp "$source" "$dest"
    sudo chown root:root "$dest"
    sudo chmod 644 "$dest"
}

search_func() {
  # optional initial query string
  local query="${1:-}"

  # list all function names, fuzzy-filter with fzf, then declare -f to dump the body
  local fn
  fn=$(declare -F | awk '{print $3}' \
       | fzf --ansi --no-sort --query="$query" --prompt="Function> ") \
       || return 1

  # echo the complete function definition
  declare -f "$fn"
}

list_abs() {
    local dir="$1"
    if [ -z "$dir" ]; then
        echo "Usage: list_abs <directory>"
        return 1
    fi
    if [ ! -d "$dir" ]; then
        echo "Error: '$dir' is not a directory"
        return 1
    fi
    find "$(realpath "$dir")" -maxdepth 1
}

maxfile() {
    local files=("$@")
    [[ ${#files[@]} -eq 0 ]] && files=(*)
    
    # Group files by their base name (everything except the number)
    declare -A groups
    for file in "${files[@]}"; do
        [[ -f "$file" ]] || continue
        base=$(echo "$file" | sed 's/[0-9]\+\([^0-9]*\)$/\1/')
        groups["$base"]+="$file "
    done
    
    # If only one group, return the file with highest number
    if [[ ${#groups[@]} -eq 1 ]]; then
        for group in "${groups[@]}"; do
            echo "$group" | tr ' ' '\n' | grep -v '^$' | sort -V | tail -1
        done
    else
        # Multiple groups: use fzf to select base, then return highest numbered file
        selected_base=$(printf '%s\n' "${!groups[@]}" | fzf --prompt="Select file pattern: ")
        [[ -n "$selected_base" ]] && echo "${groups[$selected_base]}" | tr ' ' '\n' | grep -v '^$' | sort -V | tail -1
    fi
}

# quick_replace "pattern" "replacement" "input_file" ["output_file"]
# - Replaces all occurrences of pattern with replacement in the file contents.
# - If output_file is omitted:
#     * and the pattern appears in the *filename*, it writes to a new file whose
#       name is the filename with pattern→replacement applied.
#     * otherwise, edits the file in place (atomically via a temp file).
# - The pattern and replacement are treated as *literal strings* (not regex).
quick_replace() {
  local pat="$1" rep="$2" infile="$3" outfile="$4"

  if [[ -z "$pat" || -z "$rep" || -z "$infile" ]]; then
    echo "Usage: quick_replace PATTERN REPLACEMENT INPUT_FILE [OUTPUT_FILE]" >&2
    return 2
  fi
  if [[ ! -f "$infile" ]]; then
    echo "quick_replace: input file not found: $infile" >&2
    return 2
  fi

  # If no explicit outfile and the *basename* contains the pattern, derive one.
  if [[ -z "$outfile" ]]; then
    local dir base
    dir=$(dirname -- "$infile")
    base=$(basename -- "$infile")
    if [[ "$base" == *"$pat"* ]]; then
      # Bash string replace is literal (no regex)
      local newbase=${base//"$pat"/"$rep"}
      outfile="$dir/$newbase"
    fi
  fi

  # One-liner to do a literal (non-regex) replace safely, handling any chars.
  # Uses Perl for portability; quotes/escapes are managed here.
  _qr_do() {
    QRPAT="$pat" QRREP="$rep" perl -0777 -pe '
      our $p  = $ENV{QRPAT};
      our $r  = $ENV{QRREP};
      $p = quotemeta($p);         # treat pattern literally
      $r =~ s/\\/\\\\/g;          # escape backslashes in replacement
      $r =~ s/\$/\\\$/g;          # escape $ to avoid backref expansion
      s/$p/$r/g;
    ' -- "$1"
  }

  if [[ -n "$outfile" && "$outfile" != "$infile" ]]; then
    # Write to the specified/derived output file
    mkdir -p -- "$(dirname -- "$outfile")" 2>/dev/null
    if ! _qr_do "$infile" > "$outfile".tmp; then
      echo "quick_replace: failed to write output." >&2
      rm -f -- "$outfile".tmp
      return 1
    fi
    mv -f -- "$outfile".tmp "$outfile"
    echo "Wrote: $outfile"
  else
    # In-place edit (atomic replace in the same directory)
    local tmp
    tmp="$(mktemp "${infile}.XXXXXX")" || { echo "quick_replace: mktemp failed." >&2; return 1; }
    if ! _qr_do "$infile" > "$tmp"; then
      echo "quick_replace: replacement failed." >&2
      rm -f -- "$tmp"
      return 1
    fi
    mv -f -- "$tmp" "$infile"
    echo "Updated in place: $infile"
  fi
}


dl_gitignore() {
  # Download a gitignore template using fzf to select the language
  # Usage: dl_gitignore [output_file]
  # If no output_file is specified, defaults to .gitignore in current directory

  local output_file="${1:-.gitignore}"

  # Check for required tools
  if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is not installed" >&2
    return 1
  fi

  if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed" >&2
    return 1
  fi

  # Fetch template list and let user select with fzf
  local template
  template=$(curl -s https://api.github.com/gitignore/templates | jq -r '.[]' | fzf --prompt="Select gitignore template: ")

  if [[ -z "$template" ]]; then
    echo "No template selected"
    return 1
  fi

  # Download the selected template
  echo "Downloading $template.gitignore..."
  if curl -o "$output_file" "https://raw.githubusercontent.com/github/gitignore/main/${template}.gitignore" 2>/dev/null; then
    echo "Successfully downloaded to $output_file"
  else
    echo "Error: Failed to download template" >&2
    return 1
  fi
}

binadd() {
  local binary="$(realpath $1)"
  ln -s "$binary" "/home/me/.local/bin/"
  echo "Linked $1 to /home/me/.local/bin/"
}
