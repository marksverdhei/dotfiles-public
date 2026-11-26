mp4_to_mp3() {
  ffmpeg -i $1 $(echo $1 | sed s/\.mp4/.mp3/g)
}

mp4_rev() {
  if [[ -z $1 ]]; then
    printf "Usage: reverse_mp4 <video.mp4>\n" >&2
    return 1
  fi

  local in="$1"
  [[ ! -f $in ]] && { printf "File not found: %s\n" "$in" >&2; return 1; }

  local out="${in%.*}_reversed.mp4"

  ffmpeg -y -i "$in" \
         -vf reverse \
         -af areverse \
         "$out"
}

mp4_cut() {
  if [[ $# -ne 2 ]]; then
    printf "Usage: cut_mp4 <video.mp4> <ss | mm:ss | hh:mm:ss>\n" >&2
    return 1
  fi

  local in="$1"
  local mark="$2"

  [[ ! -f $in ]] && { printf "File not found: %s\n" "$in" >&2; return 1; }

  if [[ ! $mark =~ ^[0-9]+$ && ! $mark =~ ^([0-9]{1,}:){1,2}[0-5]?[0-9]$ ]]; then
    printf "Invalid time \"%s\" – use seconds or mm:ss (or hh:mm:ss)\n" "$mark" >&2
    return 1
  fi

  local base="${in%.*}"               # strip extension
  local front="${base}_front.mp4"
  local back="${base}_${mark}_back.mp4"

  ffmpeg -y -i "$in" -t "$mark" -c copy "$front"

  ffmpeg -y -ss "$mark" -i "$in" -c copy "$back"
}

mp4_con() {
  # ---- argument checks ------------------------------------------------------
  if [[ $# -lt 2 || $# -gt 3 ]]; then
    printf "Usage: concat_mp4 file1.mp4 file2.mp4 [output.mp4]\n" >&2
    return 1
  fi

  local f1="$1"
  local f2="$2"
  local out

  [[ ! -f $f1 ]] && { printf "File not found: %s\n" "$f1" >&2; return 1; }
  [[ ! -f $f2 ]] && { printf "File not found: %s\n" "$f2" >&2; return 1; }

  # default output name
  if [[ -n $3 ]]; then
    out="$3"
  else
    out="${f1%.*}_${f2%.*}_concat.mp4"
  fi

  ffmpeg -y \
    -i "$f1" -i "$f2" \
    -filter_complex "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[v][a]" \
    -map "[v]" -map "[a]" \
    -c:v libx264 -c:a aac \
    "$out"
}


ffmerge() {
  # Losslessly join any number of videos end to end (concat demuxer, no re-encode).
  # Inputs must share codecs/resolution; use mp4_con to re-encode mismatched files.
  if [[ $# -lt 2 ]]; then
    printf "Usage: ffmerge file1 file2 [file3 ...] [-o output]\n" >&2
    return 1
  fi

  local out="" f
  local -a files=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      -o) out="$2"; shift 2 ;;
      *)  files+=("$1"); shift ;;
    esac
  done

  for f in "${files[@]}"; do
    [[ ! -f $f ]] && { printf "File not found: %s\n" "$f" >&2; return 1; }
  done

  [[ -z $out ]] && out="${files[0]%.*}_merged.${files[0]##*.}"

  local list
  list=$(mktemp --suffix=.txt) || return 1
  for f in "${files[@]}"; do
    printf "file '%s'\n" "$(realpath "$f" | sed "s/'/'\\\\''/g")" >> "$list"
  done

  ffmpeg -y -f concat -safe 0 -i "$list" -c copy "$out"
  local rc=$?
  rm -f "$list"
  return $rc
}
