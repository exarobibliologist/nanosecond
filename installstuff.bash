#!/bin/bash

# Function to install package if not already installed
# ==============================================================================
# USAGE: InstallPackageIfNotExist <package_name> [installer]
#
# DESCRIPTION:
#   Checks if a specific package is installed using a high-speed dpkg query. 
#   If the package is missing, it installs it. If it already exists, it 
#   skips it and prints a status message.
#
# PARAMETERS:
#   $1 (Required) - The exact name of the package to check/install.
#   $2 (Optional) - The package manager to use. Defaults to "apt". 
#                   Can be explicitly set to "aptitude" for forced installs.
#
# EXAMPLES:
#   InstallPackageIfNotExist "htop"             # Uses default apt
#   InstallPackageIfNotExist "conky" "aptitude" # Uses aptitude
# ==============================================================================

function InstallPackageIfNotExist() {
    local package=$1
    local installer=${2:-"apt"}

    # High-speed check: dpkg -s is much faster than piping dpkg -l
    if ! dpkg -s "$package" &> /dev/null; then
        echo -e "Working on $(color 255 0 0)$package$(reset)..."
        
        # Install the package
        if [[ "$installer" == "aptitude" ]]; then
            sudo aptitude install -Pr "$package"
        else
            sudo apt install "$package" 
        fi
    else
        echo -e "$(color 255 0 0)$package$(reset) is already installed."
    fi
}

complete -F _custom_apt_complete InstallPackageIfNotExist

# Function for menu-driven installation
function installstuff()
{
# Define packages list in a neat, easy-to-read array
PACKAGES=(
    aptitude
    apt-transport-https
    apt
    bash-completion
    curl
    dirmngr
    inxi
    wget
    systemd-timesyncd
)

# Loop through each package in the array
for pkg in "${PACKAGES[@]}"; do
    # dpkg -s silently checks if the exact package is installed
    if dpkg -s "$pkg" &> /dev/null; then
        echo "$(color 255 0 0)$pkg$(reset) already installed. Skipping."
    else
        echo "Installing $pkg..."
        sudo apt install -y "$pkg"
    fi
done

pressanykey
	clear
	echo -e "Showing you your sources.list. $(color 196)If anything looks off, abort the script immediately and fix it!$(reset)\n"
	# 1. Highlight the blue set of patterns (main, contrib, non-free, etc.)
	GREP_COLORS='mt=38;2;255;0;0;48;2;0;0;255' grep -E --color=always 'main|contrib|non-free|non-free-firmware|$' /etc/apt/sources.list | \
	# 2. Pipe to the second grep to highlight the red set of patterns (stable, testing, unstable, etc.)
	GREP_COLORS='mt=38;2;0;0;0;48;2;255;0;0' grep -E --color=always 'stable|stable-updates|stable-security|testing|testing-updates|unstable|experimental|$'
	pressanykey
	KeepInstallingMoreStuff
}

# ==============================================================================
# USAGE: KeepInstallingMoreStuff
#
# DESCRIPTION:
#   Launches an interactive, menu-driven installation wizard for setting up a 
#   fresh Linux environment. It categorizes software into logical groups.
#
# HOW TO ADD NEW SOFTWARE:
#   To add standard packages, simply find the appropriate category in the 
#   'options' array below and add the package name to the end of the string.
#   (e.g., "Terminal = btop konsole terminator NEW_PACKAGE")
#   The script will automatically parse the string and install it.
#
#   For complex installations (like Flatpaks or Steam), add a title without 
#   an equals sign (e.g., "Custom Setup") and add a matching block to the 
#   'case' statement below.
# ==============================================================================

function KeepInstallingMoreStuff() {
    clear
    echo -e "Options:\n"

    # 1. The Master Array
    local options=(
        "$(color 255 255 255)Compressed Files$(reset) = gzip p7zip-full tar unrar-free unzip"
        "$(color 255 255 255)Conky$(reset) = conky-all"
        "$(color 255 255 255)Documents$(reset) = kate libreoffice"
        "$(color 255 255 255)Drive Management$(reset) = apper brasero furiusisomount k3b smartmontools xfburn"
        "$(color 255 255 255)File Browsers$(reset) = caja dolphin krusader nautilus nemo spacefm"
        "$(color 255 255 255)Font Managers$(reset) = figlet font-manager gucharmap"
        "$(color 255 255 255)Fonts$(reset) = fonts-recommended fonts-3270 fonts-averia-gwf fonts-averia-sans-gwf fonts-averia-serif-gwf fonts-cabin fonts-cantarell fonts-cardo fonts-century-catalogue fonts-comfortaa fonts-dejavu fonts-dkg-handwriting fonts-droid-fallback fonts-dosis fonts-ebgaramond fonts-ebgaramond-extra fonts-elusive-icons fonts-essays1743 fonts-freefont-ttf fonts-gnutypewriter fonts-go fonts-hack-ttf fonts-junicode fonts-jura fonts-lato fonts-linex fonts-liberation fonts-lobster fonts-lobstertwo fonts-noto fonts-opendyslexic fonts-open-sans fonts-pc fonts-pc-extra fonts-play fonts-roboto fonts-sora fonts-terminus fonts-ubuntu* fonts-unifont fonts-wine fonts-xfree86-nonfree ttf-mscorefonts-installer"
        "$(color 255 255 255)Fortunes$(reset) = fortunes fortune-mod fortunes-spam"
        "$(color 255 255 255)Games$(reset) = games-adventure games-arcade games-board games-card games-chess games-console games-education games-emulator games-finest games-fps games-minesweeper games-mud games-platform games-puzzle games-racing games-rogue games-rpg games-shootemup games-simulation games-sport games-strategy games-tetris games-toys games-typing angrydd atanks kobodeluxe manaplus zangband"
        "$(color 255 255 255)GNOME Boxes$(reset) = gnome-boxes"
        "$(color 255 255 255)Internet$(reset) = chromium htop mtr namebench netselect-apt strace speedtest-cli telegram-desktop torbrowser-launcher"
        "$(color 255 255 255)IRC$(reset) = hexchat konversation"
        "$(color 255 255 255)Media$(reset) = flac lame moc smplayer vlc"
        "$(color 255 255 255)Pictures$(reset) = feh inkscape luminance-hdr gimp gimp-data-extras gimp-gap gimp-lensfun gimp-ufraw gimp-texturiz gwenview kde-spectacle ufraw ufraw-batch"
        "$(color 255 255 255)Terminal$(reset) = btop konsole terminator"
        "$(color 255 255 255)Torrents$(reset) = amule deluge ktorrent qbittorrent transmission-gtk"
        "$(color 255 255 255)Virtualbox$(reset) = virtualbox-nonfree"
        "$(color 255 255 255)XFCE Desktop$(reset) = xfce4 xfce4-goodies"
        "$(color 255 255 255)X Screensavers$(reset) = xscreensaver xscreensaver-data xscreensaver-data-extra xscreensaver-screensaver-bsod xscreensaver-gl xscreensaver-gl-extra rss-glx"
        "$(color 255 255 255)FlatPak$(reset)"
        "$(color 255 255 255)Python Setup$(reset)"
        "$(color 255 255 255)Snap Store$(reset)"
        "$(color 255 255 255)Steam$(reset)"
        "$(color 255 255 255)WINE$(reset)"
        "$(color 255 255 255)Exit$(reset)"
    )

    PS3="Please select an option: "
    select installmenuchoice in "${options[@]}"; do
        
        # 2. Check for the Auto-Parser first!
        if [[ "$installmenuchoice" == *" = "* ]]; then
            packages="${installmenuchoice#* = }"
            
            for pkg in $packages; do
                InstallPackageIfNotExist "$pkg"
            done

        # 3. The Special Cases
        else
            case "$installmenuchoice" in
                *"FlatPak"*)
                    sudo apt update
                    for pkg in flatpak gnome-software-plugin-flatpak; do
                        InstallPackageIfNotExist "$pkg"
                    done
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                    sudo apt update
                    ;;
                *"Snap Store"*)
                    sudo apt update
                    InstallPackageIfNotExist snapd
                    sudo snap install snapd
                    ;;
                *"Python Setup"*)
                    for pkg in python3 python3-pip python3-tk; do
                        InstallPackageIfNotExist "$pkg"
                    done
                    pip install Pillow --break-system-packages
                    ;;
                *"Steam"*)
                    sudo dpkg --add-architecture i386
                    sudo apt update
                    InstallPackageIfNotExist steam-installer "aptitude"
                    sudo apt install mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
                    ;;
                *"WINE"*)
                    sudo dpkg --add-architecture i386
                    sudo apt update
                    for pkg in wine wine32 wine64 libwine libwine:i386 fonts-wine; do
                        InstallPackageIfNotExist "$pkg" "aptitude"
                    done
                    ;;
                *"Exit"*)
                    break
                    ;;
                *)
                    echo "Invalid choice, please try again."
                    ;;
            esac
        fi
        pressanykey
        clear
        echo -e "Options:\n"
        REPLY= 
    done
}
