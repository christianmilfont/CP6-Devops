# CP6 - DevOps
Este projeto faz parte do Challenge de DevOps (CP6) e tem como objetivo integrar infraestrutura automatizada, pipelines CI/CD no Azure DevOps e uma API .NET 9.0, aplicando práticas modernas de observabilidade, containerização e deployment contínuo.

# Tecnologias Utilizadas
Backend:


- .NET 9.0 (ASP.NET Core) — Framework moderno e de alto desempenho para construção da API principal.


- C# 12 — Linguagem base para a aplicação.


- Entity Framework Core — ORM para persistência e mapeamento do banco de dados.


- MySQL — Banco de dados relacional utilizado na aplicação. (EM NUVEM) - aci + acr


- Docker — Para empacotamento da aplicação e do banco em containers independentes.



# Infraestrutura e Automação
Scripts Shell (.sh)
O repositório contém dois scripts principais para automação do ambiente DevOps:


### infra-app.sh


Responsável por configurar toda a infraestrutura necessária para execução das pipelines no Azure DevOps. Desde criar um grupo de recursos com meu App Service e um Plano de Aplicativo para ele.

Automatiza tambem a criação do banco de dados e conexão com meu banco na nuvem Azure, além disso criação das tabelas são feitas por ele tambem.


Automatiza a criação de service connections, resource groups e registries.

```bash
chmod +x infra-pipeline-setup.sh
./infra-app.sh
```


### infra-dotnet-banco.sh


Faz o build local da imagem Docker do MySQL configurada para o projeto.


Realiza o login no Azure Container Registry (ACR).


Efetua o push da imagem para o repositório remoto no Azure.

Cria grupo de recursos, além de registrar a imagem a ser lançada.

```bash
chmod +x build-mysql-push-acr.sh
./infra-dotnet-banco.sh
```

## Script-bd-sql
Apenas contempla o script presente no nosso **infra-app.sh**, ele ja automatiza a criação do nosso Database e suas respectivas tabelas.

# Integração com Azure
A integração com o Azure DevOps permite:


- CI/CD automatizado feito com editor classico, utilizando as Tasks de Build & Tests.


- Build e deploy contínuo da API e do banco.


- Gestão de imagens via Azure Container Registry.


- Monitoramento de logs e métricas via Azure Monitor / Application Insights.


## Principais Serviços Azure:


Azure DevOps Pipelines


- Azure Container Registry (ACR)


- Azure App Service com um Plano de aplicativo, o qual meu script **infra-app.sh** é responsavel


- Azure CLI



## Estrutura do Repositório
```bash
CP6-Devops/
├── src/
│   └── Api/
│       ├── Controllers/
│       ├── Models/
│       ├── Program.cs
│       └── appsettings.json
├── docker/
│   └── mysql/
│       └── Dockerfile
├── pipelines/
│   └── azure-pipelines.yml
├── infra/
│   ├── infra-pipeline-setup.sh
│   └── build-mysql-push-acr.sh
└── README.md
```

## Como Executar Localmente


Clone o repositório:
```bash
git clone https://github.com/christianmilfont/CP6-Devops.git
cd CP6-Devops
dotnet run
```




Acesse a API localmente:
```bash
http://localhost:5000
```



## Objetivo do Projeto
Este projeto demonstra a aplicação prática dos conceitos de DevOps, incluindo:


- Automação de pipelines com Azure DevOps.


I- ntegração contínua e entrega contínua (CI/CD).


- Criação e versionamento de imagens Docker.


- Deploy automatizado em ambiente de nuvem.


- Integração com repositórios GitHub e ACR.



Sinta-se à vontade para usar como referência ou base para estudos.

Se quiser, posso gerar o arquivo README.md formatado e pronto para commit direto no seu repositório. Deseja que eu gere o arquivo e te envie para download?
