function fish_title
    set command (status current-command)
    if test "$command" = fish
        echo (prompt_pwd)
    else
        echo $command
    end
end

