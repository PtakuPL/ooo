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

/* online.html.twig */
class __TwigTemplate_e2240f2bc329d9a527da57d2a453f922 extends Template
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
        $context["onlineTTL"] = $this->env->getFunction('setting')->getCallable()("core.online_cache_ttl");
        // line 2
        if (((($context["onlineTTL"] ?? null) > 0) && CoreExtension::getAttribute($this->env, $this->source, ($context["cache"] ?? null), "enabled", [], "method", false, false, false, 2))) {
            // line 3
            yield "<small>*Note: Online List is updated every ";
            yield (((($context["onlineTTL"] ?? null) > 1)) ? ($this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((" " . ($context["onlineTTL"] ?? null)), "html", null, true)) : (""));
            yield " minute";
            yield (((($context["onlineTTL"] ?? null) > 1)) ? ("s") : (""));
            yield ".</small>
<br/>
";
        }
        // line 6
        yield "
";
        // line 8
        if ($this->env->getFunction('setting')->getCallable()("core.online_vocations")) {
            // line 9
            yield "<br/>
\t";
            // line 10
            if ($this->env->getFunction('setting')->getCallable()("core.online_vocations_images")) {
                // line 11
                yield "\t<table width=\"200\" cellspacing=\"1\" cellpadding=\"0\" border=\"0\" align=\"center\">
\t\t<tr bgcolor=\"";
                // line 12
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 12), "html", null, true);
                yield "\">
\t\t\t<td><img src=\"images/sorcerer.png\" /></td>
\t\t\t<td><img src=\"images/druid.png\" /></td>
\t\t\t<td><img src=\"images/paladin.png\" /></td>
\t\t\t<td><img src=\"images/knight.png\" /></td>
\t\t</tr>
\t\t<tr bgcolor=\"";
                // line 18
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 18), "html", null, true);
                yield "\">
\t\t\t<td class=\"white\" style=\"text-align: center;\"><strong>Sorcerers</strong></td>
\t\t\t<td class=\"white\" style=\"text-align: center;\"><strong>Druids</strong></td>
\t\t\t<td class=\"white\" style=\"text-align: center;\"><strong>Paladins</strong></td>
\t\t\t<td class=\"white\" style=\"text-align: center;\"><strong>Knights</strong></td>
\t\t</tr>
\t\t<tr bgcolor=\"";
                // line 24
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 24), "html", null, true);
                yield "\">
\t\t\t<td style=\"text-align: center;\">";
                // line 25
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v0 = ($context["vocs"] ?? null)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0[1] ?? null) : null), "html", null, true);
                yield "</td>
\t\t\t<td style=\"text-align: center;\">";
                // line 26
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v1 = ($context["vocs"] ?? null)) && is_array($_v1) || $_v1 instanceof ArrayAccess ? ($_v1[2] ?? null) : null), "html", null, true);
                yield "</td>
\t\t\t<td style=\"text-align: center;\">";
                // line 27
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v2 = ($context["vocs"] ?? null)) && is_array($_v2) || $_v2 instanceof ArrayAccess ? ($_v2[3] ?? null) : null), "html", null, true);
                yield "</td>
\t\t\t<td style=\"text-align: center;\">";
                // line 28
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v3 = ($context["vocs"] ?? null)) && is_array($_v3) || $_v3 instanceof ArrayAccess ? ($_v3[4] ?? null) : null), "html", null, true);
                yield "</td>
\t\t</tr>
\t</table>
\t<div style=\"text-align: center;\">&nbsp;</div>
\t\t";
            } else {
                // line 33
                yield "\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t<tr bgcolor=\"";
                // line 34
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 34), "html", null, true);
                yield "\">
\t\t\t<td class=\"white\" colspan=\"2\"><b>Vocation statistics</b></td>
\t\t</tr>

\t\t";
                // line 38
                $context['_parent'] = $context;
                $context['_seq'] = CoreExtension::ensureTraversable(range(1, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vocations_amount", [], "any", false, false, false, 38)));
                foreach ($context['_seq'] as $context["_key"] => $context["i"]) {
                    // line 39
                    yield "\t\t<tr bgcolor=\"";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()($context["i"]), "html", null, true);
                    yield "\">
\t\t\t<td width=\"25%\">";
                    // line 40
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v4 = CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vocations", [], "any", false, false, false, 40)) && is_array($_v4) || $_v4 instanceof ArrayAccess ? ($_v4[$context["i"]] ?? null) : null), "html", null, true);
                    yield "</td>
\t\t\t<td width=\"75%\">";
                    // line 41
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v5 = ($context["vocs"] ?? null)) && is_array($_v5) || $_v5 instanceof ArrayAccess ? ($_v5[$context["i"]] ?? null) : null), "html", null, true);
                    yield "</td>
\t\t</tr>
\t\t";
                }
                $_parent = $context['_parent'];
                unset($context['_seq'], $context['_key'], $context['i'], $context['_parent']);
                $context = array_intersect_key($context, $_parent) + $_parent;
                // line 44
                yield "\t</table>
<br/>
\t";
            }
        }
        // line 48
        yield "
<br/>

";
        // line 52
        if ($this->env->getFunction('setting')->getCallable()("core.online_skulls")) {
            // line 53
            yield "<table width=\"100%\" cellspacing=\"1\">
\t<tr>
\t\t<td style=\"background: ";
            // line 55
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 55), "html", null, true);
            yield ";\" align=\"center\">
\t\t\t<img src=\"images/white_skull.gif\"/> - 1 - 6 Frags<br/>
\t\t\t<img src=\"images/red_skull.gif\"/> - 6+ Frags or Red Skull<br/>
\t\t\t<img src=\"images/black_skull.gif\"/> - 10+ Frags or Black Skull
\t\t</td>
\t</tr>
</table>
";
        }
        // line 63
        yield "
<br/>

";
        // line 66
        $context["title"] = "World Information";
        // line 67
        $context["tableClass"] = "Table3";
        // line 68
        $context["background"] = $this->env->getFunction('config')->getCallable()("darkborder");
        // line 69
        $context["content"] = ('' === $tmp = \Twig\Extension\CoreExtension::captureOutput((function () use (&$context, $macros, $blocks) {
            // line 70
            yield "<table width=\"100%\">
\t<tr>
\t\t<td class=\"LabelV150\"><b>Status:</b></td>
\t\t<td>";
            // line 73
            if ( !CoreExtension::getAttribute($this->env, $this->source, ($context["status"] ?? null), "online", [], "any", false, false, false, 73)) {
                yield "Offline";
            } else {
                yield "Online";
            }
            yield "</td>
\t</tr>
\t<tr>
\t\t<td class=\"LabelV150\"><b>Players Online:</b></td>
\t\t<td>
\t\t\t";
            // line 78
            if ($this->env->getFunction('setting')->getCallable()("core.online_afk")) {
                // line 79
                yield "\t\t\t\t";
                $context["players_count"] = Twig\Extension\CoreExtension::length($this->env->getCharset(), ($context["players"] ?? null));
                // line 80
                yield "\t\t\t\t";
                $context["afk"] = (($context["players_count"] ?? null) - CoreExtension::getAttribute($this->env, $this->source, ($context["status"] ?? null), "players", [], "any", false, false, false, 80));
                // line 81
                yield "\t\t\t\t";
                if ((($context["afk"] ?? null) < 0)) {
                    // line 82
                    yield "\t\t\t\t\t";
                    $context["players_count"] = (($context["players_count"] ?? null) + abs(($context["afk"] ?? null)));
                    // line 83
                    yield "\t\t\t\t\t";
                    $context["afk"] = 0;
                    // line 84
                    yield "\t\t\t\t";
                }
                // line 85
                yield "\t\t\t\tCurrently there are <b>";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["status"] ?? null), "players", [], "any", false, false, false, 85), "html", null, true);
                yield "</b> active and <b>";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["afk"] ?? null), "html", null, true);
                yield "</b> AFK players.<br/>
\t\t\t\tTotal number of players: <b>";
                // line 86
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["players_count"] ?? null), "html", null, true);
                yield "</b>.<br/>
\t\t\t";
            } else {
                // line 88
                yield "\t\t\t\t";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::length($this->env->getCharset(), ($context["players"] ?? null)), "html", null, true);
                yield "
\t\t\t";
            }
            // line 90
            yield "\t\t</td>
\t</tr>

\t";
            // line 93
            if (($this->env->getFunction('setting')->getCallable()("core.online_record") && (Twig\Extension\CoreExtension::length($this->env->getCharset(), ($context["record"] ?? null)) > 0))) {
                // line 94
                yield "\t<tr>
\t\t<td class=\"LabelV150\"><b>Online Record:</b></td>
\t\t<td>
\t\t\t";
                // line 97
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["record"] ?? null), "html", null, true);
                yield "
\t\t</td>
\t</tr>
\t";
            }
            // line 101
            yield "
\t<tr>
\t\t<td class=\"LabelV150\"><b>Location Datacenter:</b></td>
\t\t<td>";
            // line 104
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('setting')->getCallable()("core.online_datacenter"), "html", null, true);
            yield " <small>(Server date & time: - ";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate("now", "d/m/Y H:i:s"), "html", null, true);
            yield ")</small></td>
\t</tr>
\t<tr>
\t\t<td class=\"LabelV150\"><b>PvP Type:</b></td>
\t\t<td>
\t\t\t";
            // line 109
            $context["worldType"] = Twig\Extension\CoreExtension::lower($this->env->getCharset(), (($_v6 = $this->env->getFunction('config')->getCallable()("lua")) && is_array($_v6) || $_v6 instanceof ArrayAccess ? ($_v6["worldType"] ?? null) : null));
            // line 110
            yield "\t\t\t";
            if (CoreExtension::inFilter(($context["worldType"] ?? null), ["pvp", "2", "normal", "open", "openpvp"])) {
                // line 111
                yield "\t\t\tOpen PvP
\t\t\t";
            } elseif (CoreExtension::inFilter(            // line 112
($context["worldType"] ?? null), ["no-pvp", "nopvp", "non-pvp", "nonpvp", "1", "safe", "optional", "optionalpvp"])) {
                // line 113
                yield "\t\t\tOptional PvP
\t\t\t";
            } elseif (CoreExtension::inFilter(            // line 114
($context["worldType"] ?? null), ["pvp-enforced", "pvpenforced", "pvp-enfo", "pvpenfo", "pvpe", "enforced", "enfo", "3", "war", "hardcore", "hardcorepvp"])) {
                // line 115
                yield "\t\t\tHardcore PvP
\t\t\t";
            }
            // line 117
            yield "\t\t</td>
\t</tr>
</table>
";
            yield from [];
        })())) ? '' : new Markup($tmp, $this->env->getCharset());
        // line 121
        yield from $this->loadTemplate("tables.headline.html.twig", "online.html.twig", 121)->unwrap()->yield($context);
        // line 122
        yield "<br/>
<br/>

";
        // line 125
        $context["title"] = "Players Online";
        // line 126
        $context["tableClass"] = "Table2";
        // line 127
        $context["content"] = ('' === $tmp = \Twig\Extension\CoreExtension::captureOutput((function () use (&$context, $macros, $blocks) {
            // line 128
            yield "<table width=\"100%\">
\t<tr class=\"LabelH\" style=\"position: relative; z-index: 20;\">
\t\t";
            // line 130
            if ($this->env->getFunction('setting')->getCallable()("core.account_country")) {
                // line 131
                yield "\t\t\t<td width=\"11px\"><a href=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("online"), "html", null, true);
                yield "?order=country_";
                yield (((($context["order"] ?? null) == "country_asc")) ? ("desc") : ("asc"));
                yield "\">#&#160;&#160;</a>
\t\t\t</td>
\t\t";
            }
            // line 134
            yield "\t\t";
            if ($this->env->getFunction('setting')->getCallable()("core.online_outfit")) {
                // line 135
                yield "\t\t\t<td><b>Outfit</b></td>
\t\t";
            }
            // line 137
            yield "\t\t<td style=\"text-align:left; width:50%\">Name&#160;&#160;
\t\t\t<small style=\"font-weight:normal\">[<a href=\"";
            // line 138
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("online"), "html", null, true);
            yield "?order=name_";
            yield (((($context["order"] ?? null) == "name_asc")) ? ("desc") : ("asc"));
            yield "\">sort</a>]</small>
\t\t\t<img class=\"sortarrow\" src=\"images/";
            // line 139
            yield (((($context["order"] ?? null) == "name_asc")) ? ("order_desc") : ((((($context["order"] ?? null) == "name_desc")) ? ("order_asc") : ("news/blank"))));
            yield ".gif\"/></td>
\t\t<td style=\"text-align:left;width:30%\">Level&#160;&#160;
\t\t\t<small style=\"font-weight:normal\">[<a href=\"";
            // line 141
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("online"), "html", null, true);
            yield "?order=level_";
            yield (((($context["order"] ?? null) == "level_asc")) ? ("desc") : ("asc"));
            yield "\">sort</a>]</small>
\t\t\t<img class=\"sortarrow\" src=\"images/";
            // line 142
            yield (((($context["order"] ?? null) == "level_asc")) ? ("order_desc") : ((((($context["order"] ?? null) == "level_desc")) ? ("order_asc") : ("news/blank"))));
            yield ".gif\"/>
\t\t</td>
\t\t<td style=\"text-align:left;width:50%\">Vocation&#160;&#160;
\t\t\t<small style=\"font-weight:normal\">[<a href=\"";
            // line 145
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("online"), "html", null, true);
            yield "?order=vocation_";
            yield (((($context["order"] ?? null) == "vocation_asc")) ? ("desc") : ("asc"));
            yield "\">sort</a>]</small>
\t\t\t<img class=\"sortarrow\" src=\"images/";
            // line 146
            yield (((($context["order"] ?? null) == "vocation_asc")) ? ("order_desc") : ((((($context["order"] ?? null) == "vocation_desc")) ? ("order_asc") : ("news/blank"))));
            yield ".gif\"/>
\t\t</td>
\t</tr>

\t";
            // line 150
            $context["i"] = 0;
            // line 151
            yield "\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["players"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["player"]) {
                // line 152
                yield "\t\t";
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 153
                yield "
\t\t<tr style=\"background: ";
                // line 154
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
                yield "; text-align: right; height: 40px;\">
\t\t\t";
                // line 155
                if ($this->env->getFunction('setting')->getCallable()("core.account_country")) {
                    // line 156
                    yield "\t\t\t\t<td>";
                    yield CoreExtension::getAttribute($this->env, $this->source, $context["player"], "country_image", [], "any", false, false, false, 156);
                    yield "</td>
\t\t\t";
                }
                // line 158
                yield "
\t\t\t";
                // line 159
                if ($this->env->getFunction('setting')->getCallable()("core.online_outfit")) {
                    // line 160
                    yield "\t\t\t\t<td width=\"5%\"><img style=\"position:absolute;margin-top:-48px;margin-left:-70px;\" src=\"";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "outfit", [], "any", false, false, false, 160), "html", null, true);
                    yield "\" alt=\"player outfit\"/></td>
\t\t\t";
                }
                // line 162
                yield "
\t\t\t<td style=\"width:70%; text-align:left\">
\t\t\t\t";
                // line 164
                yield CoreExtension::getAttribute($this->env, $this->source, $context["player"], "name", [], "any", false, false, false, 164);
                yield CoreExtension::getAttribute($this->env, $this->source, $context["player"], "skull", [], "any", false, false, false, 164);
                yield "
\t\t\t</td>
\t\t\t<td style=\"width:10%\">";
                // line 166
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "level", [], "any", false, false, false, 166), "html", null, true);
                yield "</td>
\t\t\t<td style=\"width:20%\">";
                // line 167
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "vocation", [], "any", false, false, false, 167), "html", null, true);
                yield "</td>
\t\t</tr>
\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['player'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 170
            yield "</table>
";
            yield from [];
        })())) ? '' : new Markup($tmp, $this->env->getCharset());
        // line 172
        yield Twig\Extension\CoreExtension::include($this->env, $context, "tables.headline.html.twig");
        yield "
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "online.html.twig";
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
        return array (  436 => 172,  431 => 170,  422 => 167,  418 => 166,  412 => 164,  408 => 162,  402 => 160,  400 => 159,  397 => 158,  391 => 156,  389 => 155,  385 => 154,  382 => 153,  379 => 152,  374 => 151,  372 => 150,  365 => 146,  359 => 145,  353 => 142,  347 => 141,  342 => 139,  336 => 138,  333 => 137,  329 => 135,  326 => 134,  317 => 131,  315 => 130,  311 => 128,  309 => 127,  307 => 126,  305 => 125,  300 => 122,  298 => 121,  291 => 117,  287 => 115,  285 => 114,  282 => 113,  280 => 112,  277 => 111,  274 => 110,  272 => 109,  262 => 104,  257 => 101,  250 => 97,  245 => 94,  243 => 93,  238 => 90,  232 => 88,  227 => 86,  220 => 85,  217 => 84,  214 => 83,  211 => 82,  208 => 81,  205 => 80,  202 => 79,  200 => 78,  188 => 73,  183 => 70,  181 => 69,  179 => 68,  177 => 67,  175 => 66,  170 => 63,  159 => 55,  155 => 53,  153 => 52,  148 => 48,  142 => 44,  133 => 41,  129 => 40,  124 => 39,  120 => 38,  113 => 34,  110 => 33,  102 => 28,  98 => 27,  94 => 26,  90 => 25,  86 => 24,  77 => 18,  68 => 12,  65 => 11,  63 => 10,  60 => 9,  58 => 8,  55 => 6,  46 => 3,  44 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "online.html.twig", "/var/www/html/system/templates/online.html.twig");
    }
}
