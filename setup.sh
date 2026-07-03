#!/bin/bash
# ============================================
# 🚀 VPS Auto Setup - One Click Install
# By: KStarID
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════╗"
echo "║   🚀 VPS Auto Setup - One Click Install   ║"
echo "║   By: KStarID                              ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

# Menu
echo -e "${YELLOW}Pilih yang mau di-install:${NC}"
echo ""
echo -e "  ${GREEN}1)${NC} Install SEMUA (Update + Docker + Go + Node.js + Python + Screen + Git)"
echo -e "  ${GREEN}2)${NC} Update Sistem VPS"
echo -e "  ${GREEN}3)${NC} Install Docker"
echo -e "  ${GREEN}4)${NC} Install Go (Golang)"
echo -e "  ${GREEN}5)${NC} Install Node.js (via NVM)"
echo -e "  ${GREEN}6)${NC} Install Python3"
echo -e "  ${GREEN}7)${NC} Install Screen"
echo -e "  ${GREEN}8)${NC} Install Git"
echo -e "  ${GREEN}9)${NC} Install Docker Compose"
echo -e "  ${GREEN}0)${NC} Cek Spesifikasi VPS"
echo ""
read -p "Pilihan [0-9]: " choice

install_update() {
    echo -e "\n${BLUE}[1/2]${NC} Updating sistem..."
    sudo apt update && sudo apt upgrade -y
    echo -e "${BLUE}[2/2]${NC} Installing dependencies..."
    sudo apt install -y curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc jq chrony liblz4-tool
    echo -e "${GREEN}✅ Sistem updated!${NC}"
}

install_docker() {
    if command -v docker &> /dev/null; then
        echo -e "${YELLOW}⚠️  Docker sudah terinstall: $(docker --version)${NC}"
        return
    fi
    echo -e "\n${BLUE}[*]${NC} Installing Docker..."
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 2>/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo apt-mark hold docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo -e "${GREEN}✅ Docker installed: $(docker --version)${NC}"
}

install_docker_compose() {
    if docker compose version &> /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Docker Compose sudah terinstall: $(docker compose version)${NC}"
        return
    fi
    echo -e "\n${BLUE}[*]${NC} Installing Docker Compose plugin..."
    sudo apt-get install -y docker-compose-plugin
    echo -e "${GREEN}✅ Docker Compose installed: $(docker compose version)${NC}"
}

install_go() {
    if command -v go &> /dev/null; then
        echo -e "${YELLOW}⚠️  Go sudah terinstall: $(go version)${NC}"
        return
    fi
    echo -e "\n${BLUE}[*]${NC} Installing Go (latest)..."
    LATEST_GO=$(curl -s https://go.dev/VERSION?m=text | head -1)
    wget -q "https://go.dev/dl/${LATEST_GO}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "${LATEST_GO}.linux-amd64.tar.gz"
    rm -f "${LATEST_GO}.linux-amd64.tar.gz"
    if ! grep -q '/usr/local/go/bin' ~/.bash_profile 2>/dev/null; then
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
    fi
    source ~/.bash_profile 2>/dev/null || true
    echo -e "${GREEN}✅ Go installed: $(/usr/local/go/bin/go version)${NC}"
}

install_nodejs() {
    if command -v node &> /dev/null; then
        echo -e "${YELLOW}⚠️  Node.js sudah terinstall: $(node -v)${NC}"
        return
    fi
    echo -e "\n${BLUE}[*]${NC} Installing Node.js via NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm install node
    nvm use node
    echo -e "${GREEN}✅ Node.js installed: $(node -v)${NC}"
}

install_python() {
    if command -v python3 &> /dev/null; then
        echo -e "${YELLOW}⚠️  Python sudah terinstall: $(python3 --version)${NC}"
        return
    fi
    echo -e "\n${BLUE}[*]${NC} Installing Python3..."
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip
    echo -e "${GREEN}✅ Python installed: $(python3 --version)${NC}"
}

install_screen() {
    if command -v screen &> /dev/null; then
        echo -e "${YELLOW}⚠️  Screen sudah terinstall${NC}"
        return
    fi
    echo -e "\n${BLUE}[*]${NC} Installing Screen..."
    sudo apt install -y screen
    echo -e "${GREEN}✅ Screen installed!${NC}"
}

install_git() {
    if command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠️  Git sudah terinstall: $(git --version)${NC}"
        return
    fi
    echo -e "\n${BLUE}[*]${NC} Installing Git..."
    sudo apt install -y git
    echo -e "${GREEN}✅ Git installed: $(git --version)${NC}"
}

cek_vps() {
    echo -e "\n${CYAN}═══════ Spesifikasi VPS ═══════${NC}"
    echo -e "${YELLOW}OS:${NC}        $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${YELLOW}Kernel:${NC}    $(uname -r)"
    echo -e "${YELLOW}CPU:${NC}       $(nproc) vCPU - $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    echo -e "${YELLOW}RAM:${NC}       $(free -h | awk '/Mem:/ {print $2}') total, $(free -h | awk '/Mem:/ {print $3}') used"
    echo -e "${YELLOW}Disk:${NC}      $(df -h / | awk 'NR==2 {print $2}') total, $(df -h / | awk 'NR==2 {print $3}') used ($(df -h / | awk 'NR==2 {print $5}'))"
    echo -e "${YELLOW}IP:${NC}        $(curl -s ifconfig.me 2>/dev/null || echo 'N/A')"
    echo -e "${YELLOW}Uptime:${NC}    $(uptime -p)"
    echo ""
    echo -e "${CYAN}═══════ Software Terinstall ═══════${NC}"
    command -v docker &>/dev/null && echo -e "${GREEN}✅ Docker:${NC}  $(docker --version 2>/dev/null)" || echo -e "${RED}❌ Docker:${NC}  not installed"
    command -v go &>/dev/null && echo -e "${GREEN}✅ Go:${NC}      $(go version 2>/dev/null)" || echo -e "${RED}❌ Go:${NC}      not installed"
    command -v node &>/dev/null && echo -e "${GREEN}✅ Node:${NC}    $(node -v 2>/dev/null)" || echo -e "${RED}❌ Node:${NC}    not installed"
    command -v python3 &>/dev/null && echo -e "${GREEN}✅ Python:${NC}  $(python3 --version 2>/dev/null)" || echo -e "${RED}❌ Python:${NC}  not installed"
    command -v git &>/dev/null && echo -e "${GREEN}✅ Git:${NC}     $(git --version 2>/dev/null)" || echo -e "${RED}❌ Git:${NC}     not installed"
    command -v screen &>/dev/null && echo -e "${GREEN}✅ Screen:${NC}  installed" || echo -e "${RED}❌ Screen:${NC}  not installed"
    docker compose version &>/dev/null 2>&1 && echo -e "${GREEN}✅ Compose:${NC} $(docker compose version 2>/dev/null)" || echo -e "${RED}❌ Compose:${NC} not installed"
    echo -e "${CYAN}════════════════════════════════════${NC}"
}

case $choice in
    1)
        echo -e "\n${CYAN}🚀 Installing SEMUA...${NC}\n"
        install_update
        install_git
        install_screen
        install_docker
        install_docker_compose
        install_go
        install_nodejs
        install_python
        echo ""
        cek_vps
        echo -e "\n${GREEN}🎉 SEMUA SELESAI! Reboot recommended: sudo reboot${NC}"
        ;;
    2) install_update ;;
    3) install_docker ;;
    4) install_go ;;
    5) install_nodejs ;;
    6) install_python ;;
    7) install_screen ;;
    8) install_git ;;
    9) install_docker_compose ;;
    0) cek_vps ;;
    *)
        echo -e "${RED}❌ Pilihan tidak valid!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done! 🎉${NC}"
