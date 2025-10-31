using CP6_DotNet.Context;
using CP6_DotNet.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
 
namespace CP6_DotNet.Controllers
{
[Route("api/[controller]")]
    [ApiController]
    public class LivroController : ControllerBase
    {
        private readonly AppDbContext _context;
 
        public LivroController(AppDbContext context)
        {
            _context = context;
        }
 
        // GET: api/Livro
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Livro>>> GetLivros()
        {
            return await _context.Livros.Include(l => l.Autor).ToListAsync();
        }
 
        // GET: api/Livro/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Livro>> GetLivro(int id)
        {
            var livro = await _context.Livros.Include(l => l.Autor)
                                             .FirstOrDefaultAsync(l => l.Id == id);
 
            if (livro == null)
                return NotFound();
 
            return livro;
        }
 
        // POST: api/Livro
        [HttpPost]
        public async Task<ActionResult<Livro>> PostLivro(Livro livro)
        {
            _context.Livros.Add(livro);
            await _context.SaveChangesAsync();
 
            return CreatedAtAction(nameof(GetLivro), new { id = livro.Id }, livro);
        }
 
        // PUT: api/Livro/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutLivro(int id, Livro livro)
        {
            if (id != livro.Id)
                return BadRequest();
 
            _context.Entry(livro).State = EntityState.Modified;
 
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.Livros.Any(l => l.Id == id))
                    return NotFound();
                else
                    throw;
            }
 
            return NoContent();
        }
 
        // DELETE: api/Livro/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteLivro(int id)
        {
            var livro = await _context.Livros.FindAsync(id);
            if (livro == null)
                return NotFound();
 
            _context.Livros.Remove(livro);
            await _context.SaveChangesAsync();
 
            return NoContent();
        }
    }
}
