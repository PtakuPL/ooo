<?php

use Twig\Environment;
use Twig\Error\LoaderError;
use Twig\Error\RuntimeError;
use Twig\Extension\CoreExtension;
use Twig\Extension\SandboxExtension;
use Twig\Markup;
use Twig\Sandbox\SecurityError;
use Twig\Sandbox\SecurityNotAllowedTagError;
use Twig\Sandbox\SecurityNotAllowedFilterError;
use Twig\Sandbox\SecurityNotAllowedFunctionError;
use Twig\Source;
use Twig\Template;
use Twig\TemplateWrapper;

/* forum.admin.links.html.twig */
class __TwigTemplate_0114327d3c5e89f4f7504226d5b2b151 extends Template
{
    private Source $source;
    /**
     * @var array<string, Template>
     */
    private array $macros = [];

    public function __construct(Environment $env)
    {
        parent::__construct($env);

        $this->source = $this->getSourceContext();

        $this->parent = false;

        $this->blocks = [
        ];
    }

    protected function doDisplay(array $context, array $blocks = []): iterable
    {
        $macros = $this->macros;
        // line 1
        yield "<table>
\t<tr>
\t\t<td>
\t\t\t<form action=\"";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
        yield "\" method=\"post\" style=\"float: left\">
\t\t\t\t";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"edit_board\" />
\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
        // line 7
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["id"] ?? null), "html", null, true);
        yield "\" />
\t\t\t\t<button type=\"submit\" title=\"Edit\"><img src=\"images/edit.png\"/> Edit</button>
\t\t\t</form>

\t\t\t<form action=\"";
        // line 11
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
        yield "\" method=\"post\" style=\"float: left\">
\t\t\t\t";
        // line 12
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"delete_board\" />
\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
        // line 14
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["id"] ?? null), "html", null, true);
        yield "\" />
\t\t\t\t<button type=\"submit\" onclick=\"return confirm('Are you sure?');\" title=\"Delete\"><img src=\"images/del.png\"/>Delete</button>
\t\t\t</form>

\t\t\t<form action=\"";
        // line 18
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
        yield "\" method=\"post\" style=\"float: left\">
\t\t\t\t";
        // line 19
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"hide_board\" />
\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
        // line 21
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["id"] ?? null), "html", null, true);
        yield "\" />
\t\t\t\t<button type=\"submit\" title=\"";
        // line 22
        if ((($context["hide"] ?? null) != 1)) {
            yield "Hide";
        } else {
            yield "Show";
        }
        yield "\"><img src=\"images/";
        yield (((($context["hide"] ?? null) != 1)) ? ("success") : ("error"));
        yield ".png\"/>";
        yield (((($context["hide"] ?? null) != 1)) ? ("Hide") : ("Show"));
        yield "</button>
\t\t\t</form>

\t\t\t";
        // line 25
        if ((($context["i"] ?? null) != 1)) {
            // line 26
            yield "\t\t\t\t<form action=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
            yield "\" method=\"post\" style=\"float: left\">
\t\t\t\t\t";
            // line 27
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"moveup_board\" />
\t\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
            // line 29
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["id"] ?? null), "html", null, true);
            yield "\" />
\t\t\t\t\t<button type=\"submit\" title=\"Move up\"><img src=\"images/icons/arrow_up.gif\"/>Move up</button>
\t\t\t\t</form>
\t\t\t";
        }
        // line 33
        yield "\t\t\t";
        if ((($context["i"] ?? null) != CoreExtension::getAttribute($this->env, $this->source, ($context["loop"] ?? null), "last", [], "any", false, false, false, 33))) {
            // line 34
            yield "\t\t\t\t<form action=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
            yield "\" method=\"post\" style=\"float: left\">
\t\t\t\t\t";
            // line 35
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"movedown_board\" />
\t\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
            // line 37
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["id"] ?? null), "html", null, true);
            yield "\" />
\t\t\t\t\t<button type=\"submit\" title=\"Move down\"><img src=\"images/icons/arrow_down.gif\"/>Move down</button>
\t\t\t\t</form>
\t\t\t";
        }
        // line 41
        yield "\t\t</td>
\t</tr>
</table>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "forum.admin.links.html.twig";
    }

    /**
     * @codeCoverageIgnore
     */
    public function isTraitable(): bool
    {
        return false;
    }

    /**
     * @codeCoverageIgnore
     */
    public function getDebugInfo(): array
    {
        return array (  145 => 41,  138 => 37,  133 => 35,  128 => 34,  125 => 33,  118 => 29,  113 => 27,  108 => 26,  106 => 25,  92 => 22,  88 => 21,  83 => 19,  79 => 18,  72 => 14,  67 => 12,  63 => 11,  56 => 7,  51 => 5,  47 => 4,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "forum.admin.links.html.twig", "/var/www/html/system/templates/forum.admin.links.html.twig");
    }
}
