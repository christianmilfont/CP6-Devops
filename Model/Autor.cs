namespace CP6_DotNet.Model
{
    public class Autor
    {
        public int Id { get; set; }
        public string Nome { get; set; }
 
        // Um Autor pode ter zero ou mais livros
        public ICollection<Livro> Livros { get; set; } = new List<Livro>();
    }
}
