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
class __TwigTemplate_c7dd2e7c6520d878aef9ed262f18ba8b extends Template
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
        yield "<div class=\"NewsHeadline\">
\t<div class=\"NewsHeadlineBackground\" style=\"background-image:url(";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/news/newsheadline_background.gif)\">
\t\t<img src=\"";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "images/news/icon_";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["icon"] ?? null), "html", null, true);
        yield ".gif\" class=\"NewsHeadlineIcon\" />
\t\t<div class=\"NewsHeadlineDate\">";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(($context["date"] ?? null), $this->env->getFunction('setting')->getCallable()("core.news_date_format")), "html", null, true);
        yield " - </div>
\t\t<div class=\"NewsHeadlineText\">";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["title"] ?? null), "html", null, true);
        yield "</div>
\t\t";
        // line 6
        if (($this->env->getFunction('setting')->getCallable()("core.news_author") &&  !Twig\Extension\CoreExtension::testEmpty(($context["author"] ?? null)))) {
            // line 7
            yield "\t\t<div class=\"NewsHeadlineAuthor\"><b>Author: </b><i>";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["author"] ?? null), "html", null, true);
            yield "</i></div>
\t\t";
        }
        // line 9
        yield "\t</div>
</div>
<table style=\"clear:both\" border=0 cellpadding=0 cellspacing=0 width=\"100%\" >
\t<tr>
\t\t<td style=\"padding-left:10px;padding-right:10px;\" >";
        // line 13
        yield ($context["content"] ?? null);
        yield "</td>
\t</tr>
\t";
        // line 15
        if ( !(null === ($context["comments"] ?? null))) {
            // line 16
            yield "\t<tr>
\t\t<td>
\t\t\t<div style=\"text-align: right; margin-right: 10px;\"><a href=\"";
            // line 18
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["comments"] ?? null), "html", null, true);
            yield "\">» Comment on this news</a></div>
\t\t</td>
\t</tr>
\t";
        }
        // line 22
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
        return array (  95 => 22,  88 => 18,  84 => 16,  82 => 15,  77 => 13,  71 => 9,  65 => 7,  63 => 6,  59 => 5,  55 => 4,  49 => 3,  45 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "news.html.twig", "/var/www/html/system/templates/news.html.twig");
    }
}
