set fish_greeting
function key_bindings
    fish_vi_key_bindings insert
    fish_default_key_bindings --no-erase -M insert
    bind \ec fzf_jump_directory
    bind -M insert \ec fzf_jump_directory
    bind \ek prevd
    bind \ej nextd
    bind -M insert \ek 'prevd && commandline -f repaint || echo -ne \a'
    bind -M insert \ej 'nextd && commandline -f repaint || echo -ne \a'
end
set -g fish_key_bindings key_bindings

function fish_mode_prompt
  switch $fish_bind_mode
    case default
      set_color --bold brgreen
      echo 'N'
    case insert
      set_color --bold 0087ff
      echo 'I'
    case replace_one
      set_color --bold brred
      echo 'r'
    case replace
      set_color --bold brred
      echo 'R'
    case visual
      set_color --bold brmagenta
      echo 'V'
    case '*'
      set_color --bold white
      echo '?'
  end
  set_color normal
  echo ' '
end
