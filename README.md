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

- ✅ **Desbloqueio em Massa**: Ativa todos os protocolos de email simultaneamente
- 📊 **Relatórios Detalhados**: Gera logs completos e envia notificações por email
- 🔒 **Múltiplas Autenticações**: Suporta credenciais armazenadas ou interativas
- 🎯 **Processamento Seletivo**: Pode processar usuários específicos ou todos
- 🧪 **Modo Simulação**: Teste com `-WhatIf` antes de aplicar mudanças
- 📧 **Notificações Automáticas**: Envia relatório HTML por email após execução
- 🔄 **Anti-Throttling**: Pausas automáticas para evitar bloqueios por rate limit
- 💾 **Backup Local**: Salva relatórios localmente se o email falhar

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
```powershell
# O script verifica e instala automaticamente se necessário:
- ExchangeOnlineManagement
- AzureAD
```

### Permissões Necessárias
- Conta com privilégios de **Exchange Administrator** ou **Global Administrator**
- Permissões para modificar configurações de CAS Mailbox

### Requisitos do Sistema
- Windows PowerShell 5.1 ou superior
- Conexão com a Internet
- Acesso ao tenant do Microsoft 365

## 🔧 Instalação

### 1. Clone o repositório
```bash
git clone https://github.com/elvisfalmeida/exchange-emergency-toolkit.git
cd exchange-emergency-toolkit
```

### 2. Estrutura de Diretórios
O script criará automaticamente:
```
exchange-emergency-toolkit/
├── Exchange-SOS-Script.ps1
├── README.md
├── LICENSE
├── Logs/                    # Logs de execução
│   └── SOS_YYYYMMDD_HHMMSS.log
└── Reports/                 # Relatórios HTML
    └── SOS_Report_YYYYMMDD_HHMMSS.html
```

## 💻 Uso

### Sintaxe Básica
```powershell
.\Exchange-SOS-Script.ps1 [[-Credential] <PSCredential>] 
                          [[-TargetUsers] <string[]>] 
                          [[-LogPath] <string>]
                          [[-NotificationRecipients] <string[]>]
                          [-UseStoredCredentials]
                          [-WhatIf]
                          [-SkipEmailNotification]
```

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| `-Credential` | PSCredential | Não | Credenciais para autenticação. Se não fornecido, será solicitado interativamente |
| `-TargetUsers` | String[] | Não | Lista de usuários específicos para processar. Se vazio, processa todos |
| `-LogPath` | String | Não | Caminho customizado para o arquivo de log |
| `-NotificationRecipients` | String[] | Não | Lista de emails para receber notificações |
| `-UseStoredCredentials` | Switch | Não | Usa credenciais armazenadas de forma segura no script |
| `-WhatIf` | Switch | Não | Modo simulação - mostra o que seria feito sem aplicar mudanças |
| `-SkipEmailNotification` | Switch | Não | Pula o envio de email de notificação |

### Exemplos de Uso

#### 1. Execução Básica (Interativa)
```powershell
# Solicita credenciais e processa todos os usuários
.\Exchange-SOS-Script.ps1
```

#### 2. Usando Credenciais Armazenadas
```powershell
# Usa as credenciais pré-configuradas no script
.\Exchange-SOS-Script.ps1 -UseStoredCredentials
```

#### 3. Processar Usuários Específicos
```powershell
# Desbloqueia apenas usuários específicos
.\Exchange-SOS-Script.ps1 -TargetUsers "user1@empresa.com","user2@empresa.com","user3@empresa.com"
```

#### 4. Modo Simulação (Teste Seguro)
```powershell
# Simula a execução sem fazer alterações
.\Exchange-SOS-Script.ps1 -WhatIf
```

#### 5. Com Notificação Personalizada
```powershell
# Envia relatório para destinatários específicos
.\Exchange-SOS-Script.ps1 -NotificationRecipients "ciso@empresa.com","soc@empresa.com","auditoria@empresa.com"
```

#### 6. Execução Completa com Todos os Parâmetros
```powershell
.\Exchange-SOS-Script.ps1 `
    -UseStoredCredentials `
    -TargetUsers "vip1@empresa.com","vip2@empresa.com" `
    -LogPath "C:\Logs\EmergencySOS.log" `
    -NotificationRecipients "gestao@empresa.com" `
    -WhatIf
```

#### 7. Execução Silenciosa (Sem Email)
```powershell
# Executa sem enviar notificações por email
.\Exchange-SOS-Script.ps1 -SkipEmailNotification
```

## 📊 Resultados Esperados

### Durante a Execução

```
╔════════════════════════════════════════════════════════════════╗
║                    SCRIPT S.O.S - EXCHANGE ONLINE              ║
║                  Desbloqueio de Serviços em Massa              ║
║                         Omega Solutions                        ║
╚════════════════════════════════════════════════════════════════╝

[2024-12-22 10:15:00] [INFO] Script S.O.S iniciado
[2024-12-22 10:15:01] [INFO] Verificando módulos necessários...
[2024-12-22 10:15:05] [SUCCESS] Conectado ao Exchange Online
[2024-12-22 10:15:10] [INFO] Total de caixas de correio a processar: 150

Progress: [████████████████----] 80% - Processando user123@empresa.com (120 de 150)

[2024-12-22 10:25:00] [SUCCESS] Serviços desbloqueados para: user123@empresa.com
```

### Relatório Final

```
========== RESUMO DA EXECUÇÃO ==========
Total processado: 150
Sucesso: 148
Erros: 2
Taxa de Sucesso: 98.67%
Tempo de Execução: 00:10:35
========================================
```

### Estrutura do Log

O arquivo de log incluirá:
- Timestamp de cada operação
- Usuário e máquina que executou
- Cada mailbox processada
- Sucessos e falhas detalhadas
- Tempos de execução
- Erros específicos com stack trace

### Email de Notificação

O email HTML enviado contém:
- 📊 Dashboard visual com estatísticas
- 🕐 Informações temporais (início, fim, duração)
- 👤 Identificação do executor
- 📈 Taxa de sucesso com indicadores coloridos
- ⚠️ Alertas para erros que necessitam atenção
- 📁 Link/caminho para o log completo

## 🛡️ Segurança

### Boas Práticas

1. **Auditoria**: Sempre mantenha os logs para fins de auditoria
2. **Aprovação**: Execute apenas com aprovação formal da gestão
3. **Comunicação**: Notifique as equipes relevantes antes da execução
4. **Validação**: Use `-WhatIf` primeiro para validar o escopo
5. **Monitoramento**: Monitore os serviços após o desbloqueio

### Armazenamento de Credenciais

Para usar credenciais armazenadas com segurança:

```powershell
# Gerar string segura (execute em sua máquina)
$secureString = ConvertTo-SecureString "SuaSenha" -AsPlainText -Force
$encryptedString = ConvertFrom-SecureString $secureString
$encryptedString | Set-Clipboard  # Copia para área de transferência
```

⚠️ **Nota**: As credenciais criptografadas só funcionam na máquina onde foram geradas.

## 📝 Logs e Troubleshooting

### Localização dos Logs
- **Logs de Execução**: `.\Logs\SOS_YYYYMMDD_HHMMSS.log`
- **Relatórios HTML**: `.\Reports\SOS_Report_YYYYMMDD_HHMMSS.html`

### Problemas Comuns

#### Erro de Autenticação
```powershell
# Verifique se o MFA está desabilitado para a conta de serviço
# Ou use autenticação moderna com:
Connect-ExchangeOnline -UserPrincipalName admin@empresa.com
```

#### Throttling/Rate Limiting
```powershell
# O script já tem pausas automáticas, mas você pode ajustar:
# Procure por "Start-Sleep -Seconds 2" e aumente o valor
```

#### Módulos não Encontrados
```powershell
# Instale manualmente com privilégios de admin:
Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
Install-Module -Name AzureAD -Force -AllowClobber
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Distribuído sob a licença MIT. Veja `LICENSE` para mais informações.

## 👨‍💻 Autor

**Elvis F. Almeida**
- GitHub: [@elvisfalmeida](https://github.com/elvisfalmeida)
- LinkedIn: [Seu LinkedIn](https://linkedin.com/in/elvisfalmeida)

## 🙏 Agradecimentos

- Equipe de TI da Omega Solutions
- Comunidade PowerShell
- Microsoft Exchange Online Documentation

## 📞 Suporte

Para suporte, abra uma [issue](https://github.com/elvisfalmeida/exchange-emergency-toolkit/issues) no GitHub.

## 🔄 Changelog

### [1.0.0] - 2024-12-22
- Release inicial
- Desbloqueio em massa de serviços
- Sistema de logs completo
- Notificações por email
- Modo WhatIf para testes

---

⚡ **Use com responsabilidade!** Este é um script de emergência que remove restrições de segurança.

🔴 **IMPORTANTE**: Sempre documente o motivo da execução e obtenha aprovação adequada antes de usar em produção.
