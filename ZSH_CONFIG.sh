#!/bin/bash

STYLE_CLEAR="\033[0m"
COLOR_DARK="\033[1;30m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[1;33m"
COLOR_BLUE="\033[1;34m"
COLOR_PURPLE="\033[0;35m"
COLOR_WHITE="\033[0;37m"

NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/FiraCode.zip"
POWERLEVEL_URL="https://github.com/romkatv/powerlevel10k.git"
ZSHAUTOSUGGEST_URL="https://github.com/zsh-users/zsh-autosuggestions"

LST_DEPENDENCES=(
    git
    imagemagick
    neofetch
    unzip
    w3m
    wget
    zsh
)

InstallDependences () {
    # update installed softwares
    echo -e "$COLOR_GREEN[INIT] :: Updating softwares$STYLE_CLEAR"
    sudo apt update -y

    # Install dependeces
    echo -e "$COLOR_GREEN[INIT] :: Install dependences$STYLE_CLEAR"
    for depend in ${LST_DEPENDENCES[@]}; do
	echo -e "$COLOR_DARK[SOFTWARE] :: $depend$STYLE_CLEAR"

        # check if the dependency is installed
        if ! dpkg -l | grep -q $depend; then
            echo -e "$COLOR_DARK[INSTALLING] :: $depend$STYLE_CLEAR"
            sudo apt install "$depend" -y
        fi

        echo -e "$COLOR_PURPLE[INSTALLED] :: $depend$STYLE_CLEAR"
    done
}

SetFonts () {
    local FONTS_ZIP="FiraCode.zip"
    local DIR_LOCAL="$HOME/.local"
    local DIR_SHARE="$DIR_LOCAL/share"
    local DIR_FONTS="$DIR_SHARE/fonts"

    echo -e "$COLOR_DARK[FONTS] :: Get fonts$STYLE_CLEAR"
    wget $NERD_FONTS_URL

    unzip $FONTS_ZIP
    rm $FONTS_ZIP
    chmod 644 *.ttf

    # check if directory exist
    if [[ ! -d "$DIR_FONTS" ]]; then
        mkdir -p $DIR_LOCAL
        mkdir -p $DIR_SHARE
        mkdir -p $DIR_FONTS
    fi

    mv *.ttf "$DIR_FONTS/"
}

UpdateZshConfig () {
    local ZSH_PATH=$(cat /etc/shells | grep zsh | head -1)
    local ZSHCONF_PATH="$HOME/.zshrc"

    local DIR_IMAGE="$HOME/Image"
    local DIR_WALLPAPER="$DIR_IMAGE/wallpaper"
    local DIR_WALLNEO="$DIR_WALLPAPER/neofetch"
    local IMAGE_NEOFETCH="$DIR_WALLNEO/wallpaper_neofetch.png"

    chsh -s $ZSH_PATH

    if [[ ! -d "$DIR_WALLNEO" ]]; then
        mkdir -p $DIR_IMAGE
        mkdir -p $DIR_WALLPAPER
        mkdir -p $DIR_WALLNEO
    fi

    cp ./assets/img/wallpaper_neofetch.png "$DIR_WALLNEO/"

    if [[ ! -f "$ZSHCONF_PATH" ]]; then
        echo -e "# MY ALIASES\nalias neofetch=\"neofetch --w3m $IMAGE_NEOFETCH\"\n\n# DISPLAY BANNER\nneofetch" >> $ZSHCONF_PATH
    fi
}

InstallCustomZsh () {
    local DIR_POWERLEVEL="$HOME/powerlevel10k"
    local DIR_ZSH="$HOME/.zsh"
    local FILE_ZSHRC="$HOME/.zshrc"
    local DIR_ZSHAUTOSU="$DIR_ZSH/zsh-autosuggestions"

    git clone --depth=1 $POWERLEVEL_URL $DIR_POWERLEVEL
    

    if [[ ! -d "$DIR_ZSH" ]]; then
        mkdir $DIR_ZSH
    fi

    git clone $ZSHAUTOSUGGEST_URL  $DIR_ZSHAUTOSU

    if ! grep -Fxq "p10k-instant-prompt" $FILE_ZSHRC; then
        echo -e "if [[ -r \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then" >> $FILE_ZSHRC
        echo -e "source \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\"\nfi" >> $FILE_ZSHRC
    fi

    if ! grep -Fxq "powerlevel10k.zsh-theme" $FILE_ZSHRC; then
        echo -e "\n\nsource $DIR_POWERLEVEL/powerlevel10k.zsh-theme" >> $FILE_ZSHRC
    fi

    if ! grep -Fxq "zsh-autosuggestions.zsh" $FILE_ZSHRC; then
        echo -e "source $DIR_ZSHAUTOSU/zsh-autosuggestions.zsh" >> $FILE_ZSHRC
    fi

    if ! grep -Fxq ".p10k.zsh" $FILE_ZSHRC; then
        echo -e "\n\n[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> $FILE_ZSHRC
    fi
}

InstallDependences
SetFonts
UpdateZshConfig
InstallCustomZsh

echo -e "$COLOR_BLUE[FINISHED] :: OPEN A NEW TERMINAL TO END CONFIGURATION$STYLE_CLEAR"
