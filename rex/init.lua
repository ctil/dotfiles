-- Rex config, migrated from tmux, Ghostty and iTerm2.

-- tmux (~/.tmux.conf), prefix ctrl+b
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })
rex.bind("ctrl+b>r", "client.config.reload")
rex.bind("ctrl+b>up", "pane.resize", { amount = 5, direction = "up" })
rex.bind("ctrl+b>down", "pane.resize", { amount = 5, direction = "down" })
rex.bind("ctrl+b>left", "pane.resize", { amount = 5, direction = "left" })
rex.bind("ctrl+b>right", "pane.resize", { amount = 5, direction = "right" })
rex.bind("ctrl+b>z", "pane.zoom")
rex.bind("ctrl+b>t", "pane.zoom")
rex.bind("ctrl+b>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+b>shift+-", "pane.split", { direction = "down" })
rex.bind("ctrl+b>l", "pane.send_key", { key = "ctrl+l" })
-- ctrl+b <n> selects tab n (tmux base-index 1)
for i = 1, 9 do
  rex.bind("ctrl+b>" .. i, "client.tab.goto", { index = i })
end

-- tmux repeatable (bind -r) bindings: ctrl+b ctrl+r enters, enter/escape leaves
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+b>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")
rex.bind("repeat/up", "pane.resize", { amount = 5, direction = "up" })
rex.bind("repeat/down", "pane.resize", { amount = 5, direction = "down" })
rex.bind("repeat/left", "pane.resize", { amount = 5, direction = "left" })
rex.bind("repeat/right", "pane.resize", { amount = 5, direction = "right" })
rex.bind("repeat/z", "pane.zoom")
rex.bind("repeat/t", "pane.zoom")
rex.bind("repeat/shift+\\", "pane.split", { direction = "right" })
rex.bind("repeat/shift+-", "pane.split", { direction = "down" })

-- Ghostty (~/.config/ghostty/config)
rex.bind("cmd+p", "pane.send_key", { key = "ctrl+p" })
rex.bind("ctrl+enter", "com.superlogical.terminal.clear")
rex.bind("shift+enter", "pane.send_key", { key = "ctrl+j" })

-- iTerm2 (GlobalKeyMap)
rex.bind("shift+cmd+left", "client.tab.move", { direction = "backward" })
rex.bind("shift+cmd+right", "client.tab.move", { direction = "forward" })
rex.bind("cmd+right", "pane.focus_next")
rex.bind("cmd+left", "pane.focus_previous")
