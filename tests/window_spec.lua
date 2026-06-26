local eq = assert.are.same
local window = require("buffon.ui.window")

describe("window", function()
  local function close_win(win_id)
    if win_id and vim.api.nvim_win_is_valid(win_id) then
      vim.api.nvim_win_close(win_id, false)
    end
  end

  it("applies winhighlight when transparent is true", function()
    local w = window.Window:new(" Buffon ", window.WIN_POSITIONS.TOP_RIGHT, { x = 0, y = 0 }, true)
    w:show()
    local wh = vim.api.nvim_get_option_value("winhighlight", { win = w.win_id })
    eq(
      wh,
      "Normal:BuffonWindow,FloatBorder:BuffonWindow,FloatTitle:BuffonWindow,FloatFooter:BuffonWindow,EndOfBuffer:BuffonWindow"
    )
    close_win(w.win_id)
  end)

  it("does not include BuffonWindow in winhighlight when transparent is false", function()
    local w = window.Window:new(" Buffon ", window.WIN_POSITIONS.TOP_RIGHT, { x = 0, y = 0 }, false)
    w:show()
    local wh = vim.api.nvim_get_option_value("winhighlight", { win = w.win_id })
    eq(wh:find("BuffonWindow", 1, true) == nil, true)
    close_win(w.win_id)
  end)

  it("does not include BuffonWindow in winhighlight when transparent is not provided", function()
    local w = window.Window:new(" Buffon ", window.WIN_POSITIONS.TOP_RIGHT, { x = 0, y = 0 })
    w:show()
    local wh = vim.api.nvim_get_option_value("winhighlight", { win = w.win_id })
    eq(wh:find("BuffonWindow", 1, true) == nil, true)
    close_win(w.win_id)
  end)
end)
