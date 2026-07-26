{ ... }:

{
  environment.etc."gitconfig".text = ''
    [user]
    	name = ebi-fly13
    	email = yano.hiroto.xx@gmail.com
    [sequence]
    	editor = code
    [core]
    	editor = code
    	excludesfile = /home/ebi/.gitignore_global
    [init]
    	defaultBranch = main
  '';
}
