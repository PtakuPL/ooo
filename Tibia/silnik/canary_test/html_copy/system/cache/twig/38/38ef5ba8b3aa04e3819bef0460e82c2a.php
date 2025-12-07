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

/* web_status.twig */
class __TwigTemplate_e2b77291f3c206706e49a4f0e8fe1b12 extends Template
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
        yield "<div class=\"col-12 col-md-6\">
\t<div class=\"card card-warning card-outline\">
\t\t<div class=\"card-header\">
\t\t\t<span class=\"m-0\">Website Status<span class=\"float-right\">
\t\t\t<div class=\"custom-control custom-switch custom-switch-off-danger custom-switch-on-success\">
\t\t\t\t<input form=\"maintenance-form\" type=\"checkbox\" class=\"custom-control-input\" name=\"status\" id=\"status\" value=\"true\" ";
        // line 6
        if ( !($context["is_closed"] ?? null)) {
            yield " checked";
        }
        yield ">
\t\t\t\t<label id=\"status-label\" class=\"custom-control-label\" for=\"status\"> ";
        // line 7
        if (($context["is_closed"] ?? null)) {
            yield "Closed";
        } else {
            yield "Open";
        }
        yield "</label>
\t\t\t</div></span>
\t\t\t</span>
\t\t</div>
\t\t<div class=\"card-body p-2\">
\t\t\t<div class=\"col-sm-12\">
\t\t\t\t<label for=\"message\" class=\"col-form-label\">Maintenance Message</label>
\t\t\t\t<textarea form=\"maintenance-form\" name=\"message\" class=\"form-control\" cols=\"40\" rows=\"3\" maxlength=\"255\" placeholder=\"Enter ...\">";
        // line 14
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["closed_message"] ?? null), "html", null, true);
        yield "</textarea>
\t\t\t\t<small>(only visible if closed)</small>
\t\t\t</div>
\t\t</div>
\t\t<div class=\"card-footer\">
\t\t\t<form id=\"maintenance-form\" method=\"post\" action=\"?p=dashboard\" class=\"float-left\">
\t\t\t\t";
        // line 20
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"maintenance\" value=\"1\" />
\t\t\t\t<button type=\"submit\" class=\"btn btn-info\"><i class=\"far fa-update\"></i> Update</button>
\t\t\t</form>
\t\t\t<form method=\"post\" action=\"?p=dashboard\" class=\"float-right\">
\t\t\t\t";
        // line 25
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"clear_cache\" value=\"1\" />
\t\t\t\t<button type=\"submit\" onclick=\"return confirm('Are you sure that you want to clear cache?');\" class=\"btn btn-danger\" title=\"Clear Cache\"><i class=\"fas fa-clear\"></i>Clear cache</button>
\t\t\t</form>
\t\t</div>
\t</div>
</div>

<script>
\t\$(function() {
\t\t\$(\"#status\").change(function() {
\t\t\t\$statusLabel = \$(\"#status-label\");
\t\t\t\$statusLabel.html(\"Closed\");
\t\t\tif (\$(this).is(':checked')) {
\t\t\t\t\$statusLabel.html(\"Open\");
\t\t\t}
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
        return "web_status.twig";
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
        return array (  86 => 25,  78 => 20,  69 => 14,  55 => 7,  49 => 6,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "web_status.twig", "/var/www/html/admin/pages/modules/templates/web_status.twig");
    }
}
