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
rex.bind("ctrl+b>c", "client.tab.new")
rex.bind("ctrl+b>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+b>shift+-", "pane.split", { direction = "down" })
rex.bind("ctrl+b>l", "pane.send_key", { key = "ctrl+l" })
rex.bind("ctrl+b>x", "pane.close")
-- ctrl+b s / ctrl+b ; are bound below, after the last-session actions.
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

-- vim-tmux-navigator equivalent: ctrl+h/j/k/l moves between panes, but passes
-- the key through when vim is in front (nvim then calls `rex focus` at its edge).
local terminal = "com.superlogical.terminal"
local nav = {
	h = { dir = "left", byte = "\8" },
	j = { dir = "down", byte = "\n" },
	k = { dir = "up", byte = "\11" },
	l = { dir = "right", byte = "\12" },
}
local function is_vim(block_id)
	local p = rex.block.call(terminal, "process", { block_id = block_id })
	local fg = p and p.foreground
	local name = ((fg and (fg.argv0 or fg.name)) or ""):match("[^/]*$")
	return name:match("^g?n?vim?x?$") ~= nil or name == "view" or name == "fzf"
end
for key, n in pairs(nav) do
	rex.action({
		name = "nav_" .. key,
		title = "Navigate " .. n.dir .. " (vim-aware)",
		run = function(ctx)
			if ctx.block_id and is_vim(ctx.block_id) then
				rex.block.call(terminal, "write", { block_id = ctx.block_id, data = n.byte })
			else
				rex.session.focus_direction({ direction = n.dir })
			end
		end,
	})
	rex.bind("ctrl+" .. key, "nav_" .. key)
end

-- tmux copy-mode substitute: Rex has no vi copy mode, so ctrl+b v opens the
-- pane's scrollback in nvim (read-only, cursor at the bottom) in a floating
-- pane covering the window. Use v/V/y as usual; :q returns to the pane.
rex.action({
	name = "copy_mode",
	title = "Open Scrollback in nvim",
	run = function(ctx)
		if not ctx.block_id then
			return
		end
		local script = [[
f=$(mktemp -t rex-scrollback) || exit 1
rex capture -b "$1" --trim --unwrap > "$f"
nvim -R -c 'set nomodified' + "$f"
rm -f "$f"
]]
		rex.call("session.new_layer", {
			session_id = ctx.session_id or rex.session_id,
			bounds = { 0, 0, 1, 1 },
			focus = true,
			layout = {
				block = {
					flavor = "com.superlogical.terminal.shell",
					options = { command = { "/bin/sh", "-c", script, "sh", ctx.block_id } },
				},
			},
		})
	end,
})
rex.bind("ctrl+b>v", "copy_mode")

-- tmux `switch-client -l` equivalent: ctrl+b ; toggles to the last session.
-- Rex doesn't expose which session the app is showing or fire an event when
-- it changes, so the last session is recorded whenever a session is left via
-- these bindings (ctrl+b ; and ctrl+b s). Switches made with the mouse/sidebar
-- aren't seen. State lives in a file, keyed by client, so it survives reloads.
local last_session_file = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"))
	.. "/rex/last_session"

local function read_last_sessions()
	local t = {}
	local f = io.open(last_session_file, "r")
	if f then
		for line in f:lines() do
			local client, session = line:match("^(%S+)%s+(%S+)$")
			if client then
				t[client] = session
			end
		end
		f:close()
	end
	return t
end

local function remember_session(ctx)
	if not (ctx.client_id and ctx.session_id) then
		return
	end
	local t = read_last_sessions()
	t[ctx.client_id] = ctx.session_id
	rex.exec({ "mkdir", "-p", (last_session_file:match("^(.*)/")) })
	local f = io.open(last_session_file, "w")
	if f then
		for client, session in pairs(t) do
			f:write(client, " ", session, "\n")
		end
		f:close()
	end
end

local function session_exists(id)
	local r = rex.call("session.list", {})
	for _, s in ipairs((r and r.sessions) or {}) do
		if s.session_id == id then
			return true
		end
	end
	return false
end

rex.action({
	name = "last_session",
	title = "Switch to Last Session",
	run = function(ctx)
		local last = ctx.client_id and read_last_sessions()[ctx.client_id]
		remember_session(ctx)
		if last and last ~= ctx.session_id and session_exists(last) then
			rex.client.queue("session.select", { session_id = last })
		else
			rex.client.queue("session.previous")
		end
	end,
})

rex.action({
	name = "switch_session",
	title = "Change Session (remember last)",
	run = function(ctx)
		remember_session(ctx)
		rex.client.queue("session.switch")
	end,
})

rex.bind("ctrl+b>;", "last_session")
rex.bind("ctrl+b>s", "switch_session")
