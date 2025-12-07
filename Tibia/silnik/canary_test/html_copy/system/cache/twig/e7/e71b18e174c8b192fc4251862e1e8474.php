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

/* highscores.html.twig */
class __TwigTemplate_f00b5fb6f3190efdb0eede18878f6a69 extends Template
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
        yield "<style type=\"text/css\">
\t.top_level {
\t\tposition: absolute;
\t\ttop: 29px;
\t\tleft: 6px;
\t\theight: 160px;
\t\twidth: 168px;
\t\tz-index: 20;
\t\tpadding-top: 6px;
\t\tfont-family: Tahoma, Geneva, sans-serif;
\t\tfont-size: 9.2pt;
\t\tcolor: #FFF;
\t\tfont-weight: bold;
\t\ttext-align: right;
\t\ttext-decoration: inherit;
\t\ttext-shadow: 0.1em 0.1em #333
\t}

\t#Topbar a {
\t\ttext-decoration: none;
\t}

\t.online {
\t\tcolor: #008000;
\t}

\t.offline {
\t\tcolor: #FF0000;
\t}

\ta.topfont {
\t\tfont-family: Verdana, Arial, Helvetica, sans-serif;
\t\tfont-size: 11px;
\t\ttext-decoration: none
\t}
\ta:hover.topfont {
\t\tfont-family: Verdana, Arial, Helvetica, sans-serif;
\t\tfont-size: 11px;
\t\tcolor: #CCC;
\t\ttext-decoration:none
\t}
</style>

<div id=\"Topbar\" class=\"Themebox\" style=\"background-image:url(";
        // line 44
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/themeboxes/highscores/highscores.png);\">
\t<div class=\"top_level\" style=\"background:url(";
        // line 45
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/themeboxes/bg_top.png)\" align=\"\t\">
    ";
        // line 46
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["topPlayers"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["player"]) {
            // line 47
            yield "\t    <div style=\"text-align:left\"><a href=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getPlayerLink')->getCallable()((($_v0 = $context["player"]) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0["name"] ?? null) : null), false), "html", null, true);
            yield " \" class=\"topfont ";
            if ((($_v1 = $context["player"]) && is_array($_v1) || $_v1 instanceof ArrayAccess ? ($_v1["online"] ?? null) : null)) {
                yield "online";
            } else {
                yield "offline";
            }
            yield "\">
\t\t\t";
            // line 48
            if ($this->env->getFunction('setting')->getCallable()("core.online_outfit")) {
                // line 49
                yield "\t\t\t\t<img style=\"position:absolute;margin-top:";
                if (CoreExtension::inFilter(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "looktype", [], "any", false, false, false, 49), $this->env->getFunction('setting')->getCallable()("core.outfit_images_wrong_looktypes"))) {
                    yield "-20px;margin-left:-0px;";
                } else {
                    yield "-45px;margin-left:-25px;";
                }
                yield "\" src=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "outfit", [], "any", false, false, false, 49), "html", null, true);
                yield "\" alt=\"player outfit\"/>
\t\t\t";
            }
            // line 51
            yield "\t\t\t\t<span style=\"color: #CCC; margin-left: 40px\">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v2 = $context["player"]) && is_array($_v2) || $_v2 instanceof ArrayAccess ? ($_v2["rank"] ?? null) : null), "html", null, true);
            yield " - </span>
\t\t\t\t";
            // line 52
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v3 = $context["player"]) && is_array($_v3) || $_v3 instanceof ArrayAccess ? ($_v3["name"] ?? null) : null), "html", null, true);
            yield "
\t\t\t<br>
\t\t\t<small><span style=\"color: white; margin-left: 50px\">Level: (";
            // line 54
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v4 = $context["player"]) && is_array($_v4) || $_v4 instanceof ArrayAccess ? ($_v4["level"] ?? null) : null), "html", null, true);
            yield ")</span></small>
\t\t\t<br>
\t\t</a>
\t</div>
\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['player'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 59
        yield "\t<div class=\"Bottom\" style=\"background-image:url(";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/general/box-bottom.gif); top: 159px;; left:-5px;\">
\t</div>
</div>
</div>
<br/><br/><br/>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "highscores.html.twig";
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
        return array (  145 => 59,  134 => 54,  129 => 52,  124 => 51,  112 => 49,  110 => 48,  99 => 47,  95 => 46,  91 => 45,  87 => 44,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "highscores.html.twig", "/var/www/html/templates/tibiacom/boxes/templates/highscores.html.twig");
    }
}
