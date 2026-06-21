#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# IP DECODER – Multi-distro Linux, foco em segurança e usabilidade
# -----------------------------------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

# Cores para estilização
VERDE='\033[1;32m'
AZUL='\033[1;34m'
VERMELHO='\033[1;31m'
AMARELO='\033[1;33m'
CIANO='\033[1;36m'
BRANCO='\033[1;37m'
RESET='\033[0m'

# -----------------------------------------------------------------------------
# Funções auxiliares
# -----------------------------------------------------------------------------

# Pausa controlada pelo usuário
pausa() {
    echo
    read -r -p "Pressione Enter para continuar... "
}

# Executa um comando com privilégios (sudo se não for root)
run_privileged() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Reinicia um serviço usando o sistema de init disponível
service_restart() {
    local servico="$1"
    if command -v systemctl &>/dev/null; then
        run_privileged systemctl restart "$servico"
    elif command -v service &>/dev/null; then
        run_privileged service "$servico" restart
    elif [[ -x "/etc/init.d/$servico" ]]; then
        run_privileged "/etc/init.d/$servico" restart
    else
        echo "Nenhum gerenciador de serviços compatível encontrado."
        return 1
    fi
}

# Exibe o banner IP DECODER
banner() {
    clear
    echo -e "${AZUL}"
    figlet IP DECODER
    echo -e "${RESET}"
}

# -----------------------------------------------------------------------------
# Verificação e instalação de dependências (lógica original preservada)
# -----------------------------------------------------------------------------

comandos_necessarios=("figlet" "hping3" "wget" "host" "ss" "service" "ps" "grep" "ping" "awk" "cut" "rm")

echo "Verificando dependências..."
faltando=0

for cmd in "${comandos_necessarios[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Dependência '${cmd}' ausente."
        faltando=1
    fi
done

if [[ $faltando -eq 0 ]]; then
    echo "Todas as dependências já estão instaladas."
    pausa
    banner
else
    echo
    read -r -p "Faltam programas. Deseja instalar tudo de uma vez? (s/N) " resposta_instalacao
    if [[ ! "$resposta_instalacao" =~ ^[Ss]$ ]]; then
        echo "Instalação cancelada. Encerrando."
        exit 1
    fi

    # Detecta o gerenciador de pacotes e monta a lista correta (agora com arrays)
    if command -v apt &>/dev/null; then
        pacotes=(figlet hping3 wget dnsutils iproute2 sysvinit-utils procps grep iputils-ping gawk coreutils)
        echo "Instalando via APT..."
        run_privileged apt update && run_privileged apt install -y "${pacotes[@]}"
    elif command -v pacman &>/dev/null; then
        pacotes=(figlet hping3 wget bind-tools iproute2 systemd-sysvcompat procps-ng grep iputils gawk coreutils)
        echo "Instalando via Pacman..."
        run_privileged pacman -S --noconfirm "${pacotes[@]}"
    elif command -v dnf &>/dev/null; then
        pacotes=(figlet hping3 wget bind-utils iproute initscripts procps-ng grep iputils gawk coreutils)
        echo "Instalando via DNF..."
        run_privileged dnf install -y "${pacotes[@]}"
    elif command -v yum &>/dev/null; then
        pacotes=(figlet hping3 wget bind-utils iproute initscripts procps-ng grep iputils gawk coreutils)
        echo "Instalando via YUM..."
        run_privileged yum install -y "${pacotes[@]}"
    elif command -v zypper &>/dev/null; then
        pacotes=(figlet hping3 wget bind-utils iproute2 sysvinit-utils procps grep iputils gawk coreutils)
        echo "Instalando via Zypper..."
        run_privileged zypper install -y "${pacotes[@]}"
    elif command -v apk &>/dev/null; then
        pacotes=(figlet hping3 wget bind-tools iproute2 openrc procps grep iputils gawk coreutils)
        echo "Instalando via APK..."
        run_privileged apk add "${pacotes[@]}"
    else
        echo "Erro: gerenciador de pacotes desconhecido."
        echo "Instale manualmente: figlet, hping3, wget, bind-utils/dnsutils, iproute2, sysvinit-utils/initscripts, procps, grep, iputils-ping, gawk, coreutils"
        exit 1
    fi

    # Verificação pós-instalação
    echo
    echo "Verificando instalação..."
    erro=0
    for cmd in "${comandos_necessarios[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Dependência '${cmd}' NÃO foi instalada. Será necessário instalar manualmente."
            erro=1
        else
            echo "'${cmd}' pronto."
        fi
    done

    if [[ $erro -eq 0 ]]; then
        echo "Todas as dependências foram instaladas com sucesso."
    else
        echo "Algumas dependências não puderam ser instaladas. Encerrando."
        exit 1
    fi
    pausa
    banner
fi

# -----------------------------------------------------------------------------
# Menu principal
# -----------------------------------------------------------------------------

while true; do
    clear
    echo -e "${AZUL}"
    figlet IP DECODER
    echo -e "${RESET}"

    echo -e "${CIANO}=================================================${RESET}"
    echo -e "${VERDE}                MENU PRINCIPAL${RESET}"
    echo -e "${CIANO}=================================================${RESET}"
    echo -e "${AMARELO}[1]${RESET} Verificação de Diretório"
    echo -e "${AMARELO}[2]${RESET} Tipos de Serviços"
    echo -e "${AMARELO}[3]${RESET} IPnet"
    echo -e "${AMARELO}[4]${RESET} Portscan de Rede (Necessário Root)"
    echo -e "${AMARELO}[5]${RESET} Parsing HTML"
    echo -e "${AMARELO}[0]${RESET} Sair"
    echo -e "${CIANO}=================================================${RESET}"

    read -r -p "Escolha uma opção: " resp
    case $resp in
        "1")
            clear
            echo -e "${AZUL}"
            figlet SISTEMA
            echo -e "${RESET}"
            echo -e "${VERDE}[+] Sistema ligado por:${RESET} $(uptime -p)"
            echo -e "${VERDE}[+] Diretório Atual:${RESET} $(pwd)"
            echo -e "${VERDE}[+] Usuário Atual:${RESET} $(whoami)"
            pausa
            ;;
        "2")
            clear
            echo -e "${AZUL}"
            figlet SERVICOS
            echo -e "${RESET}"
            read -r -p "Digite o serviço a ser reiniciado: " servicos
            if [[ -z "$servicos" ]]; then
                echo "Opção inválida (nome vazio)."
                pausa
            elif [[ ! "$servicos" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
                echo "Nome de serviço contém caracteres inválidos."
                pausa
            else
                echo "Tentando reiniciar o serviço '${servicos}'..."
                if service_restart "$servicos"; then
                    echo "Serviço '${servicos}' reiniciado com sucesso."
                else
                    echo "Falha ao reiniciar o serviço '${servicos}'."
                fi
                echo
                echo -e "${CIANO}========== PROCESSOS ==========${RESET}"
                ps aux | grep "$servicos" | grep -v "grep" || echo "Nenhum processo encontrado."
                echo
                echo -e "${CIANO}========== PORTAS ABERTAS ==========${RESET}"
                # ss -nlpt requer privilégios para mostrar o nome do processo
                run_privileged ss -nlpt || echo "Não foi possível listar as portas (verifique permissões)."
                pausa
            fi
            ;;
        "3")
            clear
            echo -e "${AZUL}"
            figlet IP-NET
            echo -e "${RESET}"
            echo -e "${AMARELO}Exemplo:${RESET} 192.168.0"
            while true; do
                read -r -p "Digite a rede (3 primeiros octetos): " ip
                if [[ "$ip" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){2}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
                    echo
                    echo -e "${CIANO}========== HOSTS ATIVOS ==========${RESET}"
                    for host in {1..254}; do
                        if ping -c1 -W1 "$ip.$host" >/dev/null 2>&1; then
                            echo -e "${VERDE}[ONLINE]${RESET} $ip.$host"
                        fi
                        echo -n "."
                    done
                    echo
                    pausa
                    break
                else
                    echo "Formato de rede inválido. Use 3 octetos (ex: 192.168.0)."
                    pausa
                fi
            done
            ;;
        "4")
            clear
            echo -e "${AZUL}"
            figlet PORTSCAN
            echo -e "${RESET}"
            echo -e "${AMARELO}Exemplo:${RESET} 192.168.0   Porta: 80"
            read -r -p "Digite a rede (3 primeiros octetos): " ip
            read -r -p "Digite a porta: " por
            if [[ -z "$ip" ]] || [[ -z "$por" ]]; then
                echo "IP ou porta não fornecidos."
                pausa
            elif [[ ! "$ip" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){2}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
                echo "Endereço de rede inválido."
                pausa
            elif [[ ! "$por" =~ ^[0-9]+$ ]] || [[ "$por" -lt 1 ]] || [[ "$por" -gt 65535 ]]; then
                echo "Porta inválida. Use um número entre 1 e 65535."
                pausa
            else
                echo
                echo -e "${CIANO}========== RESULTADOS ==========${RESET}"
                for ip2 in {1..254}; do
                    resultado=$(run_privileged hping3 -S -p "$por" -c 1 "$ip.$ip2" --fast 2>/dev/null | cut -d " " -f 2 | cut -d "=" -f 2 | head -1)
                    if [[ -n "$resultado" ]]; then
                        echo -e "${VERDE}[RESPONDEU]${RESET} $resultado"
                    fi
                done
                pausa
            fi
            ;;
        "5")
            clear
            echo -e "${AZUL}"
            figlet PARSING
            echo -e "${RESET}"
            read -r -p "Insira a URL do site: " url
            if [[ -z "$url" ]]; then
                echo "URL não fornecida."
                pausa
            else
                # Cria arquivo temporário de forma segura
                tempfile=$(mktemp) || { echo "Erro ao criar arquivo temporário."; exit 1; }
                trap 'rm -f -- "$tempfile"' EXIT

                # Download e parsing (mesma lógica do original, com proteção contra injeção)
                wget -qO- -- "$url" | \
                    grep "href" | \
                    cut -d "/" -f 3 | \
                    grep "\." | \
                    cut -d '"' -f 1 | \
                    grep -v "<l" > "$tempfile" 2>/dev/null

                echo
                echo -e "${CIANO}========== DOMÍNIOS ENCONTRADOS ==========${RESET}"

                while IFS= read -r dominio; do
                    echo -e "${AMARELO}[DOMÍNIO]${RESET} $dominio"
                    host "$dominio" 2>/dev/null | \
                        grep "has address" | \
                    while IFS= read -r linha; do
                        ip_encontrado=$(echo "$linha" | awk '{print $NF}')
                        echo -e "    ${VERDE}\u2514 IP:${RESET} $ip_encontrado"
                    done
                    echo
                done < "$tempfile"

                # Remove arquivo temporário (o trap também removerá ao sair do script)
                rm -f -- "$tempfile"
                pausa
            fi
            ;;
        "0")
            echo "Saindo..."
            read -r -p "Pressione Enter para sair... "
            exit 0
            ;;
        *)
            echo -e "${VERMELHO}Opção inválida!${RESET}"
            pausa
            ;;
    esac
done
