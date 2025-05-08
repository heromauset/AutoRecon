#!/bin/bash

# ============================================
# AutoRecon Installer (Fork Installer Script)
# Repositório original: https://github.com/LuizWT/AutoRecon
# Este script facilita a instalação em distros variadas e de forma automatizada
# Re-Script por Ioti =)
# ============================================
set -e

# Cores
verde="\e[32m"
vermelho="\e[31m"
neutro="\e[0m"

# Função para detectar o gerenciador de pacotes
detect_package_manager() {
    if command -v apt &> /dev/null; then
        PM="apt"
    elif command -v dnf &> /dev/null; then
        PM="dnf"
    elif command -v yum &> /dev/null; then
        PM="yum"
    elif command -v pacman &> /dev/null; then
        PM="pacman"
    else
        echo -e "${vermelho}[ERRO] Gerenciador de pacotes não suportado.${neutro}"
        exit 1
    fi
}

# Instala um pacote se não existir
ensure_installed() {
    local pkg=$1
    if ! command -v "$pkg" &> /dev/null; then
        echo -e "${verde}[INFO] Instalando $pkg...${neutro}"
        case $PM in
            apt) apt update -y && apt install -y "$pkg" ;;
            dnf) dnf install -y "$pkg" ;;
            yum) yum install -y "$pkg" ;;
            pacman) pacman -Sy --noconfirm "$pkg" ;;
        esac
    else
        echo -e "${verde}[OK] $pkg já está instalado.${neutro}"
    fi
}

# Verifica se é root
if [ "$EUID" -ne 0 ]; then
    echo -e "${vermelho}[ERRO] Por favor, execute como root.${neutro}"
    exit 1
fi

clear
echo -e "${verde}"
echo "====================================="
echo "      AutoRecon - Instalador Fork    "
echo "     Instalação Simplificada v1.0    "
echo "====================================="
echo -e "${neutro}"


# Detecta gerenciador de pacotes
detect_package_manager

# Instala dependências
ensure_installed git
ensure_installed python3
ensure_installed pip3

# Instala python3-venv (com nomes diferentes se necessário)
if ! python3 -m venv --help &> /dev/null; then
    echo -e "${verde}[INFO] Instalando módulo venv...${neutro}"
    case $PM in
        apt) apt install -y python3-venv ;;
        dnf|yum) $PM install -y python3-virtualenv ;;
        pacman) pacman -Sy --noconfirm python-virtualenv ;;
    esac
fi

# Diretório destino
DEST_DIR="$HOME/AutoRecon"

# Clonagem
if [ -d "$DEST_DIR" ]; then
    echo -e "${verde}[INFO] O diretório $DEST_DIR já existe.${neutro}"
else
    echo -e "${verde}[INFO] Clonando AutoRecon...${neutro}"
    git clone https://github.com/LuizWT/AutoRecon.git "$DEST_DIR"
fi

cd "$DEST_DIR"

# Cria VENV
echo -e "${verde}[INFO] Criando ambiente virtual...${neutro}"
python3 -m venv venv

# Ativa VENV
source venv/bin/activate

# Instala dependências
echo -e "${verde}[INFO] Instalando dependências do requirements.txt...${neutro}"
pip3 install -r requirements.txt

# Executa AutoRecon
echo -e "${verde}[INFO] Executando AutoRecon...${neutro}"
venv/bin/python3 autorecon.py

echo -e "${verde}[OK] Tudo pronto! AutoRecon está rodando com sucesso.${neutro}"

