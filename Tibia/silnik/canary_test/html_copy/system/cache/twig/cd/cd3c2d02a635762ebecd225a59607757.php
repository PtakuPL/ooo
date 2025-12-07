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

/* coins.html.twig */
class __TwigTemplate_1fe67230146ac958a8f1240fa5f82b35 extends Template
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
        if (is_iterable(($context["coins"] ?? null))) {
            // line 2
            yield "\t<div class=\" col-md-6 col-lg-3\">
\t\t<div class=\"card card-info card-outline\">
\t\t\t<div class=\"card-header\">
\t\t\t\t<h5 class=\"m-0\">Top 10 - Most coins</h5>
\t\t\t</div>
\t\t\t<div class=\"card-body p-0\">
\t\t\t\t<table class=\"table table-striped table-condensed\">
\t\t\t\t\t<thead>
\t\t\t\t\t<tr>
\t\t\t\t\t\t<th>#</th>
\t\t\t\t\t\t<th>Account</th>
\t\t\t\t\t\t<th>Tibia coins</th>
\t\t\t\t\t</tr>
\t\t\t\t\t</thead>
\t\t\t\t\t<tbody>
\t\t\t\t\t";
            // line 17
            $context["i"] = 0;
            // line 18
            yield "\t\t\t\t\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["coins"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["result"]) {
                // line 19
                yield "\t\t\t\t\t\t";
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 20
                yield "\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t<th>";
                // line 21
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
                yield "</th>
\t\t\t\t\t\t\t<td><a href=\"?p=accounts&id=";
                // line 22
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["result"], "id", [], "any", false, false, false, 22), "html", null, true);
                yield "\">";
                yield (((CoreExtension::getAttribute($this->env, $this->source, $context["result"], "name", [], "any", true, true, false, 22) &&  !(null === CoreExtension::getAttribute($this->env, $this->source, $context["result"], "name", [], "any", false, false, false, 22)))) ? ($this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["result"], "name", [], "any", false, false, false, 22), "html", null, true)) : ($this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["result"], "id", [], "any", false, false, false, 22), "html", null, true)));
                yield "</a></td>
\t\t\t\t\t\t\t<td>";
                // line 23
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["result"], "coins", [], "any", false, false, false, 23), "html", null, true);
                yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['result'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 26
            yield "\t\t\t\t\t</tbody>
\t\t\t\t</table>
\t\t\t</div>
\t\t</div>
\t</div>
";
        }
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "coins.html.twig";
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
        return array (  93 => 26,  84 => 23,  78 => 22,  74 => 21,  71 => 20,  68 => 19,  63 => 18,  61 => 17,  44 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "coins.html.twig", "/var/www/html/admin/pages/modules/templates/coins.html.twig");
    }
}
