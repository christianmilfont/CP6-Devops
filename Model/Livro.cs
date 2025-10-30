namespace CP6_DotNet.Model
{
    public class Livro
    {
        public int Id { get; set; }
        public string Titulo { get; set; }
 
        // Autor opcional
        public int? AutorId { get; set; }
        public Autor Autor { get; set; }
    }
}
