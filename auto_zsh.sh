#!/bin/bash

# 🔹 현재 작업 디렉토리 저장
ORIGINAL_DIR=$(pwd)

echo "🔹 Installing required packages..."
sudo apt update && sudo apt install -y zsh git wget unzip fonts-powerline curl

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

# 🔹 5. 기본 `.zshrc` 설정 추가
echo "🔹 Configuring default .zshrc for new users..."
sudo tee /etc/skel/.zshrc <<EOF
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source \$ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF


# 🔹 7. Anaconda 설치 (모든 사용자 공용)
ANACONDA_DIR="/opt/anaconda3"
if [ ! -d "$ANACONDA_DIR" ]; then
    echo "🔹 Downloading & Installing Anaconda..."
    wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh -O /tmp/anaconda.sh
    sudo bash /tmp/anaconda.sh -b -p $ANACONDA_DIR
    rm /tmp/anaconda.sh
fi

# 🔹 8. Shared Conda 환경 설정
echo "🔹 Configuring shared Anaconda environment..."
SHARED_ENV="/opt/anaconda3/envs/shared_env"

# 환경이 없으면 생성
if [ ! -d "$SHARED_ENV" ]; then
    sudo $ANACONDA_DIR/bin/conda create --prefix $SHARED_ENV python=3.9 -y
fi

# 🔹 9. 모든 사용자가 기본적으로 공유된 Conda 환경을 사용하도록 설정
echo "🔹 Applying Conda settings for new users..."
sudo tee /etc/skel/.zshrc -a <<EOF

# Anaconda 설정
export PATH=$ANACONDA_DIR/bin:\$PATH
export CONDA_ENVS_PATH=$ANACONDA_DIR/envs
source $ANACONDA_DIR/bin/activate $SHARED_ENV

# Conda 환경 변경 방지
conda deactivate() { echo "Env change disabled"; }
EOF

# 🔹 10. 기존 사용자에게도 동일한 설정 적용
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

# 🔹 11. `.p10k.zsh` 적용 (현재 사용자)
echo "🔹 Applying Powerlevel10k settings for current user..."
cp ".p10k.zsh" "$HOME/.p10k.zsh"

# 🔹 12. `.zshrc` 설정 적용 (현재 사용자)
echo "🔹 Configuring .zshrc for current user..."
cat >> "$HOME/.zshrc" <<EOF

# Anaconda 설정
export PATH=$ANACONDA_DIR/bin:\$PATH
export CONDA_ENVS_PATH=$ANACONDA_DIR/envs
source $ANACONDA_DIR/bin/activate $SHARED_ENV

# Conda 환경 변경 방지
conda deactivate() { echo "Env change disabled"; }
EOF

# 🔹 13. 기본 쉘을 `zsh`로 변경 (현재 사용자)
echo "🔹 Changing default shell to Zsh..."
chsh -s "$(which zsh)"

# 🔹 14. 설치 완료 후 원래 디렉토리로 돌아가서 폴더 삭제
cd "$ORIGINAL_DIR"
echo "🔹 Cleaning up..."
rm -rf "$ORIGINAL_DIR/auto_zsh-anaconda"

# 🔹 15. 설치 완료 메시지 출력
echo "✅ Zsh + Anaconda + Shared Env setup complete!"
echo "🚀 Please restart your terminal and make sure to use a Nerd Font!"

zsh