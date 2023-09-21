function cargo_update_all
    cargo install (cargo install --list | awk '/[^)]:$/ { print $1 }')
end

