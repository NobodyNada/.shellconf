function pman
    man -t $argv | ps2pdf - - | open -fa Preview
end

