#!/bin/bash


# ----------------------------- Configuration ----------------------------- 

clear
set -eo pipefail
setfont ter-v32n

PS3="CHOICE> "

echo "Would you like to install Arch Linux using this script?"

select confirm in Yes No; do
	case $confirm in
		Yes)
			break
			;;
		No)
			echo "Cancelling Installation..."
			exit
			;;
	esac
done

clear

# Select boot partition
echo -e "Select \e[4;31mBoot\e[0m Partition:"
PARTITIONS=($(fdisk -l | awk '/^[/]/{print $1}'))

select partition in "${PARTITIONS[@]}"; do
	BOOTDEV=$partition
	break
done

clear

# Select root partition
echo -e "Select \e[4;34mRoot\e[0m Partition:"

select partition in "${PARTITIONS[@]}"; do
	ROOTDEV=$partition
	break
done

clear

# Select region
echo -e "Select \e[4;33mRegion\e[0m:"
REGIONS=("Africa" "America" "Antarctica" "Asia" "Australia" "Europe" "Pacific")

select region in "${REGIONS[@]}"; do
	SELECTED_REGION=$region
	break
done

clear

# Select city
echo -e "Select \e[4;35mCity\e[0m:"
CITIES=($(ls /usr/share/zoneinfo/$SELECTED_REGION))

select city in "${CITIES[@]}"; do
	SELECTED_CITY=$city
	break
done

clear

# Select CPU brand
echo -e "Select \e[4;35mCPU brand\e[0m:"

select brand in Intel AMD "Skip CPU microcode installation"; do
	CPU_BRAND=$brand
	
	if [ $CPU_BRAND == "Intel" ]; then
		MICROCODE_PKG="intel-ucode"
	elif [ $CPU_BRAND == "AMD" ]; then
		MICROCODE_PKG="amd-ucode"
	fi
	
	break
done

clear

# Select GPU brand
echo -e "Select \e[4;35mGPU brand\e[0m:"

select brand in Intel NVIDIA AMD "Skip GPU driver installation"; do
	GPU_BRAND=$brand
	
	if [ $GPU_BRAND == "Intel" ]; then
		GPU_PKGS=(
			"xf86-video-intel"
		)
	elif [ $GPU_BRAND == "NVIDIA" ]; then
		GPU_PKGS=(
			"nvidia"
			"nvidia-utils"
			"nvidia-settings"
			"lib32-nvidia-utils"
		)
	elif [ $GPU_BRAND == "AMD" ]; then
		GPU_PKGS=(
			"xf86-video-amdgpu"
			"vulkan-radeon"
			"lib32-vulkan-radeon"
		)
	fi
	
	break
done

clear

# Select backlight (REQUIRED FOR: dwmbar.sh, utilities.sh)
BACKLIGHTS=($(ls /sys/class/backlight))

select backlight in "${BACKLIGHTS[@]}"; do
	BACKLIGHT=$backlight
	break
done

clear

# Select network interface (REQUIRED FOR: dwmbar.sh)
NET_DEVICES=($(ls /sys/class/net))

select interface in "${NET_DEVICES[@]}"; do
	NET_INTERFACE=$interface
	break
done

clear

# Enter country (REQUIRED FOR: prayer.sh)
printf "Enter \e[4;95mCountry name or ISO 3166 code (ex: Netherlands or NL)\e[0m: "
read PRAYER_COUNTRY

if [ -z "$PRAYER_COUNTRY" ]; then 
	echo "Prayer times and hijri date will not be functional until you input the country and city in prayer.sh."
fi

clear

# Enter city (REQUIRED FOR: prayer.sh)
printf "Enter \e[4;95mCity name (ex: Makkah)\e[0m: "
read PRAYER_CITY

if [ -z "$PRAYER_CITY" ]; then 
	echo "Prayer times and hijri date will not be functional until you input the country and city in prayer.sh."
fi

clear

# Enter hostname
printf "Enter \e[4;94mHostname\e[0m: "
read HOSTNAME

if [ -z "$HOSTNAME" ]; then 
	echo "Hostname cannot be empty."
	exit
fi

clear

# Enter username
printf "Enter \e[4;95mUsername\e[0m: "
read USERNAME

if [ -z "$USERNAME" ]; then 
	echo "Username cannot be empty."
	exit
fi

clear

# Enter password(s)
echo "Set root password and user password to be the same?"

select confirm in Yes No; do
	SAME_PASSWORD=$confirm
	
	case $SAME_PASSWORD in
		Yes)
			printf "Enter \e[4;35mPassword\e[0m: "
			read -s PASSWORD
			printf "\n"
			
			if [ -z "$PASSWORD" ]; then
				echo "Password cannot be empty."
				exit
			fi
			
			printf "Confirm \e[4;35mPassword\e[0m: "
			read -s CONFIRM_PASSWORD
			printf "\n"
			
			if [ $PASSWORD != $CONFIRM_PASSWORD ]; then
				echo "Passwords do not match."
				exit
			fi
			
			USER_PASSWORD=$PASSWORD
			ROOT_PASSWORD=$PASSWORD
			break
			;;
		No)
			printf "Enter \e[4;35mRoot Password\e[0m: "
			read -s ROOT_PASSWORD
			printf "\n"
			
			if [ -z "$ROOT_PASSWORD" ]; then
				echo "Password cannot be empty."
				exit
			fi
			
			printf "Confirm \e[4;35mRoot Password\e[0m: "
			read -s CONFIRM_ROOT_PASSWORD
			printf "\n"
			
			if [ $ROOT_PASSWORD != $CONFIRM_ROOT_PASSWORD ]; then
				echo "Passwords do not match."
				exit
			fi
			
			printf "Enter \e[4;35m$USERNAME's Password\e[0m: "
			read -s USER_PASSWORD
			printf "\n"
			
			if [ -z "$USER_PASSWORD" ]; then
				echo "Password cannot be empty."
				exit
			fi
			
			printf "Confirm \e[4;35m$USERNAME's Password\e[0m: "
			read -s CONFIRM_USER_PASSWORD
			printf "\n"
			
			if [ $USER_PASSWORD != $CONFIRM_USER_PASSWORD ]; then
				echo "Passwords do not match."
				exit
			fi
			
			exit
			;;
	esac
done

clear

# Confirm inputted data
echo "Confirm Details:"
echo -e "\e[4;31mBOOT PARTITION:\e[0m $BOOTDEV"
echo -e "\e[4;31mROOT PARTITION:\e[0m $ROOTDEV"
echo -e "\e[4;31mREGION (TIMEZONE):\e[0m $SELECTED_REGION"
echo -e "\e[4;31mCITY (TIMEZONE):\e[0m $SELECTED_CITY"
echo -e "\e[4;31mCPU BRAND:\e[0m $CPU_BRAND"
echo -e "\e[4;31mGPU BRAND:\e[0m $GPU_BRAND"
echo -e "\e[4;31mBACKLIGHT:\e[0m $BACKLIGHT"
echo -e "\e[4;31mNET INTERFACE:\e[0m $NET_INTERFACE"
echo -e "\e[4;31mCOUNTRY (PRAYER):\e[0m $PRAYER_COUNTRY"
echo -e "\e[4;31mCITY (PRAYER):\e[0m $PRAYER_CITY"
echo -e "\e[4;31mHOSTNAME:\e[0m $HOSTNAME"
echo -e "\e[4;31mUSERNAME:\e[0m $USERNAME"
echo -e "\e[4;31mROOT AND USER SAME PASSWORD?:\e[0m $SAME_PASSWORD"
printf "\n"

select confirm in Continue Cancel; do
	case $confirm in
		Continue)
			break
			;;
		Cancel)
			echo "Cancelling Installation..."
			exit
			;;
	esac
done

clear

# ----------------------------- Installation ----------------------------- 

timedatectl set-ntp true

mount $ROOTDEV /mnt
mount --mkdir $BOOTDEV /mnt/boot

printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
sed -i "s/#ParallelDownloads/ParallelDownloads/g" /etc/pacman.conf
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/g" /etc/makepkg.conf

pacman -Syy --noconfirm archlinux-keyring

BASE_PKGS=(
	"base"
	"linux"
	"linux-firmware"
	"linux-headers"
	"base-devel"
)

BOOT_PKGS=(
	"grub"
	"mtools"
	"os-prober"
	"efibootmgr"
	"dosfstools"
)

NETWORK_PKGS=(
	"iwd"
	"wpa_supplicant"
	"wireless_tools"
	"networkmanager"
)

BLUETOOTH_PKGS=(
	"bluez"
	"bluez-utils"
)

AUDIO_PKGS=(
	"pulseaudio"
	"pulsemixer"
	"pulseaudio-bluetooth"
	"alsa-firmware"
	"alsa-plugins"
	"alsa-utils"
	"sof-firmware"
)

CUSTOM_PKGS=(
	"xorg-xinit" # X System
	"xorg-xrandr" # X System
	"xorg-server" # X System
 	"xorg-xinput" # X System
	"xorg-xsetroot" # X System
	"libx11" # X System
	"libxft" # X System
	"libxinerama" # X System
	"freetype2" # Fonts
	"fontconfig" # Fonts
	"lightdm" # Display manager
	"lightdm-webkit2-greeter" # LightDM theme
	"brightnessctl" # Manage brightness
	"zsh" # Z Shell
	"cifs-utils" # Mount Common Internet File System
	"ntfs-3g" # Mount New Technology File System
	"flameshot" # Screenshot tool
 	"okular" # PDF Reader
	"neovim" # Text Editor
	"nodejs" # TSServer dependency
	"npm" # TSServer dependency
	"typescript-language-server" # TS/JS Server
	"rust-analyzer" # Rust Language Server
	"clang" # C-Family Language Server
	"pyright" # Python Language Server
	"lua-language-server" # Lua Language Server
 	"powertop" # Power consumption monitor
	"htop" # System monitor
	"exa" # ls alternative
	"bat" # cat alternative
	"wget" # Retrieve content
	"git" # Git
	"man" # Manual
	"github-cli" # Github CLI
	"dunst" # Notifications
	"zip" # Zip files
	"unzip" # Unzip files
	"feh" # Image tool
 	"jq" # JSON Processor
  	"neofetch" # System info
	"python-pip" # Install Python modules/packages
	"imagemagick" # Pywal dependency
	"python-pywal" # Pywal
	"xclip" # Copy to clipboard
	"ttf-joypixels" # Emoji font
	"libxcursor" # Cursor dependency
	"libpng" # Cursor dependency
)

PKGS=(${BASE_PKGS[@]} ${BOOT_PKGS[@]} ${NETWORK_PKGS[@]} ${BLUETOOTH_PKGS[@]} ${AUDIO_PKGS[@]} ${GPU_PKGS[@]} ${CUSTOM_PKGS[@]} $MICROCODE_PKG)

until pacstrap /mnt "${PKGS[@]}"; do
	echo -e "\e[4;95mRetry?\e[0m"
	
	select retry in Yes No; do
		case $retry in
			Yes) break;;
			No) break 2;;
		esac
	done
done

genfstab -U /mnt >> /mnt/etc/fstab

cat << EOF > /mnt/installation.sh
# Pacman configuration
printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
sed -i "s/#ParallelDownloads/ParallelDownloads/g" /etc/pacman.conf
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/g" /etc/makepkg.conf

pacman -Syy --noconfirm archlinux-keyring

# Time zone
ln -sf /usr/share/zoneinfo/$SELECTED_REGION/$SELECTED_CITY /etc/localtime
hwclock --systohc

# Localization
sed -i "s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Network Configuration
echo $HOSTNAME > /etc/hostname
echo "127.0.0.1  localhost" >> /etc/hosts
echo "::1        localhost" >> /etc/hosts
echo "127.0.1.1  $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Install GRUB
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --efi-directory=/boot --recheck

# Add user
useradd -m $USERNAME
usermod -aG wheel,audio,video $USERNAME

# Set passwords
printf "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd
printf "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USERNAME

# Configure sudo
echo "$USERNAME  ALL=(ALL:ALL) NOPASSWD: ALL" | EDITOR="tee -a" visudo

# Enable services
systemctl enable NetworkManager.service
systemctl enable bluetooth.service

rm \$0

exit
EOF

arch-chroot /mnt /bin/bash installation.sh

# ----------------------------- Customization ----------------------------- 

cat << EOF > /mnt/home/$USERNAME/customization.sh
AUR_PKGS=(
	"nerd-fonts-jetbrains-mono" # JetBrains Mono Nerd Font
	"ttf-poppins" # Poppins font
	"picom-ftlabs-git" # Picom compositor
	"brave-bin" # Brave Browser
  	"auto-cpufreq" # Power Management
)

# Tool to switch between GPU modes on Optimus systems
if [ $GPU_BRAND == "NVIDIA" ]; then AUR_PKGS+=("envycontrol"); fi

# Install AUR packages
for aurpkg in "\${AUR_PKGS[@]}"; do
	git clone https://aur.archlinux.org/\$aurpkg.git
    sudo chmod 777 \$aurpkg
	cd \$aurpkg
	makepkg -si --noconfirm
	cd ..
	sudo rm -rf \$aurpkg
done

# Configure power management tools
sudo auto-cpufreq --install
if [ $GPU_BRAND == "NVIDIA" ]; then sudo envycontrol -s hybrid --rtd3 3; fi

# Create dwm desktop entry
sudo mkdir -p /usr/share/xsessions
sudo chmod 777 /usr/share/xsessions
sudo printf "[Desktop Entry]\nEncoding=UTF-8\nName=dwm\nExec=default" > /usr/share/xsessions/dwm.desktop

# Install LightDM Aether theme
git clone https://github.com/NoiSek/Aether.git
sudo mv Aether /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether
sudo sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = lightdm-webkit-theme-aether #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
sudo sed -i "s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-webkit2-greeter/g" /etc/lightdm/lightdm.conf
sudo sed -i "s/#user-session=default/user-session=dwm/g" /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm.service

# Set account icon
sudo cp /usr/share/lightdm-webkit/themes/lightdm-webkit-theme-aether/src/img/default-user.png \$HOME/.face
sudo chmod 644 \$HOME/.face

# Change default shell
sudo chsh -s /bin/zsh \$USER

# Make config folder and prayer time history folder
mkdir -p \$HOME/.config
mkdir \$HOME/.config/prayerhistory

# Install and configure dwm
git clone https://github.com/BetaLost/dwm.git \$HOME/.config/dwm
cd \$HOME/.config/dwm

# Install and configure st
git clone https://github.com/BetaLost/st.git \$HOME/.config/st
cd \$HOME/.config/st

# Install and configure dmenu
git clone https://github.com/BetaLost/dmenu.git \$HOME/.config/dmenu
cd \$HOME/.config/dmenu

# Download dotfiles
cd \$HOME
git clone https://github.com/BetaLost/dotfiles-x11.git dotfiles

# Configure dwm scripts
mv \$HOME/dotfiles/.xsession \$HOME/
mv \$HOME/dotfiles/scripts \$HOME/.config/

sed -i "s/_BACKLIGHT_/$BACKLIGHT/" \$HOME/.config/dwmbar.sh
sed -i "s/_BACKLIGHT_/$BACKLIGHT/" \$HOME/.config/utilities.sh

sed -i "s/_NET_/$NET_INTERFACE/" \$HOME/.config/dwmbar.sh

sed -i "s/_COUNTRY_/$PRAYER_COUNTRY/" \$HOME/.config/prayer.sh
sed -i "s/_CITY_/$PRAYER_CITY/" \$HOME/.config/prayer.sh

sudo chmod 777 \$HOME/.xsession
for script in \$HOME/.config/scripts/*.sh; do sudo chmod 777 $script; done

# Configure ZSH
git clone https://github.com/zsh-users/zsh-autosuggestions.git \$HOME/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \$HOME/.zsh/zsh-syntax-highlighting
mv \$HOME/dotfiles/.zshrc \$HOME/

# Configure BASH
mv \$HOME/dotfiles/.bashrc \$HOME/

# Configure neovim
curl -fLo \$HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mv \$HOME/dotfiles/nvim \$HOME/.config/
nvim -c "PlugInstall | q | q"
sed -i "s/background = '#282923'/background = '#1a1a18'/g" \$HOME/.local/share/nvim/plugged/ofirkai.nvim/lua/ofirkai/design.lua

# Configure dunst
sudo mv \$HOME/dotfiles/dunst \$HOME/.config/

# Configure Picom 
sudo mv \$HOME/dotfiles/picom \$HOME/.config/

# Configure Neofetch 
sudo mv \$HOME/dotfiles/neofetch \$HOME/.config/

# Wallpapers
sudo mv \$HOME/dotfiles/wallpapers \$HOME/.config/

# Install Arabic font
wget https://github.com/BetaLost/auto-arch-x11/raw/main/khebrat-musamim.zip
unzip khebrat-musamim.zip
rm khebrat-musamim.zip
sudo mkdir -p /usr/share/fonts/TTF
sudo mv "18 Khebrat Musamim Regular.ttf" /usr/share/fonts/TTF/

sudo mv \$HOME/dotfiles/fonts.conf /etc/fonts/
sudo cp /etc/fonts/fonts.conf /etc/fonts/local.conf

# Install GRUB theme
wget https://github.com/BetaLost/auto-arch-x11/raw/main/arch.tar
sudo mkdir -p /boot/grub/themes
sudo mkdir /boot/grub/themes/arch
sudo mv arch.tar /boot/grub/themes/arch/
sudo tar xf /boot/grub/themes/arch/arch.tar -C /boot/grub/themes/arch/
sudo rm /boot/grub/themes/arch/arch.tar
sudo sed -i "s/GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080/g" /etc/default/grub
sudo sed -i "s/#GRUB_THEME=.*/GRUB_THEME=\"\/boot\/grub\/themes\/arch\/theme.txt\"/g" /etc/default/grub
sudo sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g" /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install cursor
wget https://github.com/BetaLost/auto-arch-x11/raw/main/macOSBigSur.tar.gz
tar -xf macOSBigSur.tar.gz
rm macOSBigSur.tar.gz
sudo mv macOSBigSur /usr/share/icons/

sudo sed -i "s/Inherits=Adwaita/Inherits=macOSBigSur/g" /usr/share/icons/default/index.theme

rm -rf \$HOME/dotfiles \$0

exit
EOF

arch-chroot /mnt /bin/su -c "cd; bash customization.sh" $USERNAME -

# ----------------------------- Complete ----------------------------- 

echo -e "\e[4;34mArch Linux\e[0m has been installed \e[4;32msuccessfully\e[0m on this machine."
