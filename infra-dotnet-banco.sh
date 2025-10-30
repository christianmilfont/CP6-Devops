#!/usr/bin/env bash
set -euo pipefail

# ================================
# CONFIGURAÇÕES PRINCIPAIS
# ================================
APP_NAME="cp6dotnet"
RESOURCE_GROUP="rg-${APP_NAME}-db-only"
LOCATION="eastus"
ACI_DB_NAME="${APP_NAME}-db"
MYSQL_PORT=3306

# MySQL
MYSQL_ROOT_PASSWORD="Senha123!"
MYSQL_DATABASE="ProjetoAutorLivroDb"

# Gera sufixo aleatório para nomes únicos
SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | fold -w5 | head -n1)
ACR_NAME="${APP_NAME}acr${SUFFIX}"

# ================================
# LOGIN E RESOURCE GROUP
# ================================
echo "🔐 Verificando login no Azure..."
az account show &>/dev/null || az login

echo "📁 Criando Resource Group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" 1>/dev/null

# ================================
# ACR - Azure Container Registry
# ================================
echo "📦 Criando Azure Container Registry (ACR)..."
az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_NAME" \
  --sku Basic \
  --admin-enabled false 1>/dev/null

# Habilitar admin no ACR
az acr update -n "$ACR_NAME" --admin-enabled true

# Captura credenciais do ACR
ACR_USERNAME=$(az acr credential show -n "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show -n "$ACR_NAME" --query passwords[0].value -o tsv)

# ================================
# IMPORTAR IMAGEM MYSQL PARA O ACR
# ================================
echo "📥 Importando imagem MySQL para o ACR..."
az acr import \
  --name "$ACR_NAME" \
  --source docker.io/library/mysql:8.0 \
  --image mysql:8.0

# ================================
# LIMPAR CONTAINER ANTIGO
# ================================
echo "🧹 Removendo container MySQL antigo (se existir)..."
az container delete --name "$ACI_DB_NAME" --resource-group "$RESOURCE_GROUP" --yes || true
sleep 10

# ================================
# CRIAR MYSQL NO ACI
# ================================
echo "🛢️ Criando container MySQL..."
az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_DB_NAME" \
  --image "${ACR_NAME}.azurecr.io/mysql:8.0" \
  --cpu 1 --memory 1.5 \
  --ip-address public \
  --ports $MYSQL_PORT \
  --registry-login-server "${ACR_NAME}.azurecr.io" \
  --registry-username "$ACR_USERNAME" \
  --registry-password "$ACR_PASSWORD" \
  --environment-variables \
    MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
    MYSQL_DATABASE="$MYSQL_DATABASE" \
  --restart-policy Always \
  --os-type Linux

echo "⏳ Aguardando MySQL inicializar (60s)..."
sleep 60

# ================================
# EXIBIR RESULTADOS
# ================================
DB_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_DB_NAME" --query ipAddress.ip -o tsv)

echo ""
echo "=========================================="
echo "✅ Deploy do MySQL concluído!"
echo "🧠 Banco: $DB_IP:$MYSQL_PORT"
echo ""
echo "📄 Para ver logs do MySQL:"
echo "az container logs --resource-group $RESOURCE_GROUP --name $ACI_DB_NAME"
echo "=========================================="
