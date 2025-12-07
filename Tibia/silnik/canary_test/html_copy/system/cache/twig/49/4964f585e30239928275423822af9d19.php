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

/* admin.news.table.html.twig */
class __TwigTemplate_183851dd4aa336269f62a350fb71e356 extends Template
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
        yield "<div class=\"card card-info card-outline\">
\t<div class=\"card-header\">
\t\t<h5 class=\"m-0\">";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["title"] ?? null), "html", null, true);
        yield ":
\t\t\t<form method=\"post\" class=\"float-right\">
\t\t\t\t";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"new\" />
\t\t\t\t<input type=\"hidden\" name=\"type\" value=\"";
        // line 7
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["type"] ?? null), "html", null, true);
        yield "\" />
\t\t\t\t<button type=\"submit\" class=\"btn btn-sm btn-success\">New</button>
\t\t\t</form>
\t\t</h5>
\t</div>

\t<div class=\"card-body\">
\t\t<table class=\"tb_datatable table table-striped table-bordered table-responsive d-md-table\">
\t\t\t<thead>
\t\t\t<tr>
\t\t\t\t<th width=\"5%\">ID</th>
\t\t\t\t<th>Title</th>
\t\t\t\t<th>Date</th>
\t\t\t\t<th>Player</th>
\t\t\t\t<th style=\"width: 150px;\">Options</th>
\t\t\t</tr>
\t\t\t</thead>
\t\t\t<tbody>
\t\t\t";
        // line 25
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable((($_v0 = ($context["newses"] ?? null)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0[($context["type"] ?? null)] ?? null) : null));
        foreach ($context['_seq'] as $context["_key"] => $context["news"]) {
            // line 26
            yield "\t\t\t\t<tr>
\t\t\t\t\t<td>";
            // line 27
            yield CoreExtension::getAttribute($this->env, $this->source, $context["news"], "id", [], "any", false, false, false, 27);
            yield "</td>
\t\t\t\t\t<td>
\t\t\t\t\t\t<i>
\t\t\t\t\t\t\t<a href=\"";
            // line 30
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("news"), "html", null, true);
            yield "/";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["news"], "id", [], "any", false, false, false, 30), "html", null, true);
            yield "\" target=\"_blank\">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["news"], "title", [], "any", false, false, false, 30), "html", null, true);
            yield "</a>
\t\t\t\t\t\t</i>
\t\t\t\t\t</td>
\t\t\t\t\t<td>";
            // line 33
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, $context["news"], "date", [], "any", false, false, false, 33), $this->env->getFunction('setting')->getCallable()("core.news_date_format")), "html", null, true);
            yield "</td>
\t\t\t\t\t<td><a target=\"_blank\" href=\"";
            // line 34
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["news"], "player_link", [], "any", false, false, false, 34), "html", null, true);
            yield "\">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["news"], "player_name", [], "any", false, false, false, 34), "html", null, true);
            yield "</a></td>
\t\t\t\t\t<td>
\t\t\t\t\t\t<div class=\"btn-group\">
\t\t\t\t\t\t\t<form method=\"post\">
\t\t\t\t\t\t\t\t";
            // line 38
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"edit\" />
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
            // line 40
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["news"], "id", [], "any", false, false, false, 40), "html", null, true);
            yield "\" />
\t\t\t\t\t\t\t\t<button type=\"submit\" class=\"btn btn-success btn-sm\" title=\"Edit\"><i class=\"fas fa-pencil-alt\"></i></button>
\t\t\t\t\t\t\t</form>

\t\t\t\t\t\t\t<form method=\"post\">
\t\t\t\t\t\t\t\t";
            // line 45
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"delete\" />
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
            // line 47
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["news"], "id", [], "any", false, false, false, 47), "html", null, true);
            yield "\" />
\t\t\t\t\t\t\t\t<button type=\"submit\" class=\"btn btn-danger btn-sm\" onclick=\"return confirm('Are you sure?');\" title=\"Delete\"><i class=\"fas fa-trash\"></i></button>
\t\t\t\t\t\t\t</form>

\t\t\t\t\t\t\t<form method=\"post\">
\t\t\t\t\t\t\t\t";
            // line 52
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"hide\" />
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
            // line 54
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["news"], "id", [], "any", false, false, false, 54), "html", null, true);
            yield "\" />
\t\t\t\t\t\t\t\t<button type=\"submit\" class=\"btn btn-";
            // line 55
            yield (((CoreExtension::getAttribute($this->env, $this->source, $context["news"], "hide", [], "any", false, false, false, 55) != 1)) ? ("info") : ("default"));
            yield " btn-sm\" title=\"";
            if ((CoreExtension::getAttribute($this->env, $this->source, $context["news"], "hide", [], "any", false, false, false, 55) != 1)) {
                yield "Hide";
            } else {
                yield "Show";
            }
            yield "\"><i class=\"fas fa-eye";
            yield (((CoreExtension::getAttribute($this->env, $this->source, $context["news"], "hide", [], "any", false, false, false, 55) != 1)) ? ("") : ("-slash"));
            yield "\"></i></button>
\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t</div>
\t\t\t\t\t</td>
\t\t\t\t</tr>
\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['news'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 61
        yield "\t\t\t</tbody>
\t\t</table>
\t</div>
</div>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "admin.news.table.html.twig";
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
        return array (  168 => 61,  148 => 55,  144 => 54,  139 => 52,  131 => 47,  126 => 45,  118 => 40,  113 => 38,  104 => 34,  100 => 33,  90 => 30,  84 => 27,  81 => 26,  77 => 25,  56 => 7,  51 => 5,  46 => 3,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "admin.news.table.html.twig", "/var/www/html/system/templates/admin.news.table.html.twig");
    }
}
