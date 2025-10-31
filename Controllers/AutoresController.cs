using CP6_DotNet.Context;
using CP6_DotNet.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
 
namespace CP6_DotNet.Controllers

{

    [Route("api/[controller]")]

    [ApiController]

    public class AutoresController : ControllerBase

    {

        private readonly AppDbContext _context;
 
        public AutoresController(AppDbContext context)

        {

            _context = context;

        }
 
        // GET: api/Autor

        [HttpGet]

        public async Task<ActionResult<IEnumerable<Autor>>> GetAutores()

        {

            return await _context.Autores.Include(a => a.Livros).ToListAsync();

        }
 
        // GET: api/Autor/5

        [HttpGet("{id}")]

        public async Task<ActionResult<Autor>> GetAutor(int id)

        {

            var autor = await _context.Autores.Include(a => a.Livros)

                                             .FirstOrDefaultAsync(a => a.Id == id);
 
            if (autor == null)

                return NotFound();
 
            return autor;

        }
 
        [HttpPost]
        public async Task<ActionResult<Autor>> PostAutor([FromBody] Autor autor)
        {
            if (autor.Livros != null)
            {
                foreach (var livro in autor.Livros)
                {
                    livro.Id = 0;           // garante que o EF insira como novo
                    livro.AutorId = 0;      // será setado automaticamente pelo EF
                    livro.Autor = autor;     // vincula o livro ao autor
                }
            }
        
            _context.Autores.Add(autor);
            await _context.SaveChangesAsync();
        
            return CreatedAtAction(nameof(GetAutor), new { id = autor.Id }, autor);
        }
 
        // PUT: api/Autor/5

        [HttpPut("{id}")]

        public async Task<IActionResult> PutAutor(int id, Autor autor)

        {

            if (id != autor.Id)

                return BadRequest();
 
            _context.Entry(autor).State = EntityState.Modified;
 
            try

            {

                await _context.SaveChangesAsync();

            }

            catch (DbUpdateConcurrencyException)

            {

                if (!_context.Autores.Any(a => a.Id == id))

                    return NotFound();

                else

                    throw;

            }
 
            return NoContent();

        }
 
        // DELETE: api/Autor/5

        [HttpDelete("{id}")]

        public async Task<IActionResult> DeleteAutor(int id)

        {

            var autor = await _context.Autores.FindAsync(id);

            if (autor == null)

                return NotFound();
 
            _context.Autores.Remove(autor);

            await _context.SaveChangesAsync();
 
            return NoContent();

        }

    }
}
