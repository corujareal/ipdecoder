#  IP Decoder

> Uma ferramenta versátil que vai além do nome: automação simples para diagnóstico de sistema, rede e servidores.

![Shell Script](https://img.shields.io/badge/shell-✓-green?style=flat&logo=gnu-bash)
![Licença](https://img.shields.io/badge/licença-MIT-blue)

# O que é?

O **IP Decoder** é um conjunto de pequenas rotinas agrupadas em um único script. Ele não serve apenas para lidar com IPs – na verdade, oferece funções úteis para:

- Consultar informações do sistema e do usuário atual.
- Reiniciar serviços e visualizar processos/portas abertas.
- Descobrir hosts ativos em uma rede local (ping sweep).
- Escanear portas específicas em uma faixa de IPs.
- Extrair domínios de uma página web e resolver seus endereços IP.

Tudo isso com um menu colorido e feedback visual direto.

# Pré‑requisitos

Antes de executar, certifique-se de ter instalado no sistema:

| Programa | Por quê? |
|----------|----------|
| `bash`  | Interpretador do script. |
| `figlet` | Gera o banner estilizado nos menus. |
| `ping`  | Usado na opção de varredura de rede (ICMP). |
| `hping3` | Necessário para o **port scan** (opção 4). |
| `netstat` | Lista portas abertas (opção 2). |
| `wget`   | Baixa o HTML para o parsing (opção 5). |
| `host`   | Resolve domínios para IP (opção 5). |

Para instalar no **Debian/Ubuntu**:
```bash
sudo apt update
sudo apt install figlet hping3 wget dnsutil
```
# Observações
essa ferramenta é compatível apenas com linux
# baixar código
```bash
git clone https://github.com/corujareal/ipdecoder
cd ipdecoder
chmod +x ipdecoder.sh
./ipdecoder.sh
```
