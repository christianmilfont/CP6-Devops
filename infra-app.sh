#!/usr/bin/env bash
set -euo pipefail
 
# ==========================
# Parâmetros da Conexão MySQL
# ==========================
DbHost="${DbHost:-48.217.203.215}"
DbPort="${DbPort:-3306}"
DbName="${DbName:-ProjetoAutorLivroDb}"
DbUser="${DbUser:-root}"
DbPass="${DbPass:-Senha123!}"
 
# =======================
# Validação do cliente MySQL
# =======================
if ! command -v mysql >/dev/null 2>&1; then
  echo "ERRO: cliente 'mysql' não encontrado. Instale-o antes de executar este script."
  exit 1
fi
 
# =======================
# Criar banco de dados se não existir
# =======================
echo "Criando banco de dados '$DbName' se não existir..."
mysql --protocol=TCP -h"$DbHost" -P"$DbPort" -u"$DbUser" -p"$DbPass" \
  -e "CREATE DATABASE IF NOT EXISTS \`$DbName\`;"
 
# =======================
# Criar tabelas se não existirem
# =======================
echo "Criando tabelas se não existirem..."
mysql --protocol=TCP -h"$DbHost" -P"$DbPort" -u"$DbUser" -p"$DbPass" "$DbName" <<'SQL'
CREATE TABLE IF NOT EXISTS Autores (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Nome VARCHAR(255) NOT NULL
);
 
CREATE TABLE IF NOT EXISTS Livros (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Titulo VARCHAR(255) NOT NULL,
  AutorId INT NOT NULL,
  CONSTRAINT FK_Livros_Autores
    FOREIGN KEY (AutorId)
    REFERENCES Autores(Id)
    ON DELETE CASCADE
);

 
-- Verifica se o índice já existe
SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS 
WHERE table_schema = DATABASE() AND table_name = 'Livros' AND index_name = 'IX_Livros_AutoresId' LIMIT 1;
 
-- Se não existir, cria o índice
CREATE INDEX IX_Livro_AutoresId ON Livros (AutoresId);
SQL
 
echo "[OK] Banco e tabelas prontos"
 
# =======================
# Azure WebApp (mantido)
# =======================
rg="rg-api-dotnet"
location=${LOCATION:-"eastus"}
plan="planApiDotnet"
app=${NOME_WEBAPP:-"meu-app-dotnet"}
runtime="dotnet:8"
sku="F1"
 
echo "Criando Grupo de Recursos se não existir..."
az group create --name "$rg" --location "$location" 1>/dev/null
 
echo "Criando Plano de Serviço se não existir..."
az appservice plan create --name "$plan" --resource-group "$rg" --location "$location" --sku "$sku" 1>/dev/null
 
echo "Criando Serviço de Aplicativo se não existir..."
az webapp create --resource-group "$rg" --plan "$plan" --runtime "$runtime" --name "$app" 1>/dev/null
 
# Configura logs apenas se necessário
app_logging="$(az webapp log show -g "$rg" -n "$app" --query 'applicationLogs.fileSystem.level' -o tsv 2>/dev/null || true)"
ws_logging="$(az webapp log show -g "$rg" -n "$app" --query 'httpLogs.fileSystem.enabled' -o tsv 2>/dev/null || true)"
det_errors="$(az webapp log show -g "$rg" -n "$app" --query 'detailedErrorMessages.enabled' -o tsv 2>/dev/null || true)"
failed_req="$(az webapp log show -g "$rg" -n "$app" --query 'failedRequestsTracing.enabled' -o tsv 2>/dev/null || true)"
 
if [ "$app_logging" != "Information" ] || [ "$ws_logging" != "true" ] || [ "$det_errors" != "true" ] || [ "$failed_req" != "true" ]; then
  echo "Habilitando Logs do Serviço de Aplicativo..."
  az webapp log config \
    --resource-group "$rg" \
    --name "$app" \
    --application-logging filesystem \
    --web-server-logging filesystem \
    --level information \
    --detailed-error-messages true \
    --failed-request-tracing true 1>/dev/null
else
  echo "Logs já configurados"
fi
 
echo "[OK] Azure WebApp configurado"
