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

/* tables.headline.html.twig */
class __TwigTemplate_ef5c52f2e1a8f05a30e16ac846b1debe extends Template
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
        yield "<div class=\"TableContainer\">
\t<div class=\"CaptionContainer\">
\t\t<div class=\"CaptionInnerContainer\">
\t\t\t<span class=\"CaptionEdgeLeftTop\" style=\"background-image:url(";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></span>
\t\t\t<span class=\"CaptionEdgeRightTop\" style=\"background-image:url(";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></span>
\t\t\t<span class=\"CaptionBorderTop\" style=\"background-image:url(";
        // line 6
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/table-headline-border.gif);\"></span>
\t\t\t<span class=\"CaptionVerticalLeft\" style=\"background-image:url(";
        // line 7
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-vertical.gif);\"></span>
\t\t\t<div class=\"Text\">";
        // line 8
        yield ($context["title"] ?? null);
        yield "</div>
\t\t\t<span class=\"CaptionVerticalRight\" style=\"background-image:url(";
        // line 9
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-vertical.gif);\"></span>
\t\t\t<span class=\"CaptionBorderBottom\" style=\"background-image:url(";
        // line 10
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/table-headline-border.gif);\"></span>
\t\t\t<span class=\"CaptionEdgeLeftBottom\" style=\"background-image:url(";
        // line 11
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></span>
\t\t\t<span class=\"CaptionEdgeRightBottom\" style=\"background-image:url(";
        // line 12
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></span>
\t\t</div>
\t</div>
\t<table class=\"";
        // line 15
        if ( !(null === ($context["tableClass"] ?? null))) {
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["tableClass"] ?? null), "html", null, true);
        } else {
            yield "Table3";
        }
        yield "\" cellpadding=\"0\" cellspacing=\"0\" style=\"background-color: ";
        if ( !(null === ($context["background"] ?? null))) {
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["background"] ?? null), "html", null, true);
        } else {
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 15), "html", null, true);
        }
        yield "\">
\t\t<tr>
\t\t\t<td>
\t\t\t\t<div class=\"InnerTableContainer\">
\t\t\t\t\t";
        // line 19
        yield ($context["content"] ?? null);
        yield "
\t\t\t\t</div>
\t\t\t</td>
\t\t</tr>
\t</table>
</div>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "tables.headline.html.twig";
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
        return array (  102 => 19,  85 => 15,  79 => 12,  75 => 11,  71 => 10,  67 => 9,  63 => 8,  59 => 7,  55 => 6,  51 => 5,  47 => 4,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "tables.headline.html.twig", "/var/www/html/templates/tibiacom/tables.headline.html.twig");
    }
}
