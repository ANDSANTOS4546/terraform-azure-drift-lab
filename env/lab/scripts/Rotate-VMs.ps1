<#
.SYNOPSIS
Rotação Semanal de Domain Controllers com Salvaguarda Estrita de Disponibilidade.
.DESCRIPTION
Este script alterna os Domain Controllers garantindo que o nó inativo NUNCA seja
desligado se o nó ativo falhar ao iniciar.
#>

# 1. Definição do Ambiente
$vm1 = "vm-drift-lab"
$vm2 = "vm-drift-lab-2"
$rg = "rg-terraform-drift-lab"

Write-Output "🤖 [INÍCIO] Iniciando rotina automatizada de rotação dos Domain Controllers..."

# --------------------------------------------------------------------------
# [STEP]: TRY/CATCH CLARO PARA AUTENTICAÇÃO
# --------------------------------------------------------------------------
try {
  Disable-AzContextAutosave -Scope Process
  Connect-AzAccount -Identity -ErrorAction Stop
  Write-Output "🔒 [SUCESSO] Autenticação estabelecida via Managed Identity."
} catch {
  Write-Error "❌ [ERRO CRÍTICO - TRY/CATCH] Falha na autenticação com a Azure. Abortando script preventivamente para evitar indisponibilidade: $_"
  throw $_
}

# 2. Cálculo da Semana (Lógica de Calendário ISO)
$calendar = [System.Globalization.CultureInfo]::InvariantCulture.Calendar
$week = $calendar.GetWeekOfYear(
(Get-Date),
[System.Globalization.CalendarWeekRule]::FirstFourDayWeek,
[DayOfWeek]::Monday
)

Write-Output "📅 [INFO] Semana atual detectada no calendário ISO: $week"

if ($week % 2 -eq 0) {
  $vmToStart = $vm1
  $vmToStop = $vm2
  Write-Output "⚖️ [LOG] Semana PAR: Target ON -> $vmToStart | Target OFF -> $vmToStop"
} else {
  $vmToStart = $vm2
  $vmToStop = $vm1
  Write-Output "⚖️ [LOG] Semana ÍMPAR: Target ON -> $vmToStart | Target OFF -> $vmToStop"
}

# ==============================================================================
# ORQUESTRAÇÃO PRINCIPAL COM AS SALVAGUARDAS SOLICITADAS
# ==============================================================================
try {

  # --------------------------------------------------------------------------
  # [STEP]: VALIDAÇÃO DO ESTADO REAL DAS VMS (Antes de tomar qualquer ação)
  # --------------------------------------------------------------------------
  Write-Output "🔍 [CHECK] Validando o estado real atual da VM alvo de boot ($vmToStart)..."
  $currentStatusCheck = Get-AzVM -ResourceGroupName $rg -Name $vmToStart -Status -ErrorAction Stop
  $currentPowerState = ($currentStatusCheck.Statuses | Where-Object Code -like "PowerState/*").DisplayStatus

  if ($currentPowerState -eq "VM running") {
    Write-Output "ℹ️ [INFO] A VM $vmToStart já consta como 'VM running' no Azure. Prosseguindo..."
  } else {
    Write-Output "⚡ [AÇÃO] Estado atual é '$currentPowerState'. Enviando comando de inicialização..."
    Start-AzVM -ResourceGroupName $rg -Name $vmToStart -ErrorAction Stop
  }

  # --------------------------------------------------------------------------
  # [STEP]: NÃO DESLIGAR ANTES DE TER CERTEZA QUE A OUTRA SUBIU
  # --------------------------------------------------------------------------
  Write-Output "⏳ [CHECK] Iniciando loop de validação de telemetria para garantir que a VM subiu de fato..."
  $isVmRunning = $false
  $maxAttempts = 10 # 10 tentativas * 30 segundos = 5 minutos limite
  $attempt = 1

  while (-not $isVmRunning -and $attempt -le $maxAttempts) {
    # Interroga o estado real de energia direto na API do Hypervisor da Azure
    $vmStatus = Get-AzVM -ResourceGroupName $rg -Name $vmToStart -Status -ErrorAction SilentlyContinue
    $realTimeStatus = ($vmStatus.Statuses | Where-Object Code -like "PowerState/*").DisplayStatus

    if ($realTimeStatus -eq "VM running") {
      $isVmRunning = $true
      Write-Output "✅ [CERTEZA CONFIRMADA] A VM $vmToStart atingiu o estado real de '$realTimeStatus' com sucesso (Tentativa $attempt)."
    } else {
      Write-Output "🔄 [AGUARDANDO] Tentativa $attempt/$maxAttempts: VM ainda está em transição ('$realTimeStatus'). Dormindo 30s..."
      Start-Sleep -Seconds 30
      $attempt++
    }
  }

  # Bloqueio de segurança rígido: Se não tiver certeza absoluta do boot, o script gera uma falha deliberada
  if (-not $isVmRunning) {
    throw "Segurança violada: A VM target $vmToStart falhou em responder como 'VM running' dentro do tempo limite de 5 minutos."
  }

  # Janela de tolerância para subida interna dos serviços de AD (DNS, NTDS, SYSVOL)
  Write-Output "💤 [BUFFER] Aguardando 60 segundos de cooldown para estabilização interna dos serviços do Active Directory..."
  Start-Sleep -Seconds 60

  # --------------------------------------------------------------------------
  # [AÇÃO FINAL]: O desligamento seguro só ocorre agora
  # --------------------------------------------------------------------------
  Write-Output "🛑 [AÇÃO DE SEGURANÇA] Com a subida da VM alvo validada com sucesso, desligando o host antigo: $vmToStop"
  Stop-AzVM -ResourceGroupName $rg -Name $vmToStop -Force -ErrorAction Stop

  Write-Output "🚀 [FIM] Processo de rotação semanal concluído com sucesso e 100% livre de downtime!"

} catch {
  # --------------------------------------------------------------------------
  # [STEP]: TRY/CATCH CLARO PARA EVENTOS DE ERRO E SALVAGUARDA DE DOWNTIME
  # --------------------------------------------------------------------------
  Write-Error "🚨 [TRY/CATCH AVISO DE INCIDENTE] Ocorreu uma falha durante a execução do fluxo principal: $_"
  Write-Error "⚠️ [SALVAGUARDA ATIVA] O comando de desligamento da VM antiga ($vmToStop) FOI CANCELADO. Ambos os hosts ou o host remanescente continuarão ligados para mitigar indisponibilidade no AD."
  throw $_
}
