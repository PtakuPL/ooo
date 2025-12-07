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

/* install.config.html.twig */
class __TwigTemplate_90c1c55f201aa7d27a04af1f89153c2f extends Template
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
        if ( !Twig\Extension\CoreExtension::testEmpty(($context["errors"] ?? null))) {
            // line 2
            yield "<div class=\"alert alert-danger\">
\t";
            // line 3
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["errors"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["error"]) {
                // line 4
                yield "\t\t<span>";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["error"], "html", null, true);
                yield "</span>
\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['error'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 6
            yield "</div>
";
        }
        // line 8
        yield "
<form action=\"";
        // line 9
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "install/\" method=\"post\" autocomplete=\"off\">
\t<input type=\"hidden\" name=\"step\" id=\"step\" value=\"database\" />

\t";
        // line 12
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(["site_url", "server_path"]);
        foreach ($context['_seq'] as $context["_key"] => $context["value"]) {
            // line 13
            yield "\t<div class=\"form-group mb-2\">
\t\t<label for=\"vars_";
            // line 14
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["value"], "html", null, true);
            yield "\">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v0 = ($context["locale"] ?? null)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0[("step_config_" . $context["value"])] ?? null) : null), "html", null, true);
            yield "</label>
\t\t<input class=\"form-control\" type=\"";
            // line 15
            if (($context["value"] == "mail_admin")) {
                yield "email";
            } else {
                yield "text";
            }
            yield "\" name=\"vars[";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["value"], "html", null, true);
            yield "]\" id=\"vars_";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["value"], "html", null, true);
            yield "\"";
            if ( !(null === (($_v1 = ($context["session"] ?? null)) && is_array($_v1) || $_v1 instanceof ArrayAccess ? ($_v1[("var_" . $context["value"])] ?? null) : null))) {
                yield " value=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v2 = ($context["session"] ?? null)) && is_array($_v2) || $_v2 instanceof ArrayAccess ? ($_v2[("var_" . $context["value"])] ?? null) : null), "html", null, true);
                yield "\"";
            }
            yield "/>
\t\t<small class=\"form-text text-muted\">";
            // line 16
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v3 = ($context["locale"] ?? null)) && is_array($_v3) || $_v3 instanceof ArrayAccess ? ($_v3[(("step_config_" . $context["value"]) . "_desc")] ?? null) : null), "html", null, true);
            yield "</small>
\t</div>
\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['value'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 19
        yield "
\t<div class=\"form-group mb-2\">
\t\t<label for=\"vars_date_timezone\">";
        // line 21
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["locale"] ?? null), "step_config_timezone", [], "any", false, false, false, 21), "html", null, true);
        yield "</label>
\t\t<select class=\"form-control\" name=\"vars[date_timezone]\" id=\"vars_date_timezone\">
\t\t\t";
        // line 23
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["timezones"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["timezone"]) {
            // line 24
            yield "\t\t\t<option value=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["timezone"], "html", null, true);
            yield "\"";
            if ((( !(null === (($_v4 = ($context["session"] ?? null)) && is_array($_v4) || $_v4 instanceof ArrayAccess ? ($_v4["var_date_timezone"] ?? null) : null)) && ((($_v5 = ($context["session"] ?? null)) && is_array($_v5) || $_v5 instanceof ArrayAccess ? ($_v5["var_date_timezone"] ?? null) : null) == $context["timezone"])) || ((null === (($_v6 = ($context["session"] ?? null)) && is_array($_v6) || $_v6 instanceof ArrayAccess ? ($_v6["var_date_timezone"] ?? null) : null)) && ($context["timezone"] == "Europe/Warsaw")))) {
                yield " selected";
            }
            yield ">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["timezone"], "html", null, true);
            yield "</option>
\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['timezone'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 26
        yield "\t\t</select>
\t\t<small class=\"form-text text-muted\">";
        // line 27
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["locale"] ?? null), "step_config_timezone_desc", [], "any", false, false, false, 27), "html", null, true);
        yield "</small>
\t</div>

\t<div class=\"form-group mb-2\">
\t\t<label for=\"vars_client\">";
        // line 31
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["locale"] ?? null), "step_config_client", [], "any", false, false, false, 31), "html", null, true);
        yield "</label>
\t\t<select class=\"form-control\" name=\"vars[client]\" id=\"vars_client\">
\t\t\t";
        // line 33
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["clients"] ?? null));
        foreach ($context['_seq'] as $context["id"] => $context["version"]) {
            // line 34
            yield "\t\t\t<option value=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["id"], "html", null, true);
            yield "\"";
            if (( !(null === (($_v7 = ($context["session"] ?? null)) && is_array($_v7) || $_v7 instanceof ArrayAccess ? ($_v7["var_client"] ?? null) : null)) && ((($_v8 = ($context["session"] ?? null)) && is_array($_v8) || $_v8 instanceof ArrayAccess ? ($_v8["var_client"] ?? null) : null) == $context["id"]))) {
                yield " selected";
            }
            yield ">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["version"], "html", null, true);
            yield "</option>
\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['id'], $context['version'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 36
        yield "\t\t</select>
\t\t<small class=\"form-text text-muted\">";
        // line 37
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["locale"] ?? null), "step_config_client_desc", [], "any", false, false, false, 37), "html", null, true);
        yield "</small>
\t</div>

\t<div class=\"form-group mb-2\">
\t\t<label for=\"vars_usage\">";
        // line 41
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["locale"] ?? null), "step_config_usage", [], "any", false, false, false, 41), "html", null, true);
        yield "</label>
\t\t<input type=\"hidden\" value=\"0\" name=\"vars[usage]\">
\t\t<input type=\"checkbox\" name=\"vars[usage]\" id=\"vars_usage\" value=\"1\"";
        // line 43
        if (((null === (($_v9 = ($context["session"] ?? null)) && is_array($_v9) || $_v9 instanceof ArrayAccess ? ($_v9["var_usage"] ?? null) : null)) || ((($_v10 = ($context["session"] ?? null)) && is_array($_v10) || $_v10 instanceof ArrayAccess ? ($_v10["var_usage"] ?? null) : null) == 1))) {
            yield " checked";
        }
        yield "/>
\t\t<small class=\"form-text text-muted d-block\">";
        // line 44
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["locale"] ?? null), "step_config_usage_desc", [], "any", false, false, false, 44), "html", null, true);
        yield "</small>
\t</div>

\t<div class=\"text-center m-3\">
\t";
        // line 48
        yield ($context["buttons"] ?? null);
        yield "
\t</div>

</form>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "install.config.html.twig";
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
        return array (  203 => 48,  196 => 44,  190 => 43,  185 => 41,  178 => 37,  175 => 36,  160 => 34,  156 => 33,  151 => 31,  144 => 27,  141 => 26,  126 => 24,  122 => 23,  117 => 21,  113 => 19,  104 => 16,  86 => 15,  80 => 14,  77 => 13,  73 => 12,  67 => 9,  64 => 8,  60 => 6,  51 => 4,  47 => 3,  44 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "install.config.html.twig", "/var/www/html/system/templates/install.config.html.twig");
    }
}
