{
  inputs,
  ...
}:
{
  imports = [ ./bat.nix ];

  home.file.".config/nvim" = {
    source = "${inputs.dotfiles}/.config/nvim";
    recursive = true;
  };
}
