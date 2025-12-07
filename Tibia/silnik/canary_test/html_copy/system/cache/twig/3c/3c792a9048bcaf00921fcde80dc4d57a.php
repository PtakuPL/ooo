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

/* install.welcome.html.twig */
class __TwigTemplate_665f9b82ec4d9f9ea4457bfa520e3bc9 extends Template
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
        yield "<p class=\"lead\">";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["locale"] ?? null), "step_welcome_desc", [], "any", false, false, false, 1), "html", null, true);
        yield ":</p>

<form action=\"";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "install/\" method=\"post\">
\t<input type=\"hidden\" name=\"step\" id=\"step\" value=\"license\" />
\t
\t<div class=\"input\">
\t\t<select name=\"lang\" class=\"form-control\">
\t\t\t";
        // line 8
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["locales"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["locale_"]) {
            // line 9
            yield "\t\t\t\t<option value=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["locale_"], "id", [], "any", false, false, false, 9), "html", null, true);
            yield "\"";
            if ((( !(null === ($context["detected_locale"] ?? null)) && (CoreExtension::getAttribute($this->env, $this->source, $context["locale_"], "id", [], "any", false, false, false, 9) == ($context["detected_locale"] ?? null))) || (($context["cookie_locale"] ?? null) == CoreExtension::getAttribute($this->env, $this->source, $context["locale_"], "id", [], "any", false, false, false, 9)))) {
                yield " selected";
            }
            yield ">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["locale_"], "name", [], "any", false, false, false, 9), "html", null, true);
            yield "</option>
\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['locale_'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 11
        yield "\t\t</select>
\t</div>

\t<div class=\"text-center m-3\">
\t";
        // line 15
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
        return "install.welcome.html.twig";
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
        return array (  81 => 15,  75 => 11,  60 => 9,  56 => 8,  48 => 3,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "install.welcome.html.twig", "/var/www/html/system/templates/install.welcome.html.twig");
    }
}
