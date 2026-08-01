{ username, ... }:

{
  environment.etc."gitconfig".text = ''
    [user]
    	name = ebi-fly13
    	email = yano.hiroto.xx@gmail.com
    [sequence]
    	editor = code
    [core]
    	editor = code
    	excludesfile = /home/${username}/.gitignore_global
    	sshCommand = /mnt/c/Windows/System32/OpenSSH/ssh.exe
    [init]
    	defaultBranch = main
  '';
}
