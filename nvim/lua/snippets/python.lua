local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("hfload", {
    t({"from transformers import AutoTokenizer, AutoModelForCausalLM", ""}),
    t({"model_path = '"}), i(1), t({"'", ""}),
    t({"tokenizer = AutoTokenizer.from_pretrained(model_path)", ""}),
    t("model = AutoModelForCausalLM.from_pretrained(model_path)"),
    i(0),
  }),
}
