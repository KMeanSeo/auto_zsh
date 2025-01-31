P10K_URL="https://raw.githubusercontent.com/사용자명/레포지토리명/main/.p10k.zsh"

echo "🔹 Installing zsh and required packages..."
sudo apt update && sudo apt install -y zsh git curl wget

echo "🔹 Installing Oh-My-Zsh..."
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

echo "🔹 Downloading .p10k.zsh from GitHub..."
wget -O /etc/skel/.p10k.zsh "$P10K_URL" || curl -o /etc/skel/.p10k.zsh "$P10K_URL"

echo "🔹 Configuring Zsh for existing users..."
for user in $(ls /home); do
    HOME_DIR="/home/$user"

    if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
        sudo cp -r /etc/skel/.oh-my-zsh "$HOME_DIR/"
        sudo chown -R $user:$user "$HOME_DIR/.oh-my-zsh"
    fi

    
    sudo cp /etc/skel/.zshrc "$HOME_DIR/.zshrc"
    sudo chown $user:$user "$HOME_DIR/.zshrc"

    
    if [ ! -f "$HOME_DIR/.p10k.zsh" ]; then
        sudo cp /etc/skel/.p10k.zsh "$HOME_DIR/.p10k.zsh"
        sudo chown $user:$user "$HOME_DIR/.p10k.zsh"
    fi
done

echo "🔹 Setting Zsh as the default shell..."
sudo sed -i 's|SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

for user in $(ls /home); do
    sudo chsh -s /bin/zsh $user
done

echo "✅ Zsh setup complete! New users will have Zsh as the default shell with Powerlevel10k from GitHub."
