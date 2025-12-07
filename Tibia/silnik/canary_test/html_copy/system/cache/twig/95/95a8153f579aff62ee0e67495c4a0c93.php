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

/* error_box.html.twig */
class __TwigTemplate_f22e791ad2c66e000e0cc9504c765e32 extends Template
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
        yield "<div class=\"SmallBox\" >
\t<div class=\"MessageContainer\">
\t\t<div class=\"BoxFrameHorizontal\" style=\"background-image:url(";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-horizontal.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeLeftTop\" style=\"background-image:url(";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeRightTop\" style=\"background-image:url(";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"ErrorMessage\">
\t\t\t<div class=\"BoxFrameVerticalLeft\" style=\"background-image:url(";
        // line 7
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-vertical.gif);\"></div>
\t\t\t<div class=\"BoxFrameVerticalRight\" style=\"background-image:url(";
        // line 8
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-vertical.gif);\"></div>
\t\t\t<div class=\"AttentionSign\" style=\"background-image:url(";
        // line 9
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/attentionsign.gif);\"></div>
\t\t\t<b>The Following Errors Have Occurred:</b><br/>
\t\t\t";
        // line 11
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["errors"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["error"]) {
            // line 12
            yield "\t\t\t<li>";
            yield Twig\Extension\CoreExtension::striptags($context["error"], "<b>");
            yield "</li>
\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['error'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 14
        yield "\t\t</div>
\t\t<div class=\"BoxFrameHorizontal\" style=\"background-image:url(";
        // line 15
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-horizontal.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeRightBottom\" style=\"background-image:url(";
        // line 16
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeLeftBottom\" style=\"background-image:url(";
        // line 17
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></div>
\t</div>
</div>
<br/>";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "error_box.html.twig";
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
        return array (  96 => 17,  92 => 16,  88 => 15,  85 => 14,  76 => 12,  72 => 11,  67 => 9,  63 => 8,  59 => 7,  54 => 5,  50 => 4,  46 => 3,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "error_box.html.twig", "/var/www/html/system/templates/error_box.html.twig");
    }
}
