-- Compatibility shim: nvim-treesitter (archived master) on Neovim 0.11+/0.12.
--
-- Neovim 0.10 changed query `match` tables so each capture id maps to a LIST of
-- nodes (TSNode[]) instead of a single TSNode. Handlers opted out of the new
-- shape with `{ all = false }`, which delivered just the last node. Neovim 0.12
-- removed the `all` option entirely (it is now ignored by add_predicate /
-- add_directive), but nvim-treesitter's master branch -- archived at cf12346a
-- and never updated -- still registers handlers that index `match[id]` as a
-- single node. The result is:
--
--   .../vim/treesitter.lua: attempt to call method 'range' (a nil value)
--
-- whenever one of those handlers runs (e.g. the markdown code-block injection
-- directive `set-lang-from-info-string!`), because `match[id]` is a list table,
-- which is truthy (so the `if not node` guards pass) but has no `:range()`.
--
-- We restore the old `all = false` behavior by wrapping the affected handlers so
-- they again receive a single node. Scoped to the known legacy names from
-- query_predicates.lua, so handlers written for the new list API are untouched.
-- Must run before nvim-treesitter registers its handlers, so init.lua requires
-- this before lazy loads plugins.

local query = require "vim.treesitter.query"

-- Handlers in nvim-treesitter's frozen master that expect single-node matches.
local legacy = {
  ["nth?"] = true,
  ["is?"] = true,
  ["kind-eq?"] = true,
  ["set-lang-from-mimetype!"] = true,
  ["set-lang-from-info-string!"] = true,
  ["downcase!"] = true,
}

-- Collapse each capture's node list to its last node (old `all = false`).
local function collapse(match)
  local single = {}
  for id, nodes in pairs(match) do
    single[id] = type(nodes) == "table" and nodes[#nodes] or nodes
  end
  return single
end

local function wrap(register)
  return function(name, handler, opts)
    if legacy[name] and type(handler) == "function" then
      local inner = handler
      handler = function(match, ...)
        return inner(collapse(match), ...)
      end
    end
    return register(name, handler, opts)
  end
end

-- Idempotent: re-sourcing init.lua must not double-wrap the registrars.
if not query.__ts_compat_patched then
  query.add_predicate = wrap(query.add_predicate)
  query.add_directive = wrap(query.add_directive)
  query.__ts_compat_patched = true
end
