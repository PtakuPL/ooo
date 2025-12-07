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

/* buttons.base.html.twig */
class __TwigTemplate_9a4c119c90ee16b9dd93b7ed487c726c extends Template
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
        $_v0 = ('' === $tmp = \Twig\Extension\CoreExtension::captureOutput((function () use (&$context, $macros, $blocks) {
            // line 2
            yield "
\t";
            // line 3
            $context["tmp_image"] = "sbutton";
            // line 4
            yield "
\t";
            // line 5
            if (array_key_exists("button_color", $context)) {
                // line 6
                yield "\t\t";
                if ((($context["button_color"] ?? null) == "green")) {
                    // line 7
                    yield "\t\t\t";
                    $context["tmp_image"] = "sbutton_green";
                    // line 8
                    yield "\t\t";
                } elseif ((($context["button_color"] ?? null) == "red")) {
                    // line 9
                    yield "\t\t\t";
                    $context["tmp_image"] = "sbutton_red";
                    // line 10
                    yield "\t\t";
                }
                // line 11
                yield "\t";
            }
            // line 12
            yield "
\t<div class=\"BigButton\" style=\"background-image:url(";
            // line 13
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/global/buttons/";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["tmp_image"] ?? null), "html", null, true);
            yield ".gif)\">
\t\t<div onMouseOver=\"MouseOverBigButton(this);\" onMouseOut=\"MouseOutBigButton(this);\">
\t\t\t<div class=\"BigButtonOver\" style=\"background-image:url(";
            // line 15
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/global/buttons/";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["tmp_image"] ?? null), "html", null, true);
            yield "_over.gif);\" ></div>
\t\t\t<input class=\"BigButtonText\" ";
            // line 16
            if ( !array_key_exists("noSubmit", $context)) {
                yield "type=\"submit\"";
            }
            yield " value=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["button_name"] ?? null), "html", null, true);
            yield "\">
\t\t</div>
\t</div>
";
            yield from [];
        })())) ? '' : new Markup($tmp, $this->env->getCharset());
        // line 1
        yield Twig\Extension\CoreExtension::spaceless($_v0);
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "buttons.base.html.twig";
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
        return array (  100 => 1,  88 => 16,  82 => 15,  75 => 13,  72 => 12,  69 => 11,  66 => 10,  63 => 9,  60 => 8,  57 => 7,  54 => 6,  52 => 5,  49 => 4,  47 => 3,  44 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "buttons.base.html.twig", "/var/www/html/templates/tibiacom/buttons.base.html.twig");
    }
}
