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
-- Windows Terminal の "Vintage" カーソル(下部の太い矩形)に近い見た目。
-- WezTerm に同名のスタイルは無いため、太めのアンダーラインで代用。
config.default_cursor_style = "BlinkingUnderline"
config.cursor_thickness = "4px"
-- WezTerm の既定はゆっくりフェードする点滅。Windows Terminal のような
-- くっきり速い点滅にするため、間隔を短くしフェードを無くす。
config.cursor_blink_rate = 800
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

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
	-- 設定を手動リロード。\\wsl.localhost\ 経由でこのファイルを読んでいると
	-- 自動リロード(ファイル変更監視)が発火しないことがあるため用意。
	{
		key = ",",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
	-- Windows 側の PowerShell を新規タブで開く。domain を明示しないと
	-- default_domain (WSL) 側で起動しようとしてしまう。
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab {
			args = { "powershell.exe" },
			domain = { DomainName = "local" },
		},
	},
	-- WezTerm の既定では Ctrl+C はコピーではなく SIGINT、Ctrl+V は
	-- 未割り当て(コピペは本来 Ctrl+Shift+C/V)。Windows のアプリに
	-- 合わせて、選択中のみ Ctrl+C をコピーにし、それ以外は通常通り
	-- SIGINT を送る。Ctrl+V は常にペーストにする。
	{
		key = "c",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local selection = window:get_selection_text_for_pane(pane)
			if selection and #selection > 0 then
				window:perform_action(wezterm.action.CopyTo("Clipboard"), pane)
			else
				window:perform_action(wezterm.action.SendKey { key = "c", mods = "CTRL" }, pane)
			end
		end),
	},
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

-- ウィンドウタイトルバーに、実行中シェルのOS名(distro名)を表示する。
-- 表示位置(中央寄せかどうか)はOS側のタイトルバー実装に依存するため
-- WezTerm 側では制御できない。
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	local domain = tab.active_pane.domain_name or ""
	return domain:match("^WSL:(.+)$") or domain
end)

return config
