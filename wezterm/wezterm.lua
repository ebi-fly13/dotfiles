-- WezTerm (Windows 側) の設定。
--
-- このリポジトリは NixOS-WSL 側の管理用なので、WezTerm 本体・このファイルの
-- 適用は Nix のビルド対象外。Windows 側で以下のようにシンボリックリンクを
-- 張って読み込ませる(README.md 参照)。
--
--   New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.wezterm.lua `
--     -Target \\wsl$\NixOS\home\ebi\dotfiles\wezterm\wezterm.lua

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- `wsl -l -v` で表示される distro 名。異なる場合はここを書き換える。
local distro = "NixOS"

config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.9

config.default_domain = "WSL:" .. distro
config.wsl_domains = {
	{
		name = "WSL:" .. distro,
		distribution = distro,
		default_cwd = "~",
	},
}

config.keys = {
	-- 右にペインを分割
	{
		key = "r",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane { direction = "Right", size = { Percent = 50 } },
	},
	-- 下にペインを分割
	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane { direction = "Down", size = { Percent = 50 } },
	},
	-- 画面とスクロールバックをクリア
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ClearScrollback "ScrollbackAndViewport",
	},
}

return config
