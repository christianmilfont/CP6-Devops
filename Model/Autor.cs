namespace CP6_DotNet.Model
{
    public class Autor
    {
        public int Id { get; set; }
        public string Nome { get; set; }
        public List<Livro> Livros { get; set; } // Relacionamento um-para-muitos
    }
}
