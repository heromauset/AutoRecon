#!/bin/bash

# Cores
verde="\033[0;32m"
vermelho="\033[0;31m"
neutro="\033[0m"

clear
echo -e "${verde}"
echo "====================================="
echo "      AutoRecon - Instalador Fork    "
echo "        Re-Script por Ioti =)        "
echo "====================================="
echo -e "${neutro}"

# Detecta gerenciador de pacotes
detect_package_manager() {
    if command -v apt &> /dev/null; then
        PM="apt"
    elif command -v dnf &> /dev/null; then
        PM="dnf"
    elif command -v pacman &> /dev/null; then
        PM="pacman"
    else
        echo -e "${vermelho}[ERRO] Gerenciador de pacotes não suportado.${neutro}"
        exit 1
    fi
}

# Instala pacote se necessário
ensure_installed() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${verde}[INFO] Instalando dependência: $1...${neutro}"
        case "$PM" in
            apt) sudo apt update && sudo apt install -y "$1" ;;
            dnf) sudo dnf install -y "$1" ;;
            pacman) sudo pacman -Sy --noconfirm "$1" ;;
        esac
    else
        echo -e "${verde}[OK] $1 já está instalado.${neutro}"
    fi
}

# Checa e instala python3-venv
check_venv() {
    if ! python3 -m venv --help &> /dev/null; then
        echo -e "${verde}[INFO] python3-venv não está disponível. Instalando...${neutro}"
        
        # Instala python3-venv para a versão do python3 atual
        sudo apt install -y python3-venv || {
            echo -e "${vermelho}[ERRO] Falha ao instalar python3-venv.${neutro}"
            exit 1
        }

        # Verifica se a instalação foi bem-sucedida
        if ! python3 -m venv --help &> /dev/null; then
            echo -e "${vermelho}[ERRO] python3-venv ainda não disponível após instalação.${neutro}"
            exit 1
        fi
    fi
}

# Detecta o gerenciador de pacotes
detect_package_manager

echo -e "${verde}[INFO] Verificando dependências básicas...${neutro}"
ensure_installed git
ensure_installed python3
ensure_installed python3-pip
check_venv

# Define pasta destino
DEST_DIR="$HOME/AutoRecon"

if [ -d "$DEST_DIR" ]; then
    echo -e "${verde}[INFO] Diretório $DEST_DIR já existe. Pulando clonagem.${neutro}"
else
    echo -e "${verde}[INFO] Clonando o AutoRecon...${neutro}"
    git clone https://github.com/LuizWT/AutoRecon.git "$DEST_DIR" || {
        echo -e "${vermelho}[ERRO] Falha ao clonar o repositório.${neutro}"
        exit 1
    }
fi

cd "$DEST_DIR" || {
    echo -e "${vermelho}[ERRO] Não foi possível acessar $DEST_DIR.${neutro}"
    exit 1
}

echo -e "${verde}[INFO] Criando ambiente virtual em venv/...${neutro}"
python3 -m venv venv || {
    echo -e "${vermelho}[ERRO] Falha ao criar venv.${neutro}"
    exit 1
}

source venv/bin/activate || {
    echo -e "${vermelho}[ERRO] Falha ao ativar o ambiente virtual.${neutro}"
    exit 1
}

echo -e "${verde}[INFO] Instalando dependências do requirements.txt...${neutro}"
pip3 install -r requirements.txt || {
    echo -e "${vermelho}[ERRO] Falha ao instalar dependências.${neutro}"
    deactivate
    exit 1
}

echo -e "${verde}[INFO] Executando autorecon.py...${neutro}"
sudo venv/bin/python3 autorecon.py

echo -e "${verde}[SUCESSO] Instalação e execução finalizadas!${neutro}"
