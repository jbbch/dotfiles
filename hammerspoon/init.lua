-- Hammerspoon app launcher hotkeys
-- Caps Lock is mapped by Karabiner to Hyper when held:
-- Hyper = Ctrl + Option + Command + Shift

local hyper = {"ctrl", "alt", "cmd", "shift"}

local function bindApp(key, appName)
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(appName)
  end)
end

-- App focus/launch shortcuts
bindApp("0", "Ghostty")
bindApp("A", "Arc")
bindApp("1", "Zen")
bindApp("T", "TickTick")

hs.alert.show("Hammerspoon: Hyper app hotkeys loaded")
