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

/* admin.links.html.twig */
class __TwigTemplate_2b29fec0586c38021476470b990ab05b extends Template
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
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["page"] ?? null), "html", null, true);
        yield "\" method=\"post\" style=\"float: left\">
\t\t\t\t";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"edit\" />
\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
        // line 7
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["id"] ?? null), "html", null, true);
        yield "\" />
\t\t\t\t<button type=\"submit\" title=\"Edit\"><img src=\"images/edit.png\"/> Edit</button>
\t\t\t</form>

\t\t\t<form action=\"";
        // line 11
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["page"] ?? null), "html", null, true);
        yield "\" method=\"post\" style=\"float: left\">
\t\t\t\t";
        // line 12
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"delete\" />
\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
        // line 14
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["id"] ?? null), "html", null, true);
        yield "\" />
\t\t\t\t<button type=\"submit\" onclick=\"return confirm('Are you sure?');\" title=\"Delete\"><img src=\"images/del.png\"/>Delete</button>
\t\t\t</form>

\t\t\t<form action=\"";
        // line 18
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["page"] ?? null), "html", null, true);
        yield "\" method=\"post\" style=\"float: left\">
\t\t\t\t";
        // line 19
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"action\" value=\"hide\" />
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
\t\t</td>
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
        return "admin.links.html.twig";
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
        return array (  98 => 22,  94 => 21,  89 => 19,  83 => 18,  76 => 14,  71 => 12,  65 => 11,  58 => 7,  53 => 5,  47 => 4,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "admin.links.html.twig", "/var/www/html/system/templates/admin.links.html.twig");
    }
}
