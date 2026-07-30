{ ... }:

{
  # VS Code Remote-WSL needs a working dynamic linker for the foreign
  # nodejs binary it downloads; nix-ld provides that directly instead of
  # patching/replacing the binary (see NixOS-WSL docs, "Option 1").
  programs.nix-ld.enable = true;

  services.vscode-server.enable = false;
}
