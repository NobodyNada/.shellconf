set -x PATH $HOME/bin $HOME/.bin $PATH
alias xcodeclean='rm -rf ~/Library/Developer/Xcode/DerivedData/* && rm -rf ~/Library/Caches/com.apple.dt.Xcode'
if test -f ~/.homebrewtoken
    export HOMEBREW_GITHUB_API_TOKEN=(cat ~/.homebrewtoken)
end
alias xcode="open -a Xcode"
alias reload="exec login -pf jonathan"
alias pi="ssh pi@192.168.1.75"
alias qcpi="ssh pi@192.168.1.76"
alias swiftpi="ssh pi@192.168.1.77"
#alias rpi="ssh pi@76.14.235.124"
alias rpi="ssh pi@direct.nobodynada.com"
command -v hub > /dev/null; and alias git=hub
alias ffrecv="ffplay tcp://192.168.1.222:9000"
#/alias http="curlie"
alias https="http --ssl"
alias vscode="open -a 'Visual Studio Code'"
alias firefox='/Applications/Firefox.app/Contents/MacOS/firefox'
#eval (docker-machine env)

alias ff='firefox -url'
alias g=git
#alias _l='rm -rf ~/Desktop/logs && mkdir ~/Desktop/logs && scp \'lvuser@10.14.25.2:/u/logfile_*\' ~/Desktop/logs && chmod a-x ~/Desktop/logs/*'
#alias l='_l && cd ~/Desktop/logs'
#alias pl='_l && pushd ~/Desktop/logs'
#alias ol='_l && open ~/Desktop/logs'
#alias r='ssh lvuser@10.14.25.2'
alias s='firefox -search'
alias beep='echo -e \a'
[ $UNAME = Darwin ]; and alias ls="ls -G"; or alias ls="ls --color=auto"
[ $UNAME = Darwin ]; and set -x LSCOLORS Exfxdxdxbxegedabagacad

if test -d /opt/devkitpro
    set -x DEVKITPRO /opt/devkitpro
    set -x DEVKITARM $DEVKITPRO/devkitARM
    set -x DEVKITPPC $DEVKITPRO/devkitPPC
    set -x PATH $PATH $DEVKITPRO/tools/bin $DEVKITPRO/devkitPPC/bin $DEVKITPRO/devkitARM/bin 
end
if test -d /usr/local/opt/util-linux
    set -x PATH $PATH /usr/local/opt/util-linux/bin /usr/local/opt/util-linux/sbin
end

[ $UNAME = Darwin ]; and set -x JAVA_HOME (/usr/libexec/java_home -v 11.0)

set -x SWIFTENV_ROOT $HOME/.swiftenv
set -x PATH $SWIFTENV_ROOT/bin $PATH
exists swiftenv; and source (swiftenv init - | psub)

if exists pyenv
    status is-login; and pyenv init --path | source
    pyenv init - | source
end

set -x PATH /usr/local/opt/perl/bin $PATH
set -x PATH $PATH $HOME/go/bin

set -x PATH $HOME/.cargo/bin $PATH
command -q rvm; and rvm default

exists hub; and alias git=hub
alias v=vi; set -x EDITOR vi
exists vim; and begin; alias vi=vim; set -x EDITOR vim; end
exists nvim; and begin; alias vim=nvim; set -x EDITOR nvim; end

set -x RUST_BACKTRACE 1
fish_add_path /usr/local/sbin
