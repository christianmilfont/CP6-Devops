#!/usr/bin/env bash
set -euo pipefail

# ================================
# CONFIGURAÇÕES PRINCIPAIS
# ================================
APP_NAME="cp6dotnet"
RESOURCE_GROUP="rg-${APP_NAME}"
LOCATION="eastus"

ACI_APP_NAME="${APP_NAME}-app"
ACI_DB_NAME="${APP_NAME}-db"

# Gera sufixo aleatório para nomes únicos
SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w5 | head -n1)
ACR_NAME="${APP_NAME}acr${SUFFIX}"
IMAGE_NAME="${ACR_NAME}.azurecr.io/${APP_NAME}:latest"

# Portas
APP_PORT=8080
MYSQL_PORT=3306

# MySQL
MYSQL_ROOT_PASSWORD="Senha123!"
MYSQL_DATABASE="ProjetoAutorLivroDb"

# ================================
# LOGIN NO AZURE
# ================================
echo "🔐 Verificando login no Azure..."
az account show &>/dev/null || az login

# ================================
# CRIAR RESOURCE GROUP
# ================================
echo "📁 Criando Resource Group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" 1>/dev/null

# ================================
# CRIAR ACR
# ================================
echo "📦 Criando Azure Container Registry (ACR)..."
az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_NAME" \
  --sku Basic \
  --admin-enabled true 1>/dev/null

# Captura credenciais do ACR
ACR_USERNAME=$(az acr credential show -n "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show -n "$ACR_NAME" --query passwords[0].value -o tsv)

# ================================
# BUILD DO APP .NET DIRETO NO ACR (ACR Tasks)
# ================================
echo "⚙️  Buildando imagem da aplicação no ACR (ACR Tasks)..."
az acr build \
  --registry "$ACR_NAME" \
  --image "${APP_NAME}:latest" \
  .

# ================================
# CRIAR MYSQL NO ACI
# ================================
echo "🛢️ Criando container do MySQL..."
az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_DB_NAME" \
  --image "mysql:8.0" \
  --cpu 1 --memory 1.5 \
  --ip-address public \
  --ports "$MYSQL_PORT" \
  --environment-variables \
      MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
      MYSQL_DATABASE="$MYSQL_DATABASE" \
  --restart-policy Always \
  --os-type Linux

echo "⏳ Aguardando MySQL inicializar (60s)..."
sleep 60

# ================================
# CRIAR APLICAÇÃO .NET NO ACI
# ================================
echo "🚀 Criando container da aplicação .NET..."
az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACI_APP_NAME" \
  --image "$IMAGE_NAME" \
  --cpu 1 --memory 1.5 \
  --ip-address public \
  --ports "$APP_PORT" \
  --registry-login-server "${ACR_NAME}.azurecr.io" \
  --registry-username "$ACR_USERNAME" \
  --registry-password "$ACR_PASSWORD" \
  --environment-variables \
      ASPNETCORE_ENVIRONMENT=Production \
      ConnectionStrings__DefaultConnection="server=${ACI_DB_NAME};port=${MYSQL_PORT};database=${MYSQL_DATABASE};user=root;password=${MYSQL_ROOT_PASSWORD};SslMode=None;" \
  --os-type Linux

echo "⏳ Aguardando aplicação subir (60s)..."
sleep 60

# ================================
# RESULTADOS
# ================================
APP_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_APP_NAME" --query ipAddress.ip -o tsv)
DB_IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$ACI_DB_NAME" --query ipAddress.ip -o tsv)

echo ""
echo "=========================================="
echo "✅ Deploy concluído!"
echo "🌐 API:       http://$APP_IP:$APP_PORT"
echo "🧠 Banco:     $DB_IP:$MYSQL_PORT"
echo ""
echo "📄 Para ver logs da aplicação:"
echo "az container logs --resource-group $RESOURCE_GROUP --name $ACI_APP_NAME"
echo "=========================================="
