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

/* install.admin.html.twig */
class __TwigTemplate_d8212a331ef567b6ba355fbb1aaf12b3 extends Template
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
        if ( !Twig\Extension\CoreExtension::testEmpty(($context["errors"] ?? null))) {
            // line 2
            yield "<div class=\"alert alert-danger\">
\t";
            // line 3
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["errors"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["error"]) {
                // line 4
                yield "\t\t<span>";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["error"], "html", null, true);
                yield "</span>
\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['error'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 6
            yield "</div>
";
        }
        // line 8
        yield "
<form action=\"";
        // line 9
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "install/\" method=\"post\" autocomplete=\"off\">
\t<input type=\"hidden\" name=\"step\" id=\"step\" value=\"finish\" />

\t";
        // line 12
        $context["values"] = ["email", ($context["account"] ?? null), "password", "password_confirm"];
        // line 13
        yield "
\t";
        // line 14
        if (($context["hasTablePlayers"] ?? null)) {
            // line 15
            yield "\t\t";
            $context["values"] = Twig\Extension\CoreExtension::merge(($context["values"] ?? null), ["player_name"]);
            // line 16
            yield "\t";
        }
        // line 17
        yield "
\t";
        // line 18
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["values"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["value"]) {
            // line 19
            yield "
\t<div class=\"form-group mb-2\">
\t\t<label for=\"vars_";
            // line 21
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["value"], "html", null, true);
            yield "\">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v0 = ($context["locale"] ?? null)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0[("step_admin_" . $context["value"])] ?? null) : null), "html", null, true);
            yield "</label>
\t\t<input class=\"form-control\" type=\"";
            // line 22
            if (CoreExtension::inFilter($context["value"], ["password", "password_confirm"])) {
                yield "password";
            } else {
                yield "text";
            }
            yield "\" name=\"vars[";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["value"], "html", null, true);
            yield "]\" id=\"vars_";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["value"], "html", null, true);
            yield "\"";
            if ( !(null === (($_v1 = ($context["session"] ?? null)) && is_array($_v1) || $_v1 instanceof ArrayAccess ? ($_v1[("var_" . $context["value"])] ?? null) : null))) {
                yield " value=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v2 = ($context["session"] ?? null)) && is_array($_v2) || $_v2 instanceof ArrayAccess ? ($_v2[("var_" . $context["value"])] ?? null) : null), "html", null, true);
                yield "\"";
            }
            yield "/>
\t\t<small class=\"form-text text-muted\">";
            // line 23
            yield (($_v3 = ($context["locale"] ?? null)) && is_array($_v3) || $_v3 instanceof ArrayAccess ? ($_v3[(("step_admin_" . $context["value"]) . "_desc")] ?? null) : null);
            yield "</small>
\t</div>

\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['value'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 27
        yield "
\t<div class=\"text-center m-3\">
\t";
        // line 29
        yield ($context["buttons"] ?? null);
        yield "
\t</div>

</form>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "install.admin.html.twig";
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
        return array (  135 => 29,  131 => 27,  121 => 23,  103 => 22,  97 => 21,  93 => 19,  89 => 18,  86 => 17,  83 => 16,  80 => 15,  78 => 14,  75 => 13,  73 => 12,  67 => 9,  64 => 8,  60 => 6,  51 => 4,  47 => 3,  44 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "install.admin.html.twig", "/var/www/html/system/templates/install.admin.html.twig");
    }
}
