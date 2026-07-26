{ ... }:

{
  # RSA/SSH keys are managed by 1Password on the Windows host. Rather than
  # bridging its agent socket into WSL, shell out to Windows' own ssh.exe,
  # which talks to 1Password's Windows SSH agent (named pipe) directly.
  programs.fish.shellAliases = {
    ssh = "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
  };
}
