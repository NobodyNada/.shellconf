function f
    if set -q argv[1]
        open -R $argv
    else
        open -R .
    end
end

