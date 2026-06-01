#!/bin/bash

# Cores

VERDE='\033[1;32m'
AZUL='\033[1;34m'
VERMELHO='\033[1;31m'
AMARELO='\033[1;33m'
CIANO='\033[1;36m'
BRANCO='\033[1;37m'
RESET='\033[0m'

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
echo -e "${AMARELO}[4]${RESET} Portscan de Rede"
echo -e "${AMARELO}[5]${RESET} Parsing HTML"

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

;;

"2")
clear
echo -e "${AZUL}"
figlet SERVICOS
echo -e "${RESET}"


read -p "Digite o serviço a ser iniciado: " servicos

service "$servicos" restart

echo
echo -e "${CIANO}========== PROCESSOS ==========${RESET}"
ps aux | grep "$servicos"

echo
echo -e "${CIANO}========== PORTAS ABERTAS ==========${RESET}"
netstat -nlpt


;;

"3")
clear
echo -e "${AZUL}"
figlet IP-NET
echo -e "${RESET}"


echo -e "${AMARELO}Exemplo:${RESET} 192.168.0"

read -p "Digite a rede: " ip

echo
echo -e "${CIANO}========== HOSTS ATIVOS ==========${RESET}"

for host in {1..254}
do
    resultado=$(ping -c1 -W1 $ip.$host 2>/dev/null | grep "64 bytes" | cut -d ":" -f1 | cut -d " " -f4)

    if [ ! -z "$resultado" ]; then
        echo -e "${VERDE}[ONLINE]${RESET} $resultado"
    fi
done


;;

"4")
clear
echo -e "${AZUL}"
figlet PORTSCAN
echo -e "${RESET}"


echo -e "${AMARELO}Exemplo:${RESET} 192.168.0   Porta: 80"

read -p "Digite a rede: " pi
read -p "Digite a porta: " por

echo
echo -e "${CIANO}========== RESULTADOS ==========${RESET}"

for iip in {1..254}
do
    resultado=$(hping3 -S -p $por -c 1 $pi.$iip 2>/dev/null | cut -d " " -f 2)

    if [ ! -z "$resultado" ]; then
        echo -e "${VERDE}[RESPONDEU]${RESET} $resultado"
    fi
done


;;

"5")
clear
echo -e "${AZUL}"
figlet PARSING
echo -e "${RESET}"

read -p "Insira a URL do site: " url

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

;;

*)
echo -e "${VERMELHO}Opção inválida!${RESET}"
;;

esac
