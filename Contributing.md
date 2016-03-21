
`1040.js.m4` is the main web page and Javascript. The original author (BK) is basically a
novice with DOM+HTML+CSS, and there are certainly easy ways to make major improvements
here.

The whole thing is put together via m4. If you have anything even vaguely POSIX-compliant,
you have m4. Just type `make` on the command line to assemble the parts into tax.html.
If you are using Windows, you will need to install [Cygwin](https://www.cygwin.com/) first
to get the required tools.

The tax logic is encoded in a list of cells, which should be easy to modify or add to.

For example, here is a key line, Adjusted Gross Income:

`Cell(AGI, 37, Adjusted gross income, <|CV(total_in) - CV(subtractions_from_income)|>)`

This cell has five parts, one of which is empty.

* The cell name, to be used in other references. As a variable name, it should have no
spaces or odd characters.
* The line number, currently used only for reference.
* The text from the tax form. <|If there are commas, please use these angle-pipe brackets,
    or else m4 will get very confused.|>
* <|The calculation|>. See below for what can go into the formula.
The formula _must_ be in those <|surrounding brackets|>. If you are doing something
more complicated than basic arithmetic, then this may be just a function call, and
write the function itself at the head of the file; see below.
* The classes for the cell. For example, a cell about rental income might read
`Cell(rr_in, 12, "Rental income", ,u have_rr)`. The `u` tag indicates user input, so the
formula is blank. The `have_rr` tag will be used to show/hide this cell if the user has
rents/royalties. As per the AGI example, this can be omitted if there are no tags. If
there is a `u` tag, the formula itself should be blank.

I (BK) add new forms by cutting and pasting the PDF contents into a text file, and then
editing that down into individual cells. It's a bit tedious, but not a long process,
especially given that almost all cells are data entry, a reference, trivial arithmetic,
or a max/min.

What goes into a formula
=====
Basic arithmetic is always available, but you will almost certainly need to use one or
more of the following macros.

CV=cell value, and you can use that function to refer to any other cell. With
one argument like `CV(mine_rescue_training_credit_carryback)`, it refers to a cell on
the current form. To refer to a cell on another form, use two arguments: `CV(f3800,
mine_rescue_training_credit_carryback)`.

You can also use `SUM(cell1, cell2, cell3,...)`. All the usual math, including max and
min, are also options. These will all be cells on the current form; you are stuck with
directly summing `CV`s if you need to refer to other forms.

`max(a, b)` and `min(a, b)` do what you expect.

`Situation(x)`: There are a number of binary options describing the filer's situation.
Favorites include:
`have_rr
over_65
spouse_over_65
itemizing`
Use this macro to pull the true/false status of the switch.

`IF(a, b, c)` expands to whatever the target language uses to express "if a then b,
else c". Note that this easily nests, like
`IF(Situation(over_65), "directly senior", IF(Situation(spouse_over_65), "senior spouse", "not senior"))`

`Fswitch((married, 0), (single, 12), 27)`: if filing status is married, 0; if it
is single, 12, otherwise 27. Options are:
`married
married filing jointly
single
head of household`
The macro requires that final catch-all option, even if you cover all four options.

Those cover the great majority of what is on a tax form, and if you stick to these
we'll have a programming-language-independent implementation of the tax code.  If you
need more, write a function and call it from the cell.

How dependencies are calculated
=====

m4 does it by searching the formula for instances of `CV(x)` and `SUM(y,z)`. If it finds
those, it indicates that the named cell depends on those elements. Thus, if you are doing
something complicated that hides the dependencies, you may want to add it to the
calculation in a trivial way, like `<|do_math_on_agi() + 0*CV(AGI)|>`.

Dependency tracking is why you need the <|angle-pipe brackets|>, by the way: without
them, the `CV` and `SUM` macros get expanded away, and the dependency-checker doesn't
see them; the brackets indicate that the text needs to be sent with `CV`s and `SUM`s
in place.

The two other macros
=====

`m4_form(f1040)` The form you are working on. Needed once at the top of the file.

`jsversion(<|  |>)` The goal is for cell definitions to be language-agnostic, which we
can do when the math is just sums, maxes, and mins, but most languages have different
rules for function definitions. If you are writing a function for a nontrivial cell
calculation, put the javascript version in this region. See f1040.m4 for an example.
Adding `pyversion(<|  |>)` is optional.

Anything that is not inside the parens of `Form`, `jsversion`, or `Cell` is ignored, so
feel free to leave comments between these elements.
