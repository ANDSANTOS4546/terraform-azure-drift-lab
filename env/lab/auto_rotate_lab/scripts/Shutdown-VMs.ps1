# =======================================================================
# SCRIPT DE TESTE: DESLIGAR VMS NO LAB
# =======================================================================
 
# 1. Variáveis do seu Ambiente (Substitua pelos dados exatos do seu Portal)
$SubscriptionId    = "421b4834-3fad-4266-8eb1-8c75f2c5d556" # Garante que vai achar o RG
$ResourceGroupName = "rg-teste-automation-account-rotation"
$VM01_Name         = "vm01" # Verifique se no portal está exatamente "vm1"
$VM02_Name         = "vm02"
 
# Mudamos para Stop para o seu teste de desligamento
$Acao              = "Stop" 
 
# 2. Autenticação no Azure via Managed Identity
Write-Output "Iniciando autenticação no Azure via Managed Identity..."
try {
    Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "Autenticação realizada com sucesso!"
    
    # Define explicitamente a assinatura do Lab para não dar "Resource not found"
    Write-Output "Definindo o contexto para a Subscription: $SubscriptionId"
    Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
}
catch {
    Write-Error "Falha na autenticação ou definição de contexto: $_"
    throw $_
}
 
# 3. Execução do Desligamento
$VMs = @($VM01_Name, $VM02_Name)
 
foreach ($VM in $VMs) {
    if ($Acao -eq "Start") {
        Write-Output "Enviando comando para LIGAR a VM: $VM no RG: $ResourceGroupName..."
        Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VM -NoWait
    }
    else {
        Write-Output "Enviando comando para DESLIGAR (Deallocate) a VM: $VM no RG: $ResourceGroupName..."
        Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VM -Force -NoWait
    }
}
 
Write-Output "Comandos de parada enviados!"
