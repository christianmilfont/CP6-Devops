using CP6_DotNet.Context;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// =====================
// Serviços (Dependency Injection)
// =====================

// Configurando o DbContext com MySQL
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        new MySqlServerVersion(new Version(8, 0, 36))
    ));

// Adicionando os controllers
builder.Services.AddControllers();

// Configurando o Swagger / OpenAPI
builder.Services.AddEndpointsApiExplorer(); // necessário para gerar endpoints no Swagger
builder.Services.AddSwaggerGen();           // habilita a interface Swagger UI

var app = builder.Build();

// =====================
// Pipeline de execução
// =====================

if (app.Environment.IsDevelopment())
{
    // Gera e exibe a documentação Swagger
    app.UseSwagger();     // gera o JSON do OpenAPI
    app.UseSwaggerUI();   // gera a interface web (Swagger UI)
}

// app.UseHttpsRedirection(); // opcional, dependendo se há SSL configurado
app.UseAuthorization();
app.MapControllers();

app.Run();
