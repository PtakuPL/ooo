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

/* admin-bar.html.twig */
class __TwigTemplate_f84a2a0fcd3658be6155c7345891050b extends Template
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
        yield "<style>
html { margin-top: 32px !important; }
* html body { margin-top: 32px !important; }

#ma-admin-bar {
\tdirection: ltr;
\tcolor: #ccc;
\tfont-size: 13px;
\tfont-weight: 400;
\tfont-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Oxygen-Sans, Ubuntu, Cantarell, \"Helvetica Neue\", sans-serif;
\tline-height: 2.46153846;
\theight: 32px;
\tposition: fixed;
\ttop: 0;
\tleft: 0;
\twidth: 100%;
\tmin-width: 600px;
\tz-index: 99999;
\tbackground: #23282d;
}

#ma-admin-bar a.ab-item {
\tcolor: #eee;
\tfont-weight: normal;
}

#ma-admin-bar ul, #ma-admin-bar ul li {
\tbackground: 0 0;
\tclear: none;
\tlist-style: none;
\tmargin: 0;
\tpadding: 0 15px 0 0;
\tposition: relative;
\ttext-indent: 0;
\tz-index: 99999;
}

#ma-admin-bar li {
\tfloat: left;
}

#ma-admin-bar li:hover {
\tcolor: lightskyblue;
}

#ma-admin-bar .ab-top-secondary>li {
\tfloat: right;
\tmargin-right: 15px;
}

.dropdown {
\tposition: relative;
\tdisplay: inline-block;
}

.dropdown-content {
\tdisplay: none;
\tposition: absolute;
\tbackground-color: #343a40;
\tbox-shadow: 0 8px 16px 0 rgba(0,0,0,0.2);
\tz-index: 1;
}

.dropdown-content a {
\tcolor: #eee;
\tpadding: 12px 16px;
\ttext-decoration: none;
\tdisplay: block;
}

.dropdown-content a:hover {color: lightskyblue;}

.dropdown:hover .dropdown-content {display: block;}

</style>

<div id=\"ma-admin-bar\">
\t<ul>
\t\t<li class=\"dropdown\">
\t\t\t<a href=\"";
        // line 80
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "\" class=\"ab-item\">
\t\t\t\t<img alt=\"MyAAC\" src=\"";
        // line 81
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "images/logo.png\" class=\"brand-image img-circle elevation-3\" style=\"opacity: .8; height: 26px; width: 26px\">
\t\t\t\t<span class=\"brand-text\">
\t\t\t\t\t<b>My</b>AAC
\t\t\t\t</span>
\t\t\t</a>
\t\t</li>
\t\t<li class=\"dropdown\">
\t\t\t<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" class=\"bi bi-house-door\" viewBox=\"0 0 16 16\">
\t\t\t\t<path d=\"M8.354 1.146a.5.5 0 0 0-.708 0l-6 6A.5.5 0 0 0 1.5 7.5v7a.5.5 0 0 0 .5.5h4.5a.5.5 0 0 0 .5-.5v-4h2v4a.5.5 0 0 0 .5.5H14a.5.5 0 0 0 .5-.5v-7a.5.5 0 0 0-.146-.354L13 5.793V2.5a.5.5 0 0 0-.5-.5h-1a.5.5 0 0 0-.5.5v1.293L8.354 1.146zM2.5 14V7.707l5.5-5.5 5.5 5.5V14H10v-4a.5.5 0 0 0-.5-.5h-3a.5.5 0 0 0-.5.5v4H2.5z\"></path>
\t\t\t</svg>
\t\t\t<a class=\"ab-item\" href=\"#\"><i class=\"bi bi-house\"></i>";
        // line 91
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lua", [], "any", false, false, false, 91), "serverName", [], "any", false, false, false, 91), "html", null, true);
        yield "</a>
\t\t\t<div class=\"dropdown-content\">
\t\t\t\t<a href=\"";
        // line 93
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()(""), "html", null, true);
        yield "\">Visit Site</a>
\t\t\t</div>
\t\t</li>
\t\t<li class=\"dropdown\">
\t\t\t<a class=\"ab-item\" href=\"#\"><i class=\"bi bi-house\"></i>New</a>
\t\t\t<div class=\"dropdown-content\">
\t\t\t\t<a href=\"";
        // line 99
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=news&action=new\">News</a>
\t\t\t\t<a href=\"";
        // line 100
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=pages&action=new\">Page</a>
\t\t\t\t<a href=\"";
        // line 101
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=changelog&action=new\">Changelog</a>
\t\t\t</div>
\t\t</li>
\t\t<li>
\t\t\t<a class=\"ab-item\" href=\"";
        // line 105
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=plugins\">
\t\t\t\tPlugins
\t\t\t</a>
\t\t</li>
\t\t<li>
\t\t\t<form method=\"post\" action=\"";
        // line 110
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?p=dashboard\">
\t\t\t\t";
        // line 111
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t<input type=\"hidden\" name=\"clear_cache\" value=\"1\" />
\t\t\t\t<a class=\"ab-item\" href=\"javascript:void(0);\" onclick=\"confirm('Are you sure that you want to clear cache?') && \$(this).closest('form').submit()\" title=\"Clear Cache\">Clear Cache</a>
\t\t\t</form>
\t\t</li>
\t</ul>
\t<ul class=\"ab-top-secondary\">
\t\t<li class=\"dropdown\">
\t\t\t<a class=\"ab-item\" href=\"#\">Hello, ";
        // line 119
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["username"] ?? null), "html", null, true);
        yield "</a>
\t\t\t<div class=\"dropdown-content\">
\t\t\t\t<a href=\"";
        // line 121
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/manage"), "html", null, true);
        yield "\">Manage Account</a>
\t\t\t\t<a href=\"";
        // line 122
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "?action=logout\">Logout</a>
\t\t\t</div>
\t\t</li>
\t</ul>
</div>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "admin-bar.html.twig";
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
        return array (  201 => 122,  197 => 121,  192 => 119,  181 => 111,  177 => 110,  169 => 105,  162 => 101,  158 => 100,  154 => 99,  145 => 93,  140 => 91,  127 => 81,  123 => 80,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "admin-bar.html.twig", "/var/www/html/system/templates/admin-bar.html.twig");
    }
}
