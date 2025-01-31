#!/bin/bash

echo "🔹 Installing zsh and required packages..."
sudo apt update && sudo apt install -y zsh git wget unzip fonts-powerline

echo "🔹 Setting Zsh as the default shell for new users..."
sudo sed -i 's|SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

echo "🔹 Installing Oh-My-Zsh for default users..."
if [ ! -d "/etc/skel/.oh-my-zsh" ]; then
    sudo git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /etc/skel/.oh-my-zsh
fi

echo "🔹 Installing Powerlevel10k theme..."
if [ ! -d "/etc/skel/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /etc/skel/.oh-my-zsh/custom/themes/powerlevel10k
fi

echo "🔹 Installing Zsh plugins..."
if [ ! -d "/etc/skel/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions /etc/skel/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi
if [ ! -d "/etc/skel/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting /etc/skel/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

echo "🔹 Configuring default .zshrc for new users..."
sudo tee /etc/skel/.zshrc <<EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source \$ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "🔹 Copying existing Powerlevel10k configuration..."
USER_HOME=$(eval echo ~$(logname))

if [ -f "$USER_HOME/.p10k.zsh" ]; then
    sudo cp "$USER_HOME/.p10k.zsh" /etc/skel/.p10k.zsh
    sudo chmod 644 /etc/skel/.p10k.zsh
else
    echo "⚠️ WARNING: $USER_HOME/.p10k.zsh file not found! Creating a default one."
    sudo tee /etc/skel/.p10k.zsh >/dev/null <<EOF
# Powerlevel10k Configuration
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
EOF
fi

echo "✅ Setup complete! New users will have Zsh + Oh My Zsh + Powerlevel10k automatically applied."
