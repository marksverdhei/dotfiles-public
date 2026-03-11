-- OpenRouter dynamic model picker for Avante
-- Fetches models from OpenRouter API and provides a filterable picker

local M = {}

local cache_file = vim.fn.stdpath("cache") .. "/openrouter_models.json"
local cache_max_age = 3600 -- 1 hour in seconds

-- Popular providers to show as filter categories
M.providers = {
  "anthropic",
  "openai",
  "google",
  "deepseek",
  "meta-llama",
  "qwen",
  "mistralai",
  "cohere",
  "perplexity",
}

-- Fetch models from OpenRouter API
local function fetch_models(callback)
  local api_key = os.getenv("OPENROUTER_API_KEY")
  local curl_cmd = {
    "curl", "-s",
    "https://openrouter.ai/api/v1/models",
    "-H", "Content-Type: application/json",
  }
  if api_key then
    table.insert(curl_cmd, "-H")
    table.insert(curl_cmd, "Authorization: Bearer " .. api_key)
  end

  vim.system(curl_cmd, { text = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify("Failed to fetch OpenRouter models", vim.log.levels.ERROR)
      end)
      return
    end

    local ok, data = pcall(vim.json.decode, result.stdout)
    if not ok or not data or not data.data then
      vim.schedule(function()
        vim.notify("Failed to parse OpenRouter models response", vim.log.levels.ERROR)
      end)
      return
    end

    -- Cache the result
    local cache_data = {
      timestamp = os.time(),
      models = data.data,
    }
    local f = io.open(cache_file, "w")
    if f then
      f:write(vim.json.encode(cache_data))
      f:close()
    end

    vim.schedule(function()
      callback(data.data)
    end)
  end)
end

-- Load models from cache or fetch fresh
function M.get_models(callback, force_refresh)
  if not force_refresh then
    local f = io.open(cache_file, "r")
    if f then
      local content = f:read("*a")
      f:close()
      local ok, cache_data = pcall(vim.json.decode, content)
      if ok and cache_data and cache_data.models then
        local age = os.time() - (cache_data.timestamp or 0)
        if age < cache_max_age then
          callback(cache_data.models)
          return
        end
      end
    end
  end
  fetch_models(callback)
end

-- Format model for display
local function format_model(model)
  local pricing = model.pricing or {}
  local prompt_cost = tonumber(pricing.prompt) or 0
  local completion_cost = tonumber(pricing.completion) or 0

  -- Cost per 1M tokens
  local input_cost = prompt_cost * 1000000
  local output_cost = completion_cost * 1000000

  local cost_str
  if input_cost == 0 and output_cost == 0 then
    cost_str = "FREE"
  else
    cost_str = string.format("$%.2f/$%.2f", input_cost, output_cost)
  end

  local ctx = model.context_length or 0
  local ctx_str = ctx >= 1000 and string.format("%dk", ctx / 1000) or tostring(ctx)

  return string.format("%-50s  %8s  %s", model.id, ctx_str, cost_str)
end

-- Filter models by provider prefix
local function filter_by_provider(models, provider)
  if not provider or provider == "" or provider == "all" then
    return models
  end
  local filtered = {}
  for _, model in ipairs(models) do
    if model.id:match("^" .. provider .. "/") then
      table.insert(filtered, model)
    end
  end
  return filtered
end

-- Set the selected model in Avante
local function set_avante_model(model_id)
  local avante_ok, avante_api = pcall(require, "avante.api")
  if not avante_ok then
    vim.notify("Avante not loaded", vim.log.levels.ERROR)
    return
  end

  -- Update the openrouter provider model
  local config = require("avante.config")
  if config.options and config.options.providers and config.options.providers.openrouter then
    config.options.providers.openrouter.model = model_id
  end

  -- Also update via override if available
  local override_ok, _ = pcall(function()
    config.override({ providers = { openrouter = { model = model_id } } })
  end)

  vim.notify("Avante model set to: " .. model_id, vim.log.levels.INFO)
end

-- Show model picker using vim.ui.select with provider filter
function M.pick_model(opts)
  opts = opts or {}
  local provider_filter = opts.provider

  M.get_models(function(models)
    -- Sort by id
    table.sort(models, function(a, b)
      return a.id < b.id
    end)

    local filtered = filter_by_provider(models, provider_filter)

    if #filtered == 0 then
      vim.notify("No models found" .. (provider_filter and (" for " .. provider_filter) or ""), vim.log.levels.WARN)
      return
    end

    vim.ui.select(filtered, {
      prompt = "Select OpenRouter Model" .. (provider_filter and (" [" .. provider_filter .. "]") or "") .. ":",
      format_item = function(model)
        return format_model(model)
      end,
    }, function(choice)
      if choice then
        set_avante_model(choice.id)
      end
    end)
  end, opts.refresh)
end

-- Show provider picker first, then model picker
function M.pick_provider_then_model(opts)
  opts = opts or {}

  local choices = { "all (show all models)" }
  for _, p in ipairs(M.providers) do
    table.insert(choices, p)
  end

  vim.ui.select(choices, {
    prompt = "Filter by provider:",
  }, function(choice)
    if choice then
      local provider = choice:match("^(%S+)")
      if provider == "all" then
        provider = nil
      end
      M.pick_model({ provider = provider, refresh = opts.refresh })
    end
  end)
end

-- Telescope picker for better UX (if available)
function M.telescope_pick(opts)
  opts = opts or {}

  local telescope_ok, _ = pcall(require, "telescope")
  if not telescope_ok then
    -- Fallback to vim.ui.select
    M.pick_provider_then_model(opts)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  M.get_models(function(models)
    table.sort(models, function(a, b)
      return a.id < b.id
    end)

    pickers.new(opts, {
      prompt_title = "OpenRouter Models (type to filter)",
      finder = finders.new_table({
        results = models,
        entry_maker = function(model)
          return {
            value = model,
            display = format_model(model),
            ordinal = model.id .. " " .. (model.name or ""),
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      previewer = previewers.new_buffer_previewer({
        title = "Model Details",
        define_preview = function(self, entry)
          local model = entry.value
          local lines = {
            "ID: " .. model.id,
            "Name: " .. (model.name or "N/A"),
            "",
            "Context: " .. tostring(model.context_length or "N/A") .. " tokens",
            "",
            "Pricing (per 1M tokens):",
          }
          local pricing = model.pricing or {}
          local prompt_cost = (tonumber(pricing.prompt) or 0) * 1000000
          local completion_cost = (tonumber(pricing.completion) or 0) * 1000000
          if prompt_cost == 0 and completion_cost == 0 then
            table.insert(lines, "  FREE")
          else
            table.insert(lines, string.format("  Input:  $%.4f", prompt_cost))
            table.insert(lines, string.format("  Output: $%.4f", completion_cost))
          end
          table.insert(lines, "")
          if model.description then
            table.insert(lines, "Description:")
            for line in model.description:gmatch("[^\n]+") do
              table.insert(lines, "  " .. line)
            end
          end
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            set_avante_model(selection.value.id)
          end
        end)
        return true
      end,
    }):find()
  end, opts.refresh)
end

-- Setup commands
function M.setup()
  vim.api.nvim_create_user_command("OpenRouterModels", function(cmd_opts)
    local args = cmd_opts.args or ""
    local refresh = args:match("refresh") ~= nil
    M.telescope_pick({ refresh = refresh })
  end, {
    nargs = "?",
    complete = function()
      return { "refresh" }
    end,
    desc = "Pick OpenRouter model for Avante",
  })

  vim.api.nvim_create_user_command("OpenRouterRefresh", function()
    M.get_models(function(models)
      vim.notify("Cached " .. #models .. " OpenRouter models", vim.log.levels.INFO)
    end, true)
  end, {
    desc = "Refresh OpenRouter models cache",
  })
end

return M
