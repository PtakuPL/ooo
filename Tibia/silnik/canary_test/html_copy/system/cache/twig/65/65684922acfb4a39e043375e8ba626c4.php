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

/* admin.plugins.html.twig */
class __TwigTemplate_f28fccfabb23b029bc8aa9871d483c2a extends Template
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
\t\t<h5 class=\"m-0\">Installed plugins<span class=\"float-right\"><a class=\"\" data-toggle=\"collapse\" href=\"#install_plugin\">Install Plugin</a></span></h5>
\t</div>
\t<div class=\"card-body\">
\t\t<table class=\"table table-striped table-bordered table-responsive d-md-table\" id=\"tb_plugins\">
\t\t\t<thead>
\t\t\t<tr>
\t\t\t\t<th>Enabled</th>
\t\t\t\t<th>Name</th>
\t\t\t\t<th>Version</th>
\t\t\t\t<th>Author</th>
\t\t\t\t<th>Filename</th>
\t\t\t\t<th style=\"width: 55px;\">Options</th>
\t\t\t</tr>
\t\t\t</thead>
\t\t\t<tbody>
\t\t\t";
        // line 18
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["plugins"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["plugin"]) {
            // line 19
            yield "\t\t\t\t<tr>
\t\t\t\t\t<td>
\t\t\t\t\t\t";
            // line 21
            if (CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "enabled", [], "any", false, false, false, 21)) {
                // line 22
                yield "\t\t\t\t\t\t\t<form method=\"post\">
\t\t\t\t\t\t\t\t";
                // line 23
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
                yield "
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"disable\" value=\"";
                // line 24
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "file", [], "any", false, false, false, 24), "html", null, true);
                yield "\" />
\t\t\t\t\t\t\t\t<button type=\"submit\" class=\"btn btn-success\" onclick=\"return confirm('Are you sure you want to disable plugin ";
                // line 25
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "name", [], "any", false, false, false, 25), "html", null, true);
                yield "?');\" title=\"Disable\"><i class=\"fas fa-check\"></i> Enabled</button>
\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t";
            } else {
                // line 28
                yield "\t\t\t\t\t\t\t<form method=\"post\">
\t\t\t\t\t\t\t\t";
                // line 29
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
                yield "
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"enable\" value=\"";
                // line 30
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "file", [], "any", false, false, false, 30), "html", null, true);
                yield "\" />
\t\t\t\t\t\t\t\t<button type=\"submit\" class=\"btn btn-danger\" onclick=\"return confirm('Are you sure you want to enable plugin ";
                // line 31
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "name", [], "any", false, false, false, 31), "html", null, true);
                yield "?');\" title=\"Enable\"><i class=\"fas fa-ban\"></i> Disabled</button>
\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t";
            }
            // line 34
            yield "\t\t\t\t\t</td>
\t\t\t\t\t<td><b>";
            // line 35
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "name", [], "any", false, false, false, 35), "html", null, true);
            yield "</b><br>
\t\t\t\t\t\t<small>";
            // line 36
            yield CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "description", [], "any", false, false, false, 36);
            yield "</small>
\t\t\t\t\t</td>
\t\t\t\t\t<td>";
            // line 38
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "version", [], "any", false, false, false, 38), "html", null, true);
            yield "</td>
\t\t\t\t\t<td><b>";
            // line 39
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "author", [], "any", false, false, false, 39), "html", null, true);
            yield "</b><br>
\t\t\t\t\t\t<small>";
            // line 40
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "contact", [], "any", false, false, false, 40), "html", null, true);
            yield "</small>
\t\t\t\t\t</td>
\t\t\t\t\t<td>";
            // line 42
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "file", [], "any", false, false, false, 42), "html", null, true);
            yield ".json</td>
\t\t\t\t\t<td>
\t\t\t\t\t\t";
            // line 44
            if (CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "uninstall", [], "any", false, false, false, 44)) {
                // line 45
                yield "\t\t\t\t\t\t\t<form method=\"post\">
\t\t\t\t\t\t\t\t";
                // line 46
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
                yield "
\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"uninstall\" value=\"";
                // line 47
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "file", [], "any", false, false, false, 47), "html", null, true);
                yield "\" />
\t\t\t\t\t\t\t\t<button type=\"submit\" class=\"btn btn-danger btn-sm\" onclick=\"return confirm('Are you sure you want to uninstall ";
                // line 48
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["plugin"], "name", [], "any", false, false, false, 48), "html", null, true);
                yield "?');\" title=\"Uninstall\"><i class=\"fas fa-trash\"></i></button>
\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t";
            }
            // line 51
            yield "\t\t\t\t\t</td>
\t\t\t\t</tr>
\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['plugin'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 54
        yield "\t\t\t</tbody>
\t\t</table>
\t</div>
</div>

<script>
\t\$(function () {
\t\t\$('#tb_plugins').DataTable();
\t})
</script>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "admin.plugins.html.twig";
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
        return array (  162 => 54,  154 => 51,  148 => 48,  144 => 47,  140 => 46,  137 => 45,  135 => 44,  130 => 42,  125 => 40,  121 => 39,  117 => 38,  112 => 36,  108 => 35,  105 => 34,  99 => 31,  95 => 30,  91 => 29,  88 => 28,  82 => 25,  78 => 24,  74 => 23,  71 => 22,  69 => 21,  65 => 19,  61 => 18,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "admin.plugins.html.twig", "/var/www/html/system/templates/admin.plugins.html.twig");
    }
}
