#!/bin/bash

# 🔹 현재 작업 디렉토리 저장 (스크립트 실행 후 원래 위치로 돌아가기 위함)
ORIGINAL_DIR=$(pwd)

echo "🔹 Installing zsh and required packages..."
sudo apt update && sudo apt install -y zsh git wget unzip fonts-powerline

# 🔹 1. 기본 쉘을 `zsh`로 설정 (신규 사용자 자동 적용)
echo "🔹 Setting Zsh as the default shell for new users..."
sudo sed -i 's|SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# 🔹 2. Oh-My-Zsh 설치 (신규 사용자 & 기존 사용자용)
echo "🔹 Installing Oh-My-Zsh for default users..."
if [ ! -d "/etc/skel/.oh-my-zsh" ]; then
    sudo git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /etc/skel/.oh-my-zsh
fi

# 🔹 3. Powerlevel10k 테마 설치
echo "🔹 Installing Powerlevel10k theme..."
if [ ! -d "/etc/skel/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /etc/skel/.oh-my-zsh/custom/themes/powerlevel10k
fi

# 🔹 4. Zsh 플러그인 설치
echo "🔹 Installing Zsh plugins..."
if [ ! -d "/etc/skel/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions /etc/skel/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi
if [ ! -d "/etc/skel/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting /etc/skel/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

# 🔹 5. 기본 `.zshrc` 설정 추가 (신규 사용자 적용)
echo "🔹 Configuring default .zshrc for new users..."
sudo tee /etc/skel/.zshrc <<EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source \$ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# 🔹 6. GitHub에서 `.p10k.zsh` 설정 다운로드 (최신 설정 유지)
P10K_URL="https://raw.githubusercontent.com/사용자명/zsh-setup/main/.p10k.zsh"
echo "🔹 Downloading default Powerlevel10k settings..."
wget -O /etc/skel/.p10k.zsh "$P10K_URL" || curl -o /etc/skel/.p10k.zsh "$P10K_URL"

# 🔹 7. 기존 사용자에게도 동일한 설정 적용
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

# 🔹 8. `.p10k.zsh` 적용 (현재 사용자)
echo "🔹 Applying Powerlevel10k settings for current user..."
cp ".p10k.zsh" "$HOME/.p10k.zsh"

# 🔹 9. `.zshrc` 설정 적용 (현재 사용자)
echo "🔹 Configuring .zshrc for current user..."
cat > "$HOME/.zshrc" <<EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source \$ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# 🔹 10. 기본 쉘을 `zsh`로 변경 (현재 사용자)
echo "🔹 Changing default shell to Zsh..."
chsh -s "$(which zsh)"

# 🔹 11. 설치 완료 후 원래 디렉토리로 돌아가서 폴더 삭제
cd "$ORIGINAL_DIR"
echo "🔹 Cleaning up..."
rm -rf "$ORIGINAL_DIR/auto_zsh"

# 🔹 12. 설치 완료 메시지 출력
echo "✅ Zsh setup complete!"
echo "🚀 Please restart your terminal and make sure to use a Nerd Font!"
