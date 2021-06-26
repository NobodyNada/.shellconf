set fish_greeting
function fish_title; end
function key_bindings
    fish_vi_key_bindings insert
    fish_default_key_bindings --no-erase -M insert
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
