#Requires -Version 5.1
<#
.SYNOPSIS
    Script de emergência (S.O.S) para desbloqueio de serviços do Exchange Online
    
.DESCRIPTION
    Este script é utilizado para reativar todos os serviços de acesso do Exchange Online
    quando a automação padrão falha ou precisa ser sobrescrita.
    
.PARAMETER Credential
    Credenciais para autenticação (opcional - será solicitado se não fornecido)
    
.PARAMETER TargetUsers
    Lista de usuários específicos para aplicar as mudanças (opcional - aplica a todos se não especificado)
    
.PARAMETER LogPath
    Caminho para salvar o log de execução
    
.PARAMETER WhatsAppAdmins
    Lista de números WhatsApp para receber notificações
    
.PARAMETER WhatsAppInstance
    Nome da instância WhatsApp na API (padrão: LiveTim)
    
.PARAMETER WhatsAppApiKey
    Chave de API para envio de WhatsApp
    
.EXAMPLE
    .\Exchange-SOS-Script.ps1
    
.EXAMPLE
    .\Exchange-SOS-Script.ps1 -TargetUsers "user1@domain.com","user2@domain.com"
    
.NOTES
    Versão: 2.3
    Autor: Admin Team
    Data: 2024
    Empresa: Omega Solutions
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [System.Management.Automation.PSCredential]$Credential,
    
    [Parameter(Mandatory=$false)]
    [string[]]$TargetUsers = @(),
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$PSScriptRoot\Logs\SOS_$(Get-Date -Format 'yyyyMMdd_HHmmss').log",
    
    [Parameter(Mandatory=$false)]
    [switch]$UseStoredCredentials,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false)]
    [string[]]$WhatsAppAdmins = @("SeuNumeroou_Grupo"),
    
    [Parameter(Mandatory=$false)]
    [string]$WhatsAppInstance = "SEU_InstanceName",
    
    [Parameter(Mandatory=$false)]
    [string]$WhatsAppApiKey = "SUA_APIKEY",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipNotification
)

# Força a codificação de saída da sessão para UTF-8, ajudando a prevenir problemas.
$OutputEncoding = [System.Text.Encoding]::UTF8

#region Functions
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Escreve no console com cores
    switch ($Level) {
        "ERROR"   { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "INFO"    { Write-Host $logMessage -ForegroundColor Cyan }
        default   { Write-Host $logMessage }
    }
    
    # Escreve no arquivo de log
    if ($LogPath) {
        $logMessage | Out-File -FilePath $LogPath -Append -Force -Encoding UTF8
    }
}

function Test-ModuleAvailability {
    param(
        [string[]]$RequiredModules = @('ExchangeOnlineManagement', 'AzureAD')
    )
    
    Write-Log "Verificando módulos necessários..." "INFO"
    
    foreach ($module in $RequiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Write-Log "Módulo $module não encontrado. Tentando instalar..." "WARNING"
            
            try {
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser -Confirm:$false
                Write-Log "Módulo $module instalado com sucesso" "SUCCESS"
            }
            catch {
                Write-Log "Erro ao instalar módulo ${module}: $_" "ERROR"
                return $false
            }
        }
        else {
            Write-Log "Módulo $module já está instalado" "SUCCESS"
        }
        
        # Importa o módulo
        try {
            Import-Module $module -Force
            Write-Log "Módulo $module importado com sucesso" "SUCCESS"
        }
        catch {
            Write-Log "Erro ao importar módulo ${module}: $_" "ERROR"
            return $false
        }
    }
    
    return $true
}

function Get-StoredCredentials {
    # Credenciais armazenadas de forma segura (exemplo)
    # IMPORTANTE: Em produção, use Key Vault ou método mais seguro
    
    $Username = "admin.uac@omegasolutions.com.br"
    $PasswordString = "01000000d08c9ddf0115d1118c7a00c04fc297eb0100000016c590dbf77dfc44a4923d7615db306b00000000020000000000106600000001000020000000c8e11ea93bfec31d0933ed4f95b7b8ed58bb79c8eae891d679aa52f6d6b1c2f4000000000e8000000002000020000000f6c2a7f44f17aaccb634f9bd3f1e1aa02e2ff52dfad917a3a4a76da210a6d0d6300000007cffa0effce578895ddbcb84d65c9f53b5e8ee9a4bf2d10c285d9abc9e96e220caf810adefa424a55b1e6aa462667041400000008f4339e3b42000f35caea7632dc5b34f59b355cd1ed918741a9e6eb573315e38ccb81744c2e55d1357825d5befbe560aa7e14481272fce03ea406b1261697b13"
    
    try {
        $SecPasswd = ConvertTo-SecureString $PasswordString
        $Cred = New-Object System.Management.Automation.PSCredential ($Username, $SecPasswd)
        return $Cred
    }
    catch {
        Write-Log "Erro ao recuperar credenciais armazenadas: $_" "ERROR"
        return $null
    }
}

function Connect-Services {
    param(
        [System.Management.Automation.PSCredential]$Cred
    )
    
    $connected = @{
        ExchangeOnline = $false
        AzureAD = $false
    }
    
    # Conecta ao Exchange Online
    Write-Log "Conectando ao Exchange Online..." "INFO"
    try {
        Connect-ExchangeOnline -Credential $Cred -ShowBanner:$false -ErrorAction Stop
        $connected.ExchangeOnline = $true
        Write-Log "Conectado ao Exchange Online com sucesso" "SUCCESS"
    }
    catch {
        Write-Log "Erro ao conectar ao Exchange Online: $_" "ERROR"
    }
    
    # Conecta ao Azure AD
    Write-Log "Conectando ao Azure AD..." "INFO"
    try {
        Connect-AzureAD -Credential $Cred -ErrorAction Stop | Out-Null
        $connected.AzureAD = $true
        Write-Log "Conectado ao Azure AD com sucesso" "SUCCESS"
    }
    catch {
        Write-Log "Erro ao conectar ao Azure AD: $_" "ERROR"
    }
    
    return $connected
}

function Enable-AllServices {
    param(
        [string[]]$Users = @(),
        [switch]$WhatIf
    )
    
    Write-Log "Iniciando processo de desbloqueio de serviços..." "INFO"
    
    # Define os parâmetros para ativação
    $enableParams = @{
        ActiveSyncEnabled = $true
        OWAEnabled = $true
        OWAforDevicesEnabled = $true
        MAPIEnabled = $true
        ImapEnabled = $true
        PopEnabled = $true
        SmtpClientAuthenticationDisabled = $false
        EwsEnabled = $true
    }
    
    # Obtém as caixas de correio
    try {
        if ($Users.Count -gt 0) {
            Write-Log "Processando usuários específicos: $($Users -join ', ')" "INFO"
            $mailboxes = @()
            foreach ($user in $Users) {
                try {
                    $mb = Get-EXOCASMailbox -Identity $user -ErrorAction Stop
                    $mailboxes += $mb
                }
                catch {
                    Write-Log "Erro ao obter caixa de correio para ${user}: $_" "ERROR"
                }
            }
        }
        else {
            Write-Log "Obtendo todas as caixas de correio..." "INFO"
            $mailboxes = Get-EXOCASMailbox -ResultSize Unlimited
        }
        
        Write-Log "Total de caixas de correio a processar: $($mailboxes.Count)" "INFO"
        
        # Processa cada caixa de correio
        $successCount = 0
        $errorCount = 0
        $totalCount = $mailboxes.Count
        $counter = 0
        
        foreach ($mailbox in $mailboxes) {
            $counter++
            $percentComplete = [int](($counter / $totalCount) * 100)
            
            Write-Progress -Activity "Desbloqueando serviços" `
                           -Status "Processando $($mailbox.PrimarySmtpAddress) ($counter de $totalCount)" `
                           -PercentComplete $percentComplete
            
            try {
                if ($WhatIf) {
                    Write-Log "[SIMULAÇÃO] Desbloquearia serviços para: $($mailbox.PrimarySmtpAddress)" "INFO"
                    $successCount++
                }
                else {
                    Set-CASMailbox -Identity $mailbox.PrimarySmtpAddress @enableParams -ErrorAction Stop
                    Write-Log "Serviços desbloqueados para: $($mailbox.PrimarySmtpAddress)" "SUCCESS"
                    $successCount++
                }
            }
            catch {
                Write-Log "Erro ao desbloquear serviços para $($mailbox.PrimarySmtpAddress): $_" "ERROR"
                $errorCount++
            }
            
            # Pequena pausa para evitar throttling
            if ($counter % 50 -eq 0) {
                Start-Sleep -Seconds 2
            }
        }
        
        Write-Progress -Activity "Desbloqueando serviços" -Completed
        
        # Resumo final
        Write-Log "`n========== RESUMO DA EXECUÇÃO ==========" "INFO"
        Write-Log "Total processado: $totalCount" "INFO"
        Write-Log "Sucesso: $successCount" "SUCCESS"
        Write-Log "Erros: $errorCount" $(if ($errorCount -gt 0) { "ERROR" } else { "INFO" })
        Write-Log "=======================================" "INFO"
        
        return @{
            Success = $successCount
            Errors = $errorCount
            Total = $totalCount
        }
    }
    catch {
        Write-Log "Erro crítico durante o processamento: $_" "ERROR"
        return $null
    }
}

function Send-WhatsAppNotification {
    param(
        [hashtable]$Results,
        [string]$StartTime,
        [string]$EndTime,
        [string[]]$Recipients,
        [string]$Instance,
        [string]$ApiKey
    )
    
    Write-Log "Preparando notificação via WhatsApp..." "INFO"
    
    # Calcula métricas
    $duration = [DateTime]::Parse($EndTime) - [DateTime]::Parse($StartTime)
    $successRate = if ($Results.Total -gt 0) { 
        [math]::Round(($Results.Success / $Results.Total) * 100, 2) 
    } else { 0 }
    
    # Define emoji de status baseado no resultado
    $statusEmoji = if ($Results.Errors -eq 0) { "✅" } 
                    elseif ($Results.Errors -lt 5) { "⚠️" } 
                    else { "🔴" }
    
    # Monta a mensagem formatada para WhatsApp
    # IMPORTANTE: Para que os emojis funcionem, o arquivo .ps1 DEVE ser salvo com a codificação "UTF-8 with BOM"
    $message = @"
$statusEmoji *ALERTA S.O.S - EXCHANGE ONLINE*
━━━━━━━━━━━━━━━━━━━━━━━━

🚨 *Script de Emergência Executado*
O desbloqueio em massa de serviços foi realizado!

📊 *RESUMO DA OPERAÇÃO*
• Total Processado: *$($Results.Total)* usuários
• ✅ Sucesso: *$($Results.Success)*
• ❌ Erros: *$($Results.Errors)*
• 📈 Taxa de Sucesso: *$successRate%*

⏱️ *INFORMAÇÕES TEMPORAIS*
• Início: $StartTime
• Término: $EndTime
• Duração: $($duration.ToString('hh\:mm\:ss'))

👤 *EXECUTOR*
• Usuário: $env:USERNAME
• Máquina: $env:COMPUTERNAME

🔓 *SERVIÇOS DESBLOQUEADOS*
• ActiveSync
• Outlook Web App (OWA)
• OWA for Devices
• MAPI/HTTP
• IMAP / POP3
• SMTP Client Auth
• Exchange Web Services (EWS)

$(if ($Results.Errors -gt 0) {
"⚠️ *ATENÇÃO NECESSÁRIA*
Foram detectados *$($Results.Errors) erros* durante a execução.
Verifique o log para identificar os usuários afetados."
} else {
"✅ *Execução concluída sem erros!*"
})

📁 *LOG COMPLETO*
Disponível em:
_${LogPath}_

━━━━━━━━━━━━━━━━━━━━━━━━
_Mensagem automática do Sistema S.O.S_
_Omega Solutions - Infraestrutura TI_
"@

    # Endpoint da API
    $apiUrl = "https://api.ux.net.br/message/sendText/$Instance"
    
    # Envia mensagem para cada administrador
    $successCount = 0
    $errorCount = 0
    
    foreach ($recipient in $Recipients) {
        try {
            Write-Log "Enviando notificação WhatsApp para: $recipient" "INFO"
            
            # Prepara o body da requisição como um objeto PowerShell
            $bodyObject = @{
                number = $recipient
                text = $message
            }
            
            # Converte o objeto para uma string JSON
            $jsonBody = $bodyObject | ConvertTo-Json -Depth 10
            
            # **CORREÇÃO PRINCIPAL**: Converte a string JSON para um array de bytes UTF-8
            $utf8Body = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
            
            # Prepara os headers, especificando o charset
            $headers = @{
                "Content-Type" = "application/json; charset=utf-8"
                "apikey" = $ApiKey
            }
            
            # Envia a requisição com o corpo de bytes UTF-8
            $response = Invoke-RestMethod -Uri $apiUrl `
                                          -Method Post `
                                          -Headers $headers `
                                          -Body $utf8Body `
                                          -ErrorAction Stop
            
            if ($response.status -eq "PENDING" -or $response.key) {
                Write-Log "WhatsApp enviado com sucesso para $recipient (ID: $($response.key.id))" "SUCCESS"
                $successCount++
            }
            else {
                # **CORREÇÃO APLICADA AQUI**
                # A variável $recipient foi colocada entre ${} para evitar o erro de parsing.
                Write-Log "Resposta inesperada da API para ${recipient}: $( $response | ConvertTo-Json -Depth 5 )" "WARNING"
                $errorCount++
            }
        }
        catch {
            Write-Log "Erro ao enviar WhatsApp para ${recipient}: $_" "ERROR"
            $errorCount++
        }
        
        # Pequena pausa entre envios para evitar rate limiting
        Start-Sleep -Milliseconds 500
    }
    
    # Resumo do envio
    Write-Log "Notificações WhatsApp enviadas: $successCount sucesso, $errorCount erros" "INFO"
    
    # Se todas as notificações falharam, salva relatório local
    if ($successCount -eq 0 -and $errorCount -gt 0) {
        try {
            $reportPath = "$PSScriptRoot\Reports\SOS_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
            $reportDir = Split-Path $reportPath -Parent
            
            if (!(Test-Path $reportDir)) {
                New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
            }
            
            $message | Out-File -FilePath $reportPath -Force -Encoding UTF8
            Write-Log "Notificações WhatsApp falharam. Relatório salvo em: $reportPath" "WARNING"
        }
        catch {
            Write-Log "Erro ao salvar relatório local: $_" "ERROR"
        }
    }
    
    return @{
        Sent = $successCount
        Failed = $errorCount
        Total = $Recipients.Count
    }
}

#endregion

#region Main Script

Clear-Host
$banner = @"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║               SCRIPT S.O.S - EXCHANGE ONLINE                   ║
║             Desbloqueio de Serviços em Massa                   ║
║                                                                ║
║                    Omega Solutions                             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
"@

Write-Host $banner -ForegroundColor Red

$startTime = Get-Date

# Cria diretório de logs se não existir
$logDir = Split-Path $LogPath -Parent
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Write-Log "Script S.O.S iniciado em $($startTime.ToString('dd/MM/yyyy HH:mm:ss'))" "INFO"
Write-Log "Executado por: $env:USERNAME em $env:COMPUTERNAME" "INFO"

# Verifica módulos necessários
if (!(Test-ModuleAvailability)) {
    Write-Log "Não foi possível carregar os módulos necessários. Abortando execução." "ERROR"
    exit 1
}

# Obtém credenciais
if ($UseStoredCredentials) {
    Write-Log "Usando credenciais armazenadas..." "INFO"
    $Credential = Get-StoredCredentials
    if (!$Credential) {
        Write-Log "Falha ao obter credenciais armazenadas. Solicitando manualmente..." "WARNING"
        $Credential = Get-Credential -Message "Digite as credenciais de administrador do Exchange Online"
    }
}
elseif (!$Credential) {
    Write-Log "Solicitando credenciais..." "INFO"
    $Credential = Get-Credential -Message "Digite as credenciais de administrador do Exchange Online"
}

if (!$Credential) {
    Write-Log "Credenciais não fornecidas. Abortando execução." "ERROR"
    exit 1
}

# Conecta aos serviços
$connections = Connect-Services -Cred $Credential

if (!$connections.ExchangeOnline) {
    Write-Log "Não foi possível conectar ao Exchange Online. Abortando execução." "ERROR"
    exit 1
}

# Confirmação antes de prosseguir
if (!$WhatIf) {
    Write-Host "`n⚠️  ATENÇÃO: Este script irá DESBLOQUEAR TODOS os serviços de email!" -ForegroundColor Yellow
    Write-Host "Isso inclui: ActiveSync, OWA, MAPI, IMAP, POP, SMTP e EWS" -ForegroundColor Yellow
    
    if ($TargetUsers.Count -gt 0) {
        Write-Host "Usuários afetados: $($TargetUsers -join ', ')" -ForegroundColor Cyan
    }
    else {
        Write-Host "TODOS os usuários serão afetados!" -ForegroundColor Red
    }
    
    $confirmation = Read-Host "`nDeseja continuar? (S/N)"
    if ($confirmation -ne 'S') {
        Write-Log "Execução cancelada pelo usuário" "WARNING"
        exit 0
    }
}

# Executa o desbloqueio
$results = Enable-AllServices -Users $TargetUsers -WhatIf:$WhatIf

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Log "`nTempo total de execução: $($duration.ToString('hh\:mm\:ss'))" "INFO"

# Envia notificação via WhatsApp (opcional)
if ($results -and !$WhatIf -and !$SkipNotification) {
    $sendNotification = Read-Host "`nDeseja enviar notificação via WhatsApp? (S/N)"
    if ($sendNotification -eq 'S') {
        $notificationResult = Send-WhatsAppNotification -Results $results `
                                                          -StartTime $startTime.ToString('dd/MM/yyyy HH:mm:ss') `
                                                          -EndTime $endTime.ToString('dd/MM/yyyy HH:mm:ss') `
                                                          -Recipients $WhatsAppAdmins `
                                                          -Instance $WhatsAppInstance `
                                                          -ApiKey $WhatsAppApiKey
        
        Write-Log "Resumo de notificações: $($notificationResult.Sent) enviadas, $($notificationResult.Failed) falharam" "INFO"
    }
}

# Desconecta dos serviços
Write-Log "Desconectando dos serviços..." "INFO"
try {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Disconnect-AzureAD -ErrorAction SilentlyContinue
    Write-Log "Desconectado com sucesso" "SUCCESS"
}
catch {
    Write-Log "Aviso ao desconectar: $_" "WARNING"
}

Write-Log "Script S.O.S finalizado" "INFO"
Write-Host "`n✅ Script concluído! Log salvo em: $LogPath" -ForegroundColor Green

#endregion
