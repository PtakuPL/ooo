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

/* news.tickers.html.twig */
class __TwigTemplate_62df5cc965a6e2c9884fd5daee38077f extends Template
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
        yield "<table style=\"width: 100%\">
\t<tr class=\"white\" bgcolor=\"";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 2), "html", null, true);
        yield "\">
\t\t<td colspan=\"3\">Tickers</td>
\t</tr>
\t";
        // line 5
        $context["i"] = 0;
        // line 6
        yield "\t";
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["tickers"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["ticker"]) {
            // line 7
            yield "\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
            yield "\">
\t\t<td style=\"width: 16px;\"><img src=\"";
            // line 8
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
            yield "images/news/icon_";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "icon", [], "any", false, false, false, 8), "html", null, true);
            yield "_small.gif\"/></td>
\t\t<td style=\"width: 80px;\">";
            // line 9
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "date", [], "any", false, false, false, 9), "j M Y"), "html", null, true);
            yield "</td>
\t\t<td>";
            // line 10
            yield CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "body", [], "any", false, false, false, 10);
            yield "</td>
\t</tr>
\t";
            // line 12
            $context["i"] = (($context["i"] ?? null) + 1);
            // line 13
            yield "\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['ticker'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 14
        yield "</table>
<br/>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "news.tickers.html.twig";
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
        return array (  86 => 14,  80 => 13,  78 => 12,  73 => 10,  69 => 9,  63 => 8,  58 => 7,  53 => 6,  51 => 5,  45 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "news.tickers.html.twig", "/var/www/html/system/templates/news.tickers.html.twig");
    }
}
