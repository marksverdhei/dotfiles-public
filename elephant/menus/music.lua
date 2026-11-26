-- music.lua — elephant/walker menu behind SUPER+M: search and play music.
-- Sources: the bg-*.desktop background-video entries (bg-yt; NoDisplay so
-- they stay out of the app launcher) and audio files under ~/Music.
-- Playback goes through ~/dotfiles/bin/music-play: one audio-only track at a time.
--
-- Install: ln -s ~/dotfiles/elephant/menus/music.lua ~/.config/elephant/menus/
-- Open:    omarchy-launch-walker -m menus:music
Name = "music"
NamePretty = "Music"
Cache = false
HideFromProviderlist = true
SearchName = true

local HOME = os.getenv("HOME")
local PLAY = HOME .. "/dotfiles/bin/music-play"

local function ShellEscape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function DesktopField(path, key)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local value
  for line in f:lines() do
    value = line:match("^" .. key .. "=(.*)$")
    if value then
      break
    end
  end
  f:close()
  return value
end

-- Titles like "𝙰𝚛𝚎 𝚆𝚎 𝙲𝚘𝚘𝚔𝚎𝚍?" use Unicode math letters that plain typing never
-- matches; NFKC folds them to ASCII so the folded form can go in Keywords.
local function Fold(s)
  if not s:find("[\128-\255]") then
    return nil
  end
  local handle = io.popen(
    "/usr/bin/python3 -c 'import sys,unicodedata;print(unicodedata.normalize(\"NFKC\",sys.argv[1]))' "
      .. ShellEscape(s)
  )
  if not handle then
    return nil
  end
  local folded = handle:read("*l")
  handle:close()
  if folded and folded ~= s then
    return folded
  end
end

function GetEntries()
  local entries = {
    {
      Text = "Stop music",
      Subtext = "Stop playback and background video",
      Value = "stop",
      Icon = "media-playback-stop",
      Actions = { activate = PLAY .. " stop" },
    },
  }

  local apps = HOME .. "/.local/share/applications"
  local handle = io.popen("find " .. ShellEscape(apps) .. " -maxdepth 1 -name 'bg-*.desktop' 2>/dev/null | sort")
  if handle then
    for path in handle:lines() do
      local id = path:match("([^/]+)$")
      local name = (DesktopField(path, "Name") or id):gsub("^BG ", "")
      local icon = DesktopField(path, "Icon")
      table.insert(entries, {
        Text = name,
        Subtext = "Background video (plays as audio)",
        Value = id,
        Icon = icon,
        Preview = icon,
        PreviewType = "file",
        Keywords = { "bg", "video", "background", Fold(name) },
        Actions = { activate = PLAY .. " desktop " .. ShellEscape(id) },
      })
    end
    handle:close()
  end

  local music = HOME .. "/Music"
  handle = io.popen(
    "find -L " .. ShellEscape(music) .. " -type f \\( -iname '*.mp3' -o -iname '*.flac' -o -iname '*.ogg'"
      .. " -o -iname '*.opus' -o -iname '*.m4a' -o -iname '*.wav' \\) -printf '%P\\n' 2>/dev/null | sort"
  )
  if handle then
    for rel in handle:lines() do
      local dir, file = rel:match("^(.*)/([^/]+)$")
      file = file or rel
      table.insert(entries, {
        Text = file:gsub("%.[^%.]+$", ""),
        Subtext = dir and ("~/Music/" .. dir) or "~/Music",
        Value = rel,
        Icon = "audio-x-generic",
        Keywords = { dir or "", Fold(rel) },
        Actions = { activate = PLAY .. " " .. ShellEscape(music .. "/" .. rel) },
      })
    end
    handle:close()
  end

  return entries
end
