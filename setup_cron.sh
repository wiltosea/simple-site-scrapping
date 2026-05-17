#!/bin/bash
# Script para configurar automaticamente o cronjob do monitor

# Descobre o diretório absoluto onde este script (e o projeto) está localizado
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SCRIPT_PATH="$DIR/script.sh"
LOG_PATH="/tmp/girlpower_cron.log"

# Define o intervalo (A cada 3 minutos)
CRON_SCHEDULE="*/3 * * * *"

# Comando exato a ser inserido no cron
CRON_CMD="$CRON_SCHEDULE $SCRIPT_PATH >> $LOG_PATH 2>&1"

echo "⚙️ Configurando o Cron..."

# Garante que o script de monitoramento seja executável
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Erro: O script principal ($SCRIPT_PATH) não foi encontrado."
    exit 1
fi
chmod +x "$SCRIPT_PATH"

# Verifica se o cronjob já existe para evitar duplicações
if crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" > /dev/null; then
    echo "⚠️ Aviso: O cronjob para este script já está configurado no seu sistema!"
    echo "Para visualizar ou editar seus cronjobs, digite: crontab -e"
    exit 0
fi

# Adiciona o novo cronjob preservando os que já existem no usuário
(crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -

echo "✅ Cronjob configurado com sucesso!"
echo "⏱️ O monitor será executado de acordo com a regra: $CRON_SCHEDULE"
echo "📄 Os logs de execução serão armazenados em: $LOG_PATH"

# Lembrete importante para usuários de WSL
if uname -a | grep -i "microsoft" > /dev/null; then
    echo ""
    echo "🛑 ATENÇÃO: Parece que você está usando o WSL."
    echo "O serviço cron pode não iniciar sozinho no WSL. Certifique-se de iniciá-lo rodando:"
    echo "sudo service cron start"
fi
