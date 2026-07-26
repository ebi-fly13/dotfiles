; WezTerm (Windows 側) を前面に呼び出す / 背面に隠すグローバルホットキー。
;
; このリポジトリは NixOS-WSL 側の管理用なので、AutoHotkey 本体・このスクリプトの
; 実行は Nix のビルド対象外。Windows 側に AutoHotkey v2
; (https://www.autohotkey.com/) を導入した上で実行する(README.md 参照)。
;
; WezTerm には Windows Terminal の Quake モードのような表示/非表示トグル機能が
; 無く、wezterm.lua 側のキーバインドは WezTerm がフォーカスされている時しか
; 効かない(=隠れている状態からは呼び出せない)。そのため、フォーカス状態に
; 関係なく常に有効なグローバルホットキーとして AutoHotkey から制御する。
;
; どのウィンドウがアクティブでも常に有効:
;   Ctrl+Alt+Up   … WezTerm を前面に出す(最小化していれば復元してアクティブ化)
;   Ctrl+Alt+Down … WezTerm を最小化して背面に隠す

#Requires AutoHotkey v2.0

^!Up:: {
    if WinExist("ahk_exe wezterm-gui.exe") {
        WinRestore
        WinActivate
    }
}

^!Down:: {
    if WinExist("ahk_exe wezterm-gui.exe")
        WinMinimize
}
