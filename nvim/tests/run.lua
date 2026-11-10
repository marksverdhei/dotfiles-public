-- Unit tests for the pure helpers in lua/features and lua/theme.
-- Run from anywhere:  nvim -l nvim/tests/run.lua
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.normalize(debug.getinfo(1, "S").source:sub(2))))
-- Don't pick up the installed config (~/.config/nvim) instead of this checkout.
vim.o.runtimepath = vim.env.VIMRUNTIME
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path

local failures, count = 0, 0

local function test(name, fn)
  count = count + 1
  local ok, err = pcall(fn)
  if not ok then
    failures = failures + 1
    print(("FAIL %s\n  %s"):format(name, err))
  end
end

local function eq(actual, expected)
  if not vim.deep_equal(actual, expected) then
    error(("expected %s, got %s"):format(vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

-- openers ------------------------------------------------------------------
local openers = require "features.openers"

test("extract_url: plain", function()
  eq(openers.extract_url "see https://example.com/a?b=1#c here", "https://example.com/a?b=1#c")
end)
test("extract_url: markdown link and trailing punctuation", function()
  eq(openers.extract_url "[docs](https://e.com/a_(b)/c?q=1#x).", "https://e.com/a_(b)/c?q=1#x")
end)
test("extract_url: none", function()
  eq(openers.extract_url "no url here", nil)
end)
test("extract_hf_id: repo id", function()
  eq(openers.extract_hf_id "model Qwen/Qwen2.5-7B-Instruct here", "Qwen/Qwen2.5-7B-Instruct")
  eq(openers.extract_hf_id '"meta-llama/Llama-3.1-8B",', "meta-llama/Llama-3.1-8B")
end)
test("extract_hf_id: ignores paths and urls", function()
  eq(openers.extract_hf_id "edit lua/mappings.lua now", nil)
  eq(openers.extract_hf_id "./foo/bar", nil)
  eq(openers.extract_hf_id "a/b/c", nil)
  eq(openers.extract_hf_id "https://hf.co/x/y", nil)
  eq(openers.extract_hf_id "../x", nil)
end)

-- markdown -----------------------------------------------------------------
local markdown = require "features.markdown"

test("toggle_line", function()
  eq(markdown.toggle_line "- [ ] a [ ] b", "- [x] a [ ] b")
  eq(markdown.toggle_line "- [X] a", "- [ ] a")
  eq(markdown.toggle_line "plain", nil)
end)
test("sort_block: unchecked first, stable, bounded by non-checkbox lines", function()
  local lines = { "# todo", "- [x] a", "- [ ] b", "- [x] c", "- [ ] d", "", "- [ ] e" }
  local s, e, sorted = markdown.sort_block(lines, 3)
  eq({ s, e }, { 2, 5 })
  eq(sorted, { "- [ ] b", "- [ ] d", "- [x] a", "- [x] c" })
end)

-- shell --------------------------------------------------------------------
local shell = require "features.shell"

test("segment_bounds", function()
  local lines = { "echo hi", "cmd \\", "  --a 1 \\", "  --b", "echo bye" }
  eq({ shell.segment_bounds(lines, 3) }, { 2, 4 })
  eq({ shell.segment_bounds(lines, 1) }, { 1, 1 })
end)
test("toggle_segment: expand and collapse round-trip", function()
  local expanded = shell.toggle_segment { "sbatch --time 1:00 -N 2 job.sh" }
  eq(expanded, { "sbatch \\", "  --time 1:00 \\", "  -N 2 job.sh" })
  eq(shell.toggle_segment(expanded), { "sbatch --time 1:00 -N 2 job.sh" })
end)

-- ansi ---------------------------------------------------------------------
local ansi = require "features.ansi"

test("ansi.parse: strips codes, spans in byte columns, utf-8 safe", function()
  local lines, spans = ansi.parse { "\27[38;2;255;0;0mR\27[0mx\27[38;2;0;255;0m█\27[0m" }
  eq(lines, { "Rx█" })
  eq(spans, { { 0, 0, 1, "#ff0000" }, { 0, 2, 5, "#00ff00" } })
end)

-- theme.mid ----------------------------------------------------------------
local mid = require "theme.mid"

test("blend", function()
  eq(mid._blend("#000000", "#ffffff", 0.5), "#808080")
  eq(mid._blend("#102030", "#102030", 0.3), "#102030")
  eq(mid._blend("#000000", nil, 0.5), "#000000")
end)
test("contrast: WCAG reference values", function()
  eq(math.floor(mid._contrast("#000000", "#ffffff") * 10 + 0.5) / 10, 21)
  eq(mid._contrast("#777777", "#777777"), 1)
end)
test("for_theme: resolves any family member to its mid theme", function()
  eq(mid.for_theme "github_dark", "github_mid")
  eq(mid.for_theme "rosepine-dawn", "rosepine-mid")
  eq(mid.for_theme "nope", nil)
end)

-- configs.lock_guard -------------------------------------------------------
local lock_guard = require "configs.lock_guard"

test("lock_guard: restores a lockfile rewritten after the snapshot", function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ '{ "a": "pinned" }' }, path)
  local snap = lock_guard.snapshot(path)
  vim.fn.writefile({ '{ "a": "stale" }' }, path)
  eq(lock_guard.restore_if_changed(snap), true)
  eq(vim.fn.readfile(path), { '{ "a": "pinned" }' })
  os.remove(path)
end)
test("lock_guard: leaves an unchanged or missing lockfile alone", function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "same" }, path)
  eq(lock_guard.restore_if_changed(lock_guard.snapshot(path)), false)
  os.remove(path)
  eq(lock_guard.restore_if_changed(lock_guard.snapshot(path)), false)
  eq(vim.uv.fs_stat(path), nil)
end)

print(("%d tests, %d failed"):format(count, failures))
os.exit(failures == 0 and 0 or 1)
