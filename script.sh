#!/bin/bash
#
# Script para buscar alterações no SPA https://www.girlpowerseries.com.br/
# Data: 17/05/2026
# Refatorado: 17/05/2026
# Criado por: Wilson Seabra
# Github: github.com/wiltosea

# Aborta o script em caso de falha não tratada de um comando
set -e

# Globals
CONFIG_FILE="$(dirname "$0")/config.cfg"
EMAIL_PAYLOAD="/tmp/email_payload_$$.txt"

# --- Funções Auxiliares ---

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

check_dependencies() {
    for cmd in wget curl cmp diff; do
        if ! command -v "$cmd" &> /dev/null; then
            log "Erro: Dependência '$cmd' não encontrada no sistema."
            exit 1
        fi
    done
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # Exporta variáveis ignorando comentários
        export $(grep -v '^#' "$CONFIG_FILE" | xargs)
    else
        log "Erro: Arquivo config.cfg não encontrado no diretório: $(dirname "$0")"
        exit 1
    fi
}

download_api_data() {
    if ! wget -qO "$CURRENT_FILE" "$API_URL"; then
        log "Erro ao baixar dados da API: $API_URL"
        exit 1
    fi
}

format_and_diff() {
    # Tenta usar jq para formatar o JSON (melhora a visualização do diff),
    # caso contrário usa diff direto nos arquivos originais
    if command -v jq &> /dev/null; then
        diff -u <(jq . "$PREVIOUS_FILE") <(jq . "$CURRENT_FILE") || true
    else
        diff -u "$PREVIOUS_FILE" "$CURRENT_FILE" || true
    fi
}

build_email_payload() {
    local date_str=$(date -R)
    local message_id="<$(date +%s%N)-api-monitor@localhost>"
    
    # Formatando os cabeçalhos para o padrão RFC (parecer com cliente de email real)
    echo "Date: $date_str" > "$EMAIL_PAYLOAD"
    echo "Message-ID: $message_id" >> "$EMAIL_PAYLOAD"
    echo "From: $EMAIL_FROM" >> "$EMAIL_PAYLOAD"
    echo "To: $EMAIL_TO" >> "$EMAIL_PAYLOAD"
    echo "Subject: $EMAIL_SUBJECT" >> "$EMAIL_PAYLOAD"
    echo "MIME-Version: 1.0" >> "$EMAIL_PAYLOAD"
    echo "Content-Type: text/plain; charset=utf-8" >> "$EMAIL_PAYLOAD"
    echo "X-Mailer: Mozilla Thunderbird" >> "$EMAIL_PAYLOAD"
    echo "" >> "$EMAIL_PAYLOAD"
    echo "Foram detectadas modificacoes no JSON da API: $API_URL" >> "$EMAIL_PAYLOAD"
    echo "" >> "$EMAIL_PAYLOAD"
    echo "Diferenças:" >> "$EMAIL_PAYLOAD"
    echo "--------------------------------------------------" >> "$EMAIL_PAYLOAD"
    
    format_and_diff >> "$EMAIL_PAYLOAD"
    
    echo "--------------------------------------------------" >> "$EMAIL_PAYLOAD"
}

send_email() {
    # Envia o e-mail via curl usando a configuração SMTP do config.cfg
    # O parâmetro -sS esconde a barra de progresso mas exibe mensagens de erro
    local curl_output
    set +e # Desabilita a parada de erro pra podermos capturar o erro do curl gracefully
    
    curl_output=$(curl -sS --url "$SMTP_SERVER" --ssl-reqd \
        --mail-from "$EMAIL_FROM" --mail-rcpt "$EMAIL_TO" \
        --user "$SMTP_USER:$SMTP_PASS" \
        -T "$EMAIL_PAYLOAD" 2>&1)
      
    if [ $? -eq 0 ]; then
        log "E-mail de notificação enviado com sucesso!"
    else
        log "Erro ao enviar e-mail. Verifique as configurações no arquivo config.cfg."
        log "Detalhes do erro do cURL: $curl_output"
    fi
    set -e
}

cleanup() {
    # Remove payload temporário após o envio
    if [ -f "$EMAIL_PAYLOAD" ]; then
        rm -f "$EMAIL_PAYLOAD"
    fi
}

# --- Loop Principal ---

main() {
    check_dependencies
    load_config
    download_api_data
    
    # Verifica se o arquivo anterior (última consulta) existe
    if [ -f "$PREVIOUS_FILE" ]; then
        # Compara o conteúdo do arquivo atual com o anterior
        if ! cmp -s "$CURRENT_FILE" "$PREVIOUS_FILE"; then
            log "Modificações detectadas! Gerando e enviando e-mail..."
            
            build_email_payload
            send_email
            
            # Atualiza o arquivo de referência com o conteúdo mais recente
            cp "$CURRENT_FILE" "$PREVIOUS_FILE"
        else
            log "Nenhuma modificação detectada na API."
        fi
    else
        log "Primeira execução do script. Criando o arquivo de referência inicial..."
        cp "$CURRENT_FILE" "$PREVIOUS_FILE"
    fi
    
    cleanup
}

# Inicia a execução
main
