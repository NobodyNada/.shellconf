if string match -q 'CYGWIN' (uname -s) 
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
