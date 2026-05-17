# Girl Power API Monitor

Um script leve em Bash projetado para monitorar alterações em uma API JSON (como o SPA do Girl Power Series) e disparar notificações automáticas por e-mail quando o conteúdo for alterado. O script é ideal para ser rodado em background através do **Cron**, rodando de forma nativa no Linux ou WSL.

## 🚀 Funcionalidades

- **Monitoramento Simples**: Baixa o JSON de uma API especificada e o compara com a última versão conhecida.
- **Notificação Nativa via SMTP**: Utiliza o `curl` para se comunicar diretamente com servidores SMTP, sem necessidade de configuração complexa de MTA (Mail Transfer Agent) local como `Postfix` ou `Sendmail`.
- **Relatório Detalhado de Mudanças**: O corpo do e-mail inclui as diferenças exatas (`diff`) do que foi alterado.
- **Suporte ao `jq`**: Se a ferramenta `jq` estiver instalada no servidor, o script formata o JSON automaticamente para garantir que a visualização das diferenças no e-mail seja amigável e legível.
- **Anti-Spam Bypass**: Gera cabeçalhos RFC no payload (`Date`, `Message-ID`, `X-Mailer`, etc.) simulando um cliente de e-mail comum para evitar filtros de spam.

## 📋 Pré-requisitos

O script requer os seguintes pacotes instalados no seu ambiente Linux/WSL:

- `bash`
- `wget`
- `curl`
- `cmp` e `diff`
- `jq` _(Opcional, porém altamente recomendado para formatação do JSON)_

No Ubuntu/Debian, instale com:

```bash
sudo apt update
sudo apt install wget curl jq coreutils
```

## ⚙️ Configuração

1. Clone o repositório ou copie os arquivos para o seu servidor.
2. Copie o arquivo de exemplo de configuração e renomeie para `config.cfg`:
   ```bash
   cp config.cfg.example config.cfg
   ```
3. Edite o arquivo `config.cfg` e insira as suas credenciais SMTP e as informações da API:

   ```ini
   # Exemplo de configuração SMTP
   SMTP_SERVER="smtp://mail.seuservidor.com.br:587"
   SMTP_USER="seu_email@dominio.com"
   SMTP_PASS="sua_senha_ou_app_password"
   EMAIL_FROM="seu_email@dominio.com"
   EMAIL_TO="destino@dominio.com"

   # Configurações do Alvo
   API_URL="https://sua-api.com/endpoint"
   CURRENT_FILE="/tmp/api_current.json"
   PREVIOUS_FILE="/tmp/api_previous.json"
   EMAIL_SUBJECT="Modificação detectada!"
   ```

> **Aviso de Segurança:** Como o `config.cfg` contém senhas, assegure-se de que ele não seja commitado para o Git. Um arquivo `.gitignore` ignorando este arquivo é recomendado.

## ▶️ Como Usar

Dê permissão de execução para o script:

```bash
chmod +x script.sh
```

Execute manualmente para um teste (a primeira execução apenas cria a base, a segunda checa por diferenças):

```bash
./script.sh
```

### Automatizando com o Cron

Para monitorar de forma contínua a cada 3 minutos, você não precisa configurar o crontab manualmente. Basta utilizar o instalador interativo incluso no projeto:

```bash
chmod +x setup_cron.sh
./setup_cron.sh
```

O script localizará o diretório absoluto do projeto automaticamente, configurará a tarefa em background e garantirá que os logs fiquem salvos em `/tmp/girlpower_cron.log`.

> **Dica para WSL:** Se estiver usando o WSL no Windows, lembre-se de rodar `sudo service cron start` após ligar a máquina, pois o daemon do cron não inicia sozinho.

## 🛠️ Manutenabilidade e Estrutura

O programa foi refatorado utilizando as melhores práticas para scripts em Shell:

- **Separação de Configuração e Código**: Variáveis de ambiente isoladas em `config.cfg`.
- **Modularidade Funcional**: Toda a lógica foi dividida em pequenas funções (`check_dependencies`, `load_config`, `send_email`), tornando o debug extremamente fácil.
- **Fail-Fast**: Implementação da diretiva `set -e` que mata o script automaticamente se algum comando crítico falhar inesperadamente, evitando falso-positivos ou e-mails de erros genéricos.
- **Cleanup**: Os arquivos temporários (como os payloads do e-mail gerados em run-time) são descartados após a execução para não acumular lixo no `/tmp`.
