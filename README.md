# Exchange-Emergency-Toolkit

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Exchange Online](https://img.shields.io/badge/Exchange-Online-green.svg)](https://docs.microsoft.com/en-us/exchange/exchange-online)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/elvisfalmeida/exchange-emergency-toolkit/graphs/commit-activity)

## 📋 Descrição

**Exchange-Emergency-Toolkit** é um script PowerShell de emergência (S.O.S) desenvolvido para situações críticas onde é necessário desbloquear rapidamente todos os serviços de email do Exchange Online que foram bloqueados por automação ou políticas de segurança.

Este script foi criado para cenários onde a automação principal falha ou quando é necessário sobrescrever rapidamente as configurações de segurança em massa.

## ⚠️ Aviso Importante

> **ATENÇÃO**: Este script remove TODAS as restrições de acesso aos serviços de email. Use apenas em situações de emergência e com aprovação adequada da gestão de TI/Segurança.

## 🚀 Características

### Principais Funcionalidades

- ✅ **Desbloqueio em Massa**: Ativa todos os protocolos de email simultaneamente.
- 📊 **Relatórios Detalhados**: Gera logs de texto completos com o status de cada operação.
- 📱 **Notificações por WhatsApp**: Envia um resumo detalhado da operação via WhatsApp para administradores.
- 🔒 **Múltiplas Autenticações**: Suporta credenciais armazenadas ou interativas.
- 🎯 **Processamento Seletivo**: Pode processar usuários específicos ou todos os usuários do tenant.
- 🧪 **Modo Simulação**: Permite testar a execução com o parâmetro `-WhatIf` antes de aplicar mudanças reais.
- 🔄 **Anti-Throttling**: Inclui pausas automáticas para evitar bloqueios por *rate limit* da API do Exchange.
- 💾 **Backup Local**: Salva um relatório de notificação localmente se o envio via WhatsApp falhar.

### Serviços Desbloqueados

O script ativa os seguintes serviços para cada usuário:
- ActiveSync
- Outlook Web App (OWA)
- OWA for Devices
- MAPI/HTTP
- IMAP
- POP3
- SMTP Client Authentication
- Exchange Web Services (EWS)

## 📦 Pré-requisitos

### Módulos PowerShell Necessários
O script verifica e tenta instalar os seguintes módulos automaticamente:
- `ExchangeOnlineManagement`
- `AzureAD`

### Permissões Necessárias
- Conta com privilégios de **Exchange Administrator** ou **Global Administrator** no Microsoft 365.
- Permissões para modificar configurações de `CAS Mailbox`.

### Notificações via WhatsApp (API Externa)
Para utilizar o sistema de notificação via WhatsApp, é **obrigatório** ter uma instância da **[Evolution API](https://github.com/EvolutionAPI/evolution-api)** ativa e funcional.

Você precisará das seguintes informações da sua instância da API:
- **Endpoint (URL da API)**: O script usa um endpoint fixo (`https://api.ux.net.br`), mas você pode ajustá-lo se necessário.
- **Instance Name**: O nome da sua instância na Evolution API.
- **API Key**: A chave de API para autenticação.

### Requisitos do Sistema
- Windows PowerShell 5.1 ou superior.
- Conexão com a Internet.

## 🔧 Instalação

### 1. Clone o repositório
```bash
git clone [https://github.com/elvisfalmeida/exchange-emergency-toolkit.git](https://github.com/elvisfalmeida/exchange-emergency-toolkit.git)
cd exchange-emergency-toolkit
```

### 2. Estrutura de Diretórios
O script criará automaticamente os seguintes diretórios e arquivos:
```
exchange-emergency-toolkit/
├── Exchange-SOS-Script.ps1
├── README.md
├── LICENSE
├── Logs/                  # Logs de execução detalhados
│   └── SOS_YYYYMMDD_HHMMSS.log
└── Reports/               # Relatórios de notificação (se o envio falhar)
    └── SOS_Report_YYYYMMDD_HHMMSS.txt
```

## 💻 Uso

### Sintaxe Básica
```powershell
.\Exchange-SOS-Script.ps1 `
    [-Credential <PSCredential>] `
    [-TargetUsers <string[]>] `
    [-LogPath <string>] `
    [-WhatsAppAdmins <string[]>] `
    [-WhatsAppInstance <string>] `
    [-WhatsAppApiKey <string>] `
    [-UseStoredCredentials] `
    [-WhatIf] `
    [-SkipNotification]
```

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `-Credential` | PSCredential | Não | Credenciais para autenticação. Se não fornecido, será solicitado interativamente. |
| `-TargetUsers` | String[] | Não | Lista de usuários específicos para processar. Se vazio, processa todos. |
| `-LogPath` | String | Não | Caminho customizado para o arquivo de log. |
| `-WhatsAppAdmins` | String[] | Não | Lista de números WhatsApp (com código do país) para receber notificações. |
| `-WhatsAppInstance` | String | Não | Nome da sua instância na Evolution API. |
| `-WhatsAppApiKey` | String | Não | Chave de API para autenticação na Evolution API. |
| `-UseStoredCredentials` | Switch | Não | Usa credenciais de administrador armazenadas de forma segura no script. |
| `-WhatIf` | Switch | Não | Modo simulação - mostra o que seria feito sem aplicar mudanças reais. |
| `-SkipNotification` | Switch | Não | Pula a etapa de envio de notificação via WhatsApp. |

### Exemplos de Uso

#### 1. Execução Básica (Interativa)
```powershell
# Solicita credenciais, processa todos os usuários e pergunta se deseja notificar.
.\Exchange-SOS-Script.ps1
```

#### 2. Usando Credenciais Armazenadas
```powershell
# Usa as credenciais pré-configuradas no script para o administrador.
.\Exchange-SOS-Script.ps1 -UseStoredCredentials
```

#### 3. Processar Usuários Específicos
```powershell
# Desbloqueia apenas usuários específicos.
.\Exchange-SOS-Script.ps1 -TargetUsers "user1@empresa.com","user2@empresa.com"
```

#### 4. Modo Simulação (Teste Seguro)
```powershell
# Simula a execução para todos os usuários sem fazer alterações.
.\Exchange-SOS-Script.ps1 -WhatIf
```

#### 5. Execução Completa com Parâmetros de Notificação
```powershell
# Executa para um usuário, usando credenciais armazenadas e enviando notificação para administradores específicos.
.\Exchange-SOS-Script.ps1 `
    -UseStoredCredentials `
    -TargetUsers "vip1@empresa.com" `
    -WhatsAppAdmins "5511999998888","5521888889999" `
    -WhatsAppInstance "minha-instancia" `
    -WhatsAppApiKey "SUA_API_KEY_AQUI"
```

#### 6. Execução Silenciosa (Sem Notificação)
```powershell
# Executa o processo sem enviar notificações via WhatsApp.
.\Exchange-SOS-Script.ps1 -SkipNotification
```

## 📊 Resultados Esperados

### Saída no Console
```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║               SCRIPT S.O.S - EXCHANGE ONLINE                   ║
║             Desbloqueio de Serviços em Massa                   ║
║                                                                ║
║                    Omega Solutions                             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

[2025-08-11 10:30:00] [INFO] Script S.O.S iniciado em 11/08/2025 10:30:00
[2025-08-11 10:30:01] [SUCCESS] Módulo ExchangeOnlineManagement já está instalado
[2025-08-11 10:30:05] [SUCCESS] Conectado ao Exchange Online com sucesso
[2025-08-11 10:30:10] [INFO] Total de caixas de correio a processar: 150

Progress: [████████████████----] 80% - Processando user123@empresa.com (120 de 150)

[2025-08-11 10:35:00] [SUCCESS] Serviços desbloqueados para: user123@empresa.com
...
========== RESUMO DA EXECUÇÃO ==========
[2025-08-11 10:40:35] [INFO] Total processado: 150
[2025-08-11 10:40:35] [SUCCESS] Sucesso: 148
[2025-08-11 10:40:35] [ERROR] Erros: 2
========================================
```

### Notificação no WhatsApp
Uma mensagem formatada será enviada aos administradores, contendo:
- ✅ Status geral da operação (sucesso, alerta ou erro).
- 📊 Resumo com total de usuários, sucessos e falhas.
- 📈 Taxa de sucesso percentual.
- ⏱️ Informações de tempo (início, fim e duração).
- 👤 Identificação do usuário e máquina que executou o script.
- 📁 Caminho completo para o arquivo de log detalhado.

## 🛡️ Segurança

### Boas Práticas
1.  **Auditoria**: Sempre mantenha os logs para fins de auditoria e conformidade.
2.  **Aprovação**: Execute o script apenas com aprovação formal da gestão de TI ou Segurança da Informação.
3.  **Comunicação**: Notifique as equipes relevantes (Help Desk, Segurança) antes e depois da execução.
4.  **Validação**: Sempre use `-WhatIf` primeiro para validar o escopo e o impacto das alterações.
5.  **Monitoramento**: Monitore os serviços e os logs de acesso do Microsoft 365 após o desbloqueio.

### Armazenamento de Credenciais
Para usar o parâmetro `-UseStoredCredentials`, você precisa gerar uma string segura da senha da conta de serviço e inseri-la na função `Get-StoredCredentials` dentro do script.

```powershell
# Execute este comando na máquina onde o script será executado
$secureString = ConvertTo-SecureString "SuaSenhaSuperSecreta" -AsPlainText -Force
$encryptedString = ConvertFrom-SecureString $secureString

# Copie a string de saída e cole no script
$encryptedString | Set-Clipboard
```
⚠️ **Nota**: As credenciais criptografadas só funcionam no mesmo computador e para o mesmo usuário que as gerou.

## 📝 Logs e Troubleshooting

### Localização dos Arquivos
- **Logs de Execução**: `.\Logs\SOS_YYYYMMDD_HHMMSS.log`
- **Relatórios de Notificação (Fallback)**: `.\Reports\SOS_Report_YYYYMMDD_HHMMSS.txt`

### Problemas Comuns

#### Erro de Autenticação no Exchange
- Verifique se a conta de serviço não possui MFA habilitado ou use uma conta que suporte autenticação não interativa.
- Garanta que a senha da conta não expirou.

#### Erro ao Enviar Notificação via WhatsApp
- Verifique se a URL da API, o nome da instância e a API Key estão corretos.
- Confirme se a máquina que executa o script tem acesso à internet e consegue alcançar o endpoint da sua Evolution API.
- Certifique-se de que a instância na Evolution API está conectada e com o status "Connected".

#### Módulos não Encontrados
Se a instalação automática falhar, instale os módulos manualmente em um terminal PowerShell com privilégios de administrador:
```powershell
Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
Install-Module -Name AzureAD -Force -AllowClobber
```

## 🤝 Contribuindo

Contribuições são muito bem-vindas! Por favor, siga estes passos:
1.  Fork o projeto.
2.  Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`).
3.  Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`).
4.  Push para a branch (`git push origin feature/AmazingFeature`).
5.  Abra um Pull Request.

## 📄 Licença

Distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais informações.

## 👨‍💻 Autor

**Elvis F. Almeida**
- GitHub: [@elvisfalmeida](https://github.com/elvisfalmeida)
- LinkedIn: [linkedin.com/in/elvisfalmeida](https://linkedin.com/in/elvisfalmeida)

## 🙏 Agradecimentos

- Equipe de TI da Omega Solutions
- Comunidade PowerShell do Brasil
- Time de desenvolvimento da [Evolution API](https://github.com/EvolutionAPI/evolution-api)

---

⚡ **Use com responsabilidade!** Este é um script de emergência que remove restrições de segurança.

🔴 **IMPORTANTE**: Sempre documente o motivo da execução e obtenha aprovação adequada antes de usar em produção.
