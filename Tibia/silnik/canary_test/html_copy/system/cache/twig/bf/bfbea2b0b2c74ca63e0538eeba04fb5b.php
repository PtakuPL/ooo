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
class __TwigTemplate_5972f574ab1f79f23449058e1b53ff28 extends Template
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
        yield "<div id=\"newsticker\" class=\"Box\">
\t<div class=\"Corner-tl\" style=\"background-image: url(";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/corner-tl.gif);\"></div>
\t<div class=\"Corner-tr\" style=\"background-image: url(";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/corner-tr.gif);\"></div>
\t<div class=\"Border_1\" style=\"background-image: url(";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/border-1.gif);\"></div>
\t<div class=\"BorderTitleText\" style=\"background-image: url(";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/title-background-green.gif);\"></div>
\t<img class=\"Title\" src=\"";
        // line 6
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/header/headline-newsticker.gif\" alt=\"Contentbox headline\">
\t<div class=\"Border_2\">
\t\t<div class=\"Border_3\">
\t\t\t<div class=\"BoxContent\" style=\"background-image: url(";
        // line 9
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/scroll.gif);\">
\t\t\t\t";
        // line 10
        if ( !array_key_exists("i", $context)) {
            // line 11
            yield "\t\t\t\t";
            $context["i"] = 0;
            // line 12
            yield "\t\t\t\t";
        }
        // line 13
        yield "\t\t\t\t";
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["tickers"] ?? null));
        $context['loop'] = [
          'parent' => $context['_parent'],
          'index0' => 0,
          'index'  => 1,
          'first'  => true,
        ];
        if (is_array($context['_seq']) || (is_object($context['_seq']) && $context['_seq'] instanceof \Countable)) {
            $length = count($context['_seq']);
            $context['loop']['revindex0'] = $length - 1;
            $context['loop']['revindex'] = $length;
            $context['loop']['length'] = $length;
            $context['loop']['last'] = 1 === $length;
        }
        foreach ($context['_seq'] as $context["_key"] => $context["ticker"]) {
            // line 14
            yield "\t\t\t\t<div id=\"TickerEntry-";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
            yield "\" class=\"Row\" onclick='TickerAction(\"TickerEntry-";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
            yield "\")'>
\t\t\t\t\t<div class=\"";
            // line 15
            if (CoreExtension::matches("/^\\d+\$/", (($context["i"] ?? null) / 2))) {
                yield "Odd";
            } else {
                yield "Even";
            }
            yield "\">
\t\t\t\t\t<div class=\"NewsTickerIcon\" style=\"background-image: url(";
            // line 16
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
            yield "images/news/icon_";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "icon", [], "any", false, false, false, 16), "html", null, true);
            yield "_small.gif);\"></div>
\t\t\t\t\t<div id=\"TickerEntry-";
            // line 17
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
            yield "-Button\" class=\"NewsTickerExtend\" style=\"background-image: url(";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/general/plus.gif);\"></div>
\t\t\t\t\t<div class=\"NewsTickerText\">
\t\t\t\t\t\t<span class=\"NewsTickerDate\">";
            // line 19
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "date", [], "any", false, false, false, 19), "j M Y"), "html", null, true);
            yield " -</span>
\t\t\t\t\t\t<div id=\"TickerEntry-";
            // line 20
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
            yield "-ShortText\" class=\"NewsTickerShortText\">";
            yield CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "body_short", [], "any", false, false, false, 20);
            yield "</div>
\t\t\t\t\t\t<div id=\"TickerEntry-";
            // line 21
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
            yield "-FullText\" class=\"NewsTickerFullText\">";
            yield CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "body", [], "any", false, false, false, 21);
            yield "
\t\t\t\t\t\t\t";
            // line 22
            if (($context["canEdit"] ?? null)) {
                // line 23
                yield "\t\t\t\t\t\t\t\t";
                yield Twig\Extension\CoreExtension::include($this->env, $context, "admin.links.html.twig", ["page" => "news", "id" => CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "id", [], "any", false, false, false, 23), "hide" => CoreExtension::getAttribute($this->env, $this->source, $context["ticker"], "hide", [], "any", false, false, false, 23)]);
                yield "
\t\t\t\t\t\t\t";
            }
            // line 25
            yield "\t\t\t\t\t\t</div>
\t\t\t\t\t</div>
\t\t\t\t</div>
\t\t\t</div>
\t\t\t";
            // line 29
            $context["i"] = (($context["i"] ?? null) + 1);
            // line 30
            yield "\t\t\t";
            ++$context['loop']['index0'];
            ++$context['loop']['index'];
            $context['loop']['first'] = false;
            if (isset($context['loop']['revindex0'], $context['loop']['revindex'])) {
                --$context['loop']['revindex0'];
                --$context['loop']['revindex'];
                $context['loop']['last'] = 0 === $context['loop']['revindex0'];
            }
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['ticker'], $context['_parent'], $context['loop']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 31
        yield "\t\t\t</div>
\t</div>
</div>
<div class=\"Border_1\" style=\"background-image: url(";
        // line 34
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/border-1.gif);\"></div>
<div class=\"CornerWrapper-b\"><div class=\"Corner-bl\" style=\"background-image: url(";
        // line 35
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/corner-bl.gif);\"></div></div>
<div class=\"CornerWrapper-b\"><div class=\"Corner-br\" style=\"background-image: url(";
        // line 36
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/corner-br.gif);\"></div></div>
</div>
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
        return array (  184 => 36,  180 => 35,  176 => 34,  171 => 31,  157 => 30,  155 => 29,  149 => 25,  143 => 23,  141 => 22,  135 => 21,  129 => 20,  125 => 19,  118 => 17,  112 => 16,  104 => 15,  97 => 14,  79 => 13,  76 => 12,  73 => 11,  71 => 10,  67 => 9,  61 => 6,  57 => 5,  53 => 4,  49 => 3,  45 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "news.tickers.html.twig", "/var/www/html/templates/tibiacom/news.tickers.html.twig");
    }
}
