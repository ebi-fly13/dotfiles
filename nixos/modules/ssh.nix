{ ... }:

{
  # RSA/SSH keys are managed by 1Password on the Windows host, so ssh/ssh-add
  # must resolve to the Windows binaries. link (not register) so non-fish
  # processes can exec them via $PATH too.
  programs.fish.shellInit = ''
    wslwrap link ssh
    wslwrap link ssh-add
  '';
}
