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

/* admin.news.html.twig */
class __TwigTemplate_f302a75df38288aa3eb6a263a1ea8f38 extends Template
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
        yield Twig\Extension\CoreExtension::include($this->env, $context, "admin.news.table.html.twig", ["type" => 1, "title" => "News"]);
        yield "
";
        // line 2
        yield Twig\Extension\CoreExtension::include($this->env, $context, "admin.news.table.html.twig", ["type" => 2, "title" => "Tickers"]);
        yield "
";
        // line 3
        yield Twig\Extension\CoreExtension::include($this->env, $context, "admin.news.table.html.twig", ["type" => 3, "title" => "Articles"]);
        yield "

<script>
\t\$(function () {
\t\t\$('.tb_datatable').DataTable({
\t\t\t\"order\": [[0, \"desc\"]]
\t\t});
\t});
</script>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "admin.news.html.twig";
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
        return array (  50 => 3,  46 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "admin.news.html.twig", "/var/www/html/system/templates/admin.news.html.twig");
    }
}
