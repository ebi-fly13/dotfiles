{ ... }:

{
  # RSA/SSH keys are managed by 1Password on the Windows host. Enabling
  # "Use the SSH agent" + WSL integration in 1Password's Developer settings
  # exposes its agent socket to every WSL distro at ~/.1password/agent.sock.
  environment.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
  };
}
