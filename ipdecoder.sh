#!/usr/bin/env bash

# cores
VERDE='\033[1;32m'
AZUL='\033[1;34m'
VERMELHO='\033[1;31m'
AMARELO='\033[1;33m'
CIANO='\033[1;36m'
BRANCO='\033[1;37m'
RESET='\033[0m'

# verifica se tudo foi baixado
for programa in figlet hping3 wget host ss systemctl; do
    if ! command -v "$programa" >/dev/null 2>&1; then
        echo "Erro: $programa não está instalado."
        exit 1
    fi
done

while true; do

    clear
    echo -e "${AZUL}"
    figlet IP DECODER
    echo -e "${RESET}"

    echo -e "${CIANO}=================================================${RESET}"
    echo -e "${VERDE}                MENU PRINCIPAL${RESET}"
    echo -e "${CIANO}=================================================${RESET}"
# opções do menu
    echo -e "${AMARELO}[1]${RESET} Verificação de Diretório"
    echo -e "${AMARELO}[2]${RESET} Tipos de Serviços"
    echo -e "${AMARELO}[3]${RESET} IPnet"
    echo -e "${AMARELO}[4]${RESET} Portscan de Rede(Necessário Root)"
    echo -e "${AMARELO}[5]${RESET} Parsing HTML"
    echo -e "${AMARELO}[0]${RESET} Sair"

    echo -e "${CIANO}=================================================${RESET}"

    read -p "Escolha uma opção: " resp
    case $resp in
    "1")

        clear
        echo -e "${AZUL}"
        figlet SISTEMA
        echo -e "${RESET}"
        echo -e "${VERDE}[+] Sistema ligado por:${RESET} $(uptime -p)"
        echo -e "${VERDE}[+] Diretório Atual:${RESET} $(pwd)"
        echo -e "${VERDE}[+] Usuário Atual:${RESET} $(whoami)"
        sleep 5
    ;;
    "2")
        
        clear
        echo -e "${AZUL}"  
        figlet SERVICOS
        echo -e "${RESET}"

        read -p "Digite o serviço a ser iniciado: " servicos
        if [ -z "$servicos" ]
        then
            echo "opção inválida"
            sleep 1
        else
            systemctl restart "$servicos"
            echo
            echo -e "${CIANO}========== PROCESSOS ==========${RESET}"
            ps aux | grep "$servicos" | grep -v "grep"
            echo
            echo -e "${CIANO}========== PORTAS ABERTAS ==========${RESET}"
            ss -nlpt
            sleep 5
        fi
        
    ;;
    "3")

        clear
        echo -e "${AZUL}"
        figlet IP-NET
        echo -e "${RESET}"
        echo -e "${AMARELO}Exemplo:${RESET} 192.168.0"
        read -p "Digite a rede: " ip
        if [ -z "$ip" ]
        then
            echo "ip inválido"
            sleep 1
        else
            echo
            echo -e "${CIANO}========== HOSTS ATIVOS ==========${RESET}"

            for host in {1..254}
            do
                resultado=$(ping -c1 -W1 $ip.$host 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
                if [ ! -z "$resultado" ]; then
                echo -e "${VERDE}[ONLINE]${RESET} $resultado"
                fi
            done
            sleep 10
        fi
    ;;
    "4")

        clear
        echo -e "${AZUL}"
        figlet PORTSCAN
        echo -e "${RESET}"
        echo -e "${AMARELO}Exemplo:${RESET} 192.168.0   Porta: 80"
        read -p "Digite a rede: " ip
        read -p "Digite a porta: " por
        if [ -z "$ip" ] || [ -z "$por" ]
        then
            echo "digite novamente"
            sleep 1
        else
            echo
            echo -e "${CIANO}========== RESULTADOS ==========${RESET}"
            for ip2 in {1..254}
            do
                resultado=$(hping3 -S -p "$por" -c 1 "$ip.$ip2" --fast 2>/dev/null | cut -d " " -f 2 | cut -d "=" -f 2 | head -1)
                if [ ! -z "$resultado" ]; then
                    echo -e "${VERDE}[RESPONDEU]${RESET} $resultado"
                fi
            done
            sleep 20
        fi

    ;;

    "5")

        clear
        echo -e "${AZUL}"
        figlet PARSING
        echo -e "${RESET}"
        read -p "Insira a URL do site: " url
        if [ -z "$url" ]
        then
            echo "digite novamente"
            sleep 1
        else 
            wget -qO- "$url" |
            grep "href" |
            cut -d "/" -f 3 |
            grep "\." |
            cut -d '"' -f 1 |
            grep -v "<l" > logs
            echo
            echo -e "${CIANO}========== DOMÍNIOS ENCONTRADOS ==========${RESET}"

            while read dominio
            do
                echo -e "${AMARELO}[DOMÍNIO]${RESET} $dominio"

                host "$dominio" 2>/dev/null |
                grep "has address" |
            while read linha
            do
                ip=$(echo "$linha" | awk '{print $NF}')
                echo -e "    ${VERDE}└─ IP:${RESET} $ip"
            done
            echo
            done < logs
            rm -f logs
            sleep 30
        fi
    ;;
    0)

        exit
    ;;
    *)
        echo -e "${VERMELHO}Opção inválida!${RESET}"
        sleep 2
    ;;

    esac
done
