using Microsoft.EntityFrameworkCore;
using CP6_DotNet.Model;
 
namespace CP6_DotNet.Context
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
 
        public DbSet<Autor> Autores { get; set; }
        public DbSet<Livro> Livros { get; set; }
 
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
 
            // Relacionamento opcional
            modelBuilder.Entity<Livro>()
                        .HasOne(l => l.Autor)
                        .WithMany(a => a.Livros)
                        .HasForeignKey(l => l.AutorId)
                        .OnDelete(DeleteBehavior.SetNull); // se o autor for deletado, o livro permanece sem autor
        }
    }
}
