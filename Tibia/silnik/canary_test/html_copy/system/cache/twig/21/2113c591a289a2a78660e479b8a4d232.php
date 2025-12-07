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

/* newcomer.html.twig */
class __TwigTemplate_202f1ee342cdfcd79e7bac79b04bd6ab extends Template
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
        yield "<div id=\"NewcomerBox\" class=\"Themebox\" style=\"background-image:url(";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/themeboxes/newcomer/newcomerbox.gif);\">
\t<a class=\"ThemeboxButton\" href=\"";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/create"), "html", null, true);
        yield "\" onMouseOver=\"MouseOverBigButton(this);\" onMouseOut=\"MouseOutBigButton(this);\" style=\"background-image:url(";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/global/buttons/sbutton.gif);\"><div class=\"BigButtonOver\" style=\"background-image:url(";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/global/buttons/sbutton_over.gif);\"></div><div class=\"ButtonText\" style=\"background-image:url(";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/global/buttons/_sbutton_jointibia.gif);\"></div>
\t</a>
\t<div class=\"Bottom\" style=\"background-image:url(";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/general/box-bottom.gif);\"></div>
</div>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "newcomer.html.twig";
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
        return array (  58 => 4,  47 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "newcomer.html.twig", "/var/www/html/templates/tibiacom/boxes/templates/newcomer.html.twig");
    }
}
