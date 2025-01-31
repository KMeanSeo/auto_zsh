ORIGINAL_DIR=$(pwd)

echo "🔹 Installing zsh and required packages..."
sudo apt update && sudo apt install -y zsh git wget unzip fonts-powerline

echo "🔹 Installing Oh-My-Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

echo "🔹 Installing Powerlevel10k theme..."
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

echo "🔹 Installing Zsh plugins..."
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

echo "🔹 Applying Powerlevel10k settings..."
cp ".p10k.zsh" "$HOME/.p10k.zsh"

echo "🔹 Configuring .zshrc..."
cat > "$HOME/.zshrc" <<EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source \$ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

echo "🔹 Changing default shell to Zsh..."
chsh -s "$(which zsh)"

cd "$ORIGINAL_DIR/.." || exit
echo "🔹 Cleaning up..."
rm -rf "$ORIGINAL_DIR"

echo "✅ Zsh setup complete!"
echo "🚀 Please restart your terminal and make sure to use a Nerd Font!"
