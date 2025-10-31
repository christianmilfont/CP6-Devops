using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
 
namespace CP6_DotNet.Model
{
    public class Livro
    {
        public int Id { get; set; }
        public string Titulo { get; set; }
 
        // Autor opcional
        public int? AutorId { get; set; }
 
        [ValidateNever]  // Impede validação do campo 'Autor' no POST/PUT
        public Autor Autor { get; set; }
    }
}
