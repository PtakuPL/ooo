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

/* news.html.twig */
class __TwigTemplate_ce0b59bbb39b5f61d7396c0950983cea extends Template
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
        yield "<div id=\"News\">
\t<div class=\"NewsHeadline\">
\t\t<div class=\"NewsHeadlineBackground\" style=\"background-image:url(";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/news/newsheadline_background.gif)\">
\t\t\t<img src=\"";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "images/news/icon_";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["icon"] ?? null), "html", null, true);
        yield ".gif\" class=\"NewsHeadlineIcon\" />
\t\t\t<div class=\"NewsHeadlineDate\">";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(($context["date"] ?? null), CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "news_date_format", [], "any", false, false, false, 5)), "html", null, true);
        yield " - </div>
\t\t\t<div class=\"NewsHeadlineText\">";
        // line 6
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["title"] ?? null), "html", null, true);
        yield "</div>
\t\t\t";
        // line 7
        if ( !Twig\Extension\CoreExtension::testEmpty(($context["author"] ?? null))) {
            // line 8
            yield "\t\t\t<div class=\"NewsHeadlineAuthor\"><b>Author: </b><i>";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["author"] ?? null), "html", null, true);
            yield "</i></div>
\t\t\t";
        }
        // line 10
        yield "\t\t</div>
\t</div>
</div>
<table style=\"clear:both\" border=0 cellpadding=0 cellspacing=0 width=\"100%\" >
\t<tr>
\t\t<td style=\"padding-left:10px;padding-right:10px;\" >";
        // line 15
        yield ($context["content"] ?? null);
        yield "</td>
\t</tr>
\t";
        // line 17
        if ( !(null === ($context["comments"] ?? null))) {
            // line 18
            yield "\t<tr>
\t\t<td>
\t\t\t<div style=\"text-align: right; margin-right: 10px;\"><a href=\"";
            // line 20
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["comments"] ?? null), "html", null, true);
            yield "\">» Comment on this news</a></div>
\t\t</td>
\t</tr>
\t";
        }
        // line 24
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
        return "news.html.twig";
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
        return array (  97 => 24,  90 => 20,  86 => 18,  84 => 17,  79 => 15,  72 => 10,  66 => 8,  64 => 7,  60 => 6,  56 => 5,  50 => 4,  46 => 3,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "news.html.twig", "/var/www/html/templates/kathrine/news.html.twig");
    }
}
