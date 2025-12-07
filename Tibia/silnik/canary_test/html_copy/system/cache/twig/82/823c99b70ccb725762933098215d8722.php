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

/* statistics.html.twig */
class __TwigTemplate_cd24e048021427d844926561ea3e9e12 extends Template
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
        yield "<div class=\"col\">
\t<div class=\"info-box\">
\t\t<span class=\"info-box-icon bg-info elevation-1\"><i class=\"fas fa-user-plus\"></i></span>
\t\t<div class=\"info-box-content\">
\t\t\t<span class=\"info-box-text\">Accounts:</span>
\t\t\t<span class=\"info-box-number\">";
        // line 6
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["count"] ?? null), "total_accounts", [], "any", false, false, false, 6), "html", null, true);
        yield "</span>
\t\t</div>
\t</div>
</div>
<div class=\"col\">
\t<div class=\"info-box\">
\t\t<span class=\"info-box-icon bg-red elevation-1\"><i class=\"fas fa-user-plus\"></i></span>
\t\t<div class=\"info-box-content\">
\t\t\t<span class=\"info-box-text\">Players:</span>
\t\t\t<span class=\"info-box-number\">";
        // line 15
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["count"] ?? null), "total_players", [], "any", false, false, false, 15), "html", null, true);
        yield "</span>
\t\t</div>
\t</div>
</div>
<div class=\"col\">
\t<div class=\"info-box\">
\t\t<span class=\"info-box-icon bg-teal elevation-1\"><i class=\"fas fa-pastafarianism\"></i></span>
\t\t<div class=\"info-box-content\">
\t\t\t<span class=\"info-box-text\">Monsters:</span>
\t\t\t<span class=\"info-box-number\">";
        // line 24
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["count"] ?? null), "total_monsters", [], "any", false, false, false, 24), "html", null, true);
        yield "</span>
\t\t</div>
\t</div>
</div>
<div class=\"col\">
\t<div class=\"info-box\">
\t\t<span class=\"info-box-icon bg-green elevation-1\"><i class=\"fas fa-chart-pie\"></i></span>
\t\t<div class=\"info-box-content\">
\t\t\t<span class=\"info-box-text\">Guilds:</span>
\t\t\t<span class=\"info-box-number\">";
        // line 33
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["count"] ?? null), "total_guilds", [], "any", false, false, false, 33), "html", null, true);
        yield "</span>
\t\t</div>
\t</div>
</div>
<div class=\"col\">
\t<div class=\"info-box\">
\t\t<span class=\"info-box-icon bg-yellow elevation-1\"><i class=\"fas fa-home\"></i></span>
\t\t<div class=\"info-box-content\">
\t\t\t<span class=\"info-box-text\">Houses:</span>
\t\t\t<span class=\"info-box-number\">";
        // line 42
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["count"] ?? null), "total_houses", [], "any", false, false, false, 42), "html", null, true);
        yield "</span>
\t\t</div>
\t</div>
</div>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "statistics.html.twig";
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
        return array (  97 => 42,  85 => 33,  73 => 24,  61 => 15,  49 => 6,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "statistics.html.twig", "/var/www/html/admin/pages/modules/templates/statistics.html.twig");
    }
}
