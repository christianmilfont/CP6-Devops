namespace CP6_DotNet.Model
{
    public class Livro
    {
        public int Id { get; set; }
        public string Titulo { get; set; }
        public int AutorId { get; set; }  // Chave estrangeira
        public Autor Autor { get; set; } // Relacionamento com o Autor
    }
}
