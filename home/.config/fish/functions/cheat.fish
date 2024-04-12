function cheat
    for arg in $argv
        cat ~/".shellconf/cheats/$arg.txt"
    end
end

complete cheat -fa (string join " " (path change-extension "" (path basename ~/.shellconf/cheats/*)))

