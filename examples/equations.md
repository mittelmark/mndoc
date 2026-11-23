
# Equations display demo

This    is   an    example    to    show    the   use   of   the    Javascript
[MathJax](https://www.mathjax.org/) library which can be used to display LaTeX
math equations within Markdown documents.

## Document creation

The Markdown file can be converted with Equation parsing like this:

```
mndoc example.md example.html --mathjax true
```

## Inline Equations

Simple  Equations  can be  inline  within  the text  using  the backslash
parenthesis syntax like here:

```
    The  famous  Einstein  equations  \( E = mc^2 \) is  probably  the most known
    equation world wide.
```

The output is this:

The  famous  Einstein  equations  \( E = mc^2 \) is  probably  the most known
equation world wide.

## Block Equations

Block  equations can be embedded within brackets  protected by two backslashes
or within two starting and two ending dollar signs like in the examples below:


```
\[ \sum_{i=0}^n i^2 =  \frac{(n^2+n)(2n+1)}{6} \tag{1} \] 
```

and here the output:

\[ \sum_{i=0}^n i^2 =  \frac{(n^2+n)(2n+1)}{6} \tag{1} \] 

As you can see the  alignment  to the  center  does not  really  look nice. So
there is style  command for the  division tag of class left which aligns the equation to the
left which is probably  better to read. So you wrap your equation  within this
div tag to make it left aligned:

```
<div style="display: flex;>

$$\sum_{i=0}^n i^2 = \frac{(n^2+n)(2n+1)}{6} \tag{2}$$

</div>
```


And here the output:

<div style="display: flex;">
$$\sum_{i=0}^n i^2 = \frac{(n^2+n)(2n+1)}{6} \tag{2}$$
</div>

That probably looks better than a centered  equation with the numbering at the
very end.

You can as well create a div class left in your  stylesheet  to just write the
classname in your div tag.

## Problems

Multiline blocks with $$ borders are supported as well.

$$
E = mc^2
$$

The following equation is more involved:

The Formula for the geometric mean \(gm\) is :

$$
\left(\prod_{i=1}^{n} x_i\right)^{1/n}
$$

It uses underscores and subscripts within a multiline display block.

## Some more equations

The well known Pythagorean theorem \(x^2 + y^2 = z^2\) was 
proved to be invalid for other exponents. 
Meaning the next equation has no integer solutions:

\[ x^n + y^n = z^n \]

Same formula but opening and closing on different lines:

\[ 
x^n + y^n = z^n 
\]

Works as well.

Two equations on the same line \( x = 3 \) and \( y = 4 \).

Now the same with single dollars $x = 3$ and $y = 4$. 

## Backward compatibility:

Does \\(E = mc^2\\) render correctly?

Or:

\\[
E = mc^2
\\]

## End
