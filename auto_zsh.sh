#!/bin/bash

ORIGINAL_DIR=$(pwd)

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

echo "🔹 Applying settings to existing users..."
for user in $(ls /home); do
    if [ ! -d "/home/$user/.oh-my-zsh" ]; then
        sudo cp -r /etc/skel/.oh-my-zsh "/home/$user/"
        sudo chown -R $user:$user "/home/$user/.oh-my-zsh"
    fi
    sudo cp /etc/skel/.zshrc "/home/$user/.zshrc"
    sudo cp /etc/skel/.p10k.zsh "/home/$user/.p10k.zsh"
    sudo chown $user:$user "/home/$user/.zshrc" "/home/$user/.p10k.zsh"
done

echo "🔹 Applying Powerlevel10k settings for current user..."
cp ".p10k.zsh" "$HOME/.p10k.zsh"

echo "🔹 Configuring .zshrc for current user..."
cat > "$HOME/.zshrc" <<EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source \$ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "🔹 Changing default shell to Zsh..."
chsh -s "$(which zsh)"

cd "$ORIGINAL_DIR"
echo "🔹 Cleaning up..."
rm -rf "$ORIGINAL_DIR/auto_zsh-multiuser"

echo "✅ Zsh setup complete!"
echo "🚀 Please restart your terminal and make sure to use a Nerd Font!"
