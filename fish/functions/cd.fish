function cd
    if [ -z "$argv" ]
        builtin cd
    else if [ -d "$argv" -o "$argv" = "-" ]
        builtin cd "$argv"
    else
        # split argument into first path component + remaining path components
        set -l arg (string split -m 1 / "$argv")

        # get last path components of tagged directories
        set -l tagged ([ (uname) = Darwin ]; and tag -f '*')
        set -l basenames (echo $tagged | xargs basename -a)

        # is there a match?
        if set -l index (contains -i "$arg[1]" $basenames)
            builtin cd "$tagged[$index]"/"$arg[2]"
        else
            # fallback to cd as error handler
            builtin cd "$argv"
        end
    end
end

function cd_tags_completions
    set -l tagged (tag -f '*')
    set -l basenames (echo $tagged | xargs basename -a)
    printf '%s/\n' $basenames # add tagged directories to the completion list

    # if the user has typed a tagged directory as the base path, also add matching subdirectories
    set -l token (commandline -ct)

    # split into first path component + remaining path components
    set -l token (string split -m 1 / "$token")
    if set -l index (contains -i "$token[1]" $basenames)
        for d in "$tagged[$index]"/"$token[2]"*/
            # replace the tag path with just the basename
            echo $d
            echo "$token[1]"(string sub -s (math 1 + (string length "$tagged[$index]")) "$d")
        end
    end
end

# add tags to completion
complete -c cd -a "(cd_tags_completions)"
complete -c pushd -a "(cd_tags_completions)"
