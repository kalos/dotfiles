if test $TERM = 'linux'
  set -x STARSHIP_CONFIG "$HOME/.config/starship_console.toml"
end
starship init fish | source
