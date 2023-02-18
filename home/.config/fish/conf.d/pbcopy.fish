if [ "$TERM" = xterm-kitty ]
    function pbcopy
        kitten clipboard $argv
    end

    function pbpaste
        kitten clipboard --get-clipboard $argv
    end
else if string match -q 'CYGWIN*' $UNAME
    function pbcopy
        putclip
    end
    function pbpaste
        getclip
    end
else if [ "$UNAME" = Linux ]
    function pbcopy
        xclip -i -sel clip
    end
    function pbpaste
        xclip -o -sel clip
    end
end
