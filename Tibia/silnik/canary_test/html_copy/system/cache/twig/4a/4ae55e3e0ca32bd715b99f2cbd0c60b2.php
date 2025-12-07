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

/* admin.plugins.form.html.twig */
class __TwigTemplate_d91cc4cdedaac01684c93bead7066971 extends Template
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
        yield "<div id=\"install_plugin\">
\t<div class=\"card card-info card-outline\">
\t\t<div class=\"card-header\">
\t\t\t<h5 class=\"m-0\">Install plugin
\t\t\t\t<a href=\"?p=plugins&check-updates\" class=\"btn btn-primary float-right\">Check for updates</a>
\t\t\t</h5>
\t\t</div>
\t\t<form enctype=\"multipart/form-data\" method=\"post\" action=\"";
        // line 8
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=plugins\">
\t\t\t";
        // line 9
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t<div class=\"card-body\">
\t\t\t\t<input type=\"hidden\" name=\"upload_plugin\"/>

\t\t\t\t<div class=\"form-group\">
\t\t\t\t\t<label>File input</label>
\t\t\t\t\t<input type=\"file\" name=\"plugin\" accept=\".zip\">
\t\t\t\t</div>
\t\t\t</div>
\t\t\t<div class=\"card-footer\">
\t\t\t\t<button type=\"submit\" class=\"btn btn-info\" ";
        // line 19
        if ( !($context["pluginUploadEnabled"] ?? null)) {
            yield "disabled";
        }
        yield ">Upload</button>
\t\t\t</div>
\t\t</form>
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
        return "admin.plugins.form.html.twig";
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
        return array (  68 => 19,  55 => 9,  51 => 8,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "admin.plugins.form.html.twig", "/var/www/html/system/templates/admin.plugins.form.html.twig");
    }
}
