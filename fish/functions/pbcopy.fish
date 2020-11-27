if string match -q 'CYGWIN' (uname -s) 
    function pbcopy
        putclip
    end
    function pbpaste
        getclip
    end
end
