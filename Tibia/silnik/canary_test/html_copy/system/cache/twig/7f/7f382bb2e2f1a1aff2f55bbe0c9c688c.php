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

/* characters.html.twig */
class __TwigTemplate_9d0322d13c3e0497e6e0c34ef70e3ec3 extends Template
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
        yield "<script type=\"text/javascript\" src=\"tools/js/tipped.js\"></script>
<link rel=\"stylesheet\" type=\"text/css\" href=\"tools/css/tipped.css\"/>
<script>
\t\$(document).ready(function() {
\t    Tipped.create('.item_image');
\t});
</script>
";
        // line 8
        $context["rows"] = 0;
        // line 9
        yield "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\"><tr>
\t<td><img src=\"";
        // line 10
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/general/blank.gif\" width=\"10\" height=\"1\" border=\"0\"></td>
\t<td>
        ";
        // line 12
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_BEFORE_INFORMATIONS")), "html", null, true);
        yield "
\t\t";
        // line 13
        if (($context["canEdit"] ?? null)) {
            // line 14
            yield "\t\t\t<a href=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
            yield "?p=players&id=";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getId", [], "method", false, false, false, 14), "html", null, true);
            yield "\" title=\"Edit in Admin Panel\" target=\"_blank\">
\t\t\t\t<img src=\"images/edit.png\"/>Edit
\t\t\t</a>
\t\t";
        }
        // line 18
        yield "\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t\t";
        // line 19
        if (CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "characters", [], "any", false, false, false, 19), "outfit", [], "any", false, false, false, 19)) {
            // line 20
            yield "\t\t\t<div style=\"width:64px;height:64px;border:2px solid #F1E0C6; border-radius:50px; padding:13px; margin-top:38px;margin-left:376px;position:absolute;\"><img style=\"margin-left:";
            if (CoreExtension::inFilter(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getLookType", [], "method", false, false, false, 20), $this->env->getFunction('setting')->getCallable()("core.outfit_images_wrong_looktypes"))) {
                yield "-0px;margin-top:-0px;width:64px;height:64px;";
            } else {
                yield "-60px;margin-top:-60px;width:128px;height:128px;";
            }
            yield "\" src=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["outfit"] ?? null), "html", null, true);
            yield "\" alt=\"player outfit\"/></div>
\t\t\t";
        }
        // line 22
        yield "
\t\t\t<tr bgcolor=\"";
        // line 23
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 23), "html", null, true);
        yield "\">
\t\t\t\t<td colspan=\"2\" class=\"white\"><b>Character Information</b></td>
\t\t\t</tr>

\t\t\t";
        // line 27
        $context["rows"] = (($context["rows"] ?? null) + 1);
        // line 28
        yield "\t\t\t<tr bgcolor=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
        yield "\">
\t\t\t\t<td width=\"20%\">Name:</td>
\t\t\t\t<td>";
        // line 30
        yield ($context["flag"] ?? null);
        yield " <span style=\"color: ";
        if (CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "isOnline", [], "method", false, false, false, 30)) {
            yield "green";
        } else {
            yield "red";
        }
        yield "\"><b>";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getName", [], "method", false, false, false, 30), "html", null, true);
        yield "</b></span>";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["oldName"] ?? null), "html", null, true);
        yield "</td>
\t\t\t</tr>

\t\t\t";
        // line 33
        $context["rows"] = (($context["rows"] ?? null) + 1);
        // line 34
        yield "\t\t\t<tr bgcolor=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
        yield "\">
\t\t\t\t<td>Sex:</td>
\t\t\t\t<td>";
        // line 36
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["sex"] ?? null), "html", null, true);
        yield "</td>
\t\t\t</tr>

\t\t\t";
        // line 39
        if (($context["marriage_enabled"] ?? null)) {
            // line 40
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 41
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>Marital status:</td>
\t\t\t\t<td>";
            // line 43
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["marital_status"] ?? null), "html", null, true);
            yield "</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 46
        yield "
\t\t\t";
        // line 47
        $context["rows"] = (($context["rows"] ?? null) + 1);
        // line 48
        yield "\t\t\t<tr bgcolor=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
        yield "\">
\t\t\t\t<td>Profession:</td>
\t\t\t\t<td>";
        // line 50
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["vocation"] ?? null), "html", null, true);
        yield "</td>
\t\t\t</tr>

\t\t\t";
        // line 53
        if (CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "characters", [], "any", false, false, false, 53), "level", [], "any", false, false, false, 53)) {
            // line 54
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 55
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>Level:</td>
\t\t\t\t<td>";
            // line 57
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getLevel", [], "method", false, false, false, 57), "html", null, true);
            yield "</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 60
        yield "
\t\t\t";
        // line 61
        if (CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "characters", [], "any", false, false, false, 61), "experience", [], "any", false, false, false, 61)) {
            // line 62
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 63
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>Experience:</td>
\t\t\t\t<td>";
            // line 65
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getExperience", [], "method", false, false, false, 65), "html", null, true);
            yield "</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 68
        yield "
\t\t\t";
        // line 69
        if (CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "characters", [], "any", false, false, false, 69), "magic_level", [], "any", false, false, false, 69)) {
            // line 70
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 71
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>Magic Level:</td>
\t\t\t\t<td>";
            // line 73
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getMagLevel", [], "method", false, false, false, 73), "html", null, true);
            yield "</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 76
        yield "
\t\t\t";
        // line 77
        if (($context["frags_enabled"] ?? null)) {
            // line 78
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 79
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>Frags:</td>
\t\t\t\t<td>";
            // line 81
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["frags_count"] ?? null), "html", null, true);
            yield "</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 84
        yield "
\t\t\t";
        // line 85
        $context["rows"] = (($context["rows"] ?? null) + 1);
        // line 86
        yield "\t\t\t<tr bgcolor=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
        yield "\">
\t\t\t\t<td>Residence:</td>
\t\t\t\t<td>";
        // line 88
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["town"] ?? null), "html", null, true);
        yield "</td>
\t\t\t</tr>

\t\t\t";
        // line 91
        if (CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "characters", [], "any", false, false, false, 91), "balance", [], "any", false, false, false, 91)) {
            // line 92
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 93
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>Balance:</td>
\t\t\t\t<td>";
            // line 95
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getBalance", [], "method", false, false, false, 95), "html", null, true);
            yield " Gold Coins.</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 98
        yield "
\t\t\t";
        // line 99
        if (CoreExtension::getAttribute($this->env, $this->source, ($context["house"] ?? null), "found", [], "any", false, false, false, 99)) {
            // line 100
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 101
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>House:</td>
\t\t\t\t<td>
\t\t\t\t\t<table border=\"0\">
\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t<td>";
            // line 106
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(((CoreExtension::getAttribute($this->env, $this->source, ($context["house"] ?? null), "name", [], "any", false, false, false, 106) . CoreExtension::getAttribute($this->env, $this->source, ($context["house"] ?? null), "town", [], "any", false, false, false, 106)) . CoreExtension::getAttribute($this->env, $this->source, ($context["house"] ?? null), "add", [], "any", false, false, false, 106)), "html", null, true);
            yield "</td>
\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t<form action=\"?subtopic=houses&page=view\" method=\"post\">
\t\t\t\t\t\t\t\t\t";
            // line 109
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"house\" value=\"";
            // line 110
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["house"] ?? null), "name", [], "any", false, false, false, 110), "html", null, true);
            yield "\">
\t\t\t\t\t\t\t\t\t<input type=\"image\" name=\"View\" alt=\"View\" src=\"";
            // line 111
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/global/buttons/sbutton_view.gif\" border=\"0\" width=\"120\">
\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t</table>
\t\t\t\t</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 119
        yield "
\t\t\t";
        // line 120
        if ( !(null === CoreExtension::getAttribute($this->env, $this->source, ($context["guild"] ?? null), "rank", [], "any", false, false, false, 120))) {
            // line 121
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 122
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>Guild membership:</td>
\t\t\t\t<td>";
            // line 124
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["guild"] ?? null), "rank", [], "any", false, false, false, 124), "html", null, true);
            yield " of the ";
            yield CoreExtension::getAttribute($this->env, $this->source, ($context["guild"] ?? null), "link", [], "any", false, false, false, 124);
            yield "</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 127
        yield "
\t\t\t";
        // line 128
        $context["rows"] = (($context["rows"] ?? null) + 1);
        // line 129
        yield "\t\t\t<tr bgcolor=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
        yield "\">
\t\t\t\t<td>Last login:</td>
\t\t\t\t<td>";
        // line 131
        if ((CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getLastLogin", [], "method", false, false, false, 131) == 0)) {
            yield "Never logged in.";
        } else {
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getLastLogin", [], "method", false, false, false, 131), "M d Y, H:i:s"), "html", null, true);
            yield " CEST";
        }
        yield "</td>
\t\t\t</tr>

\t\t\t";
        // line 134
        if (CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "characters", [], "any", false, false, false, 134), "creation_date", [], "any", false, false, false, 134)) {
            // line 135
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 136
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td>Created:</td>
\t\t\t\t<td>";
            // line 138
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getCreated", [], "method", false, false, false, 138), "M d Y, H:i:s"), "html", null, true);
            yield " CEST</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 141
        yield "
\t\t\t";
        // line 142
        if ( !(null === ($context["comment"] ?? null))) {
            // line 143
            yield "\t\t\t";
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 144
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td valign=\"top\">Comment:</td>
\t\t\t\t<td style=\"word-break: break-all\">";
            // line 146
            yield ($context["comment"] ?? null);
            yield "</td>
\t\t\t</tr>
\t\t\t";
        }
        // line 149
        yield "
\t\t\t";
        // line 150
        $context["rows"] = (($context["rows"] ?? null) + 1);
        // line 151
        yield "\t\t\t<tr bgcolor=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
        yield "\">
\t\t\t\t<td>Account Status:</td>
\t\t\t\t<td>";
        // line 153
        if (CoreExtension::getAttribute($this->env, $this->source, ($context["account"] ?? null), "isPremium", [], "method", false, false, false, 153)) {
            yield "Premium Account";
        } else {
            yield "Free Account";
        }
        yield "</td>
\t\t\t</tr>
\t\t</table>
\t\t";
        // line 156
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_AFTER_INFORMATIONS")), "html", null, true);
        yield "
\t\t<br/>
\t\t<table border=\"0\" width=\"100%\">
\t\t\t<tr>
\t\t\t\t";
        // line 160
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_BEFORE_SKILLS")), "html", null, true);
        yield "

\t\t\t\t";
        // line 162
        if (CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "characters", [], "any", false, false, false, 162), "skills", [], "any", false, false, false, 162)) {
            // line 163
            yield "\t\t\t\t<!-- SKILLS -->
\t\t\t\t<td width=\"30%\" valign=\"top\">
\t\t\t\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t\t\t\t\t<tr bgcolor=\"";
            // line 166
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 166), "html", null, true);
            yield "\">
\t\t\t\t\t\t\t<td colspan=\"2\" class=\"white\"><B>Skills</b></td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            // line 169
            $context["i"] = 0;
            // line 170
            yield "\t\t\t\t\t\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["skills"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["skill"]) {
                // line 171
                yield "\t\t\t\t\t\t";
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 172
                yield "\t\t\t\t\t\t<tr bgcolor=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
                yield "\">
\t\t\t\t\t\t\t<td valign=\"top\">";
                // line 173
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["skill"], "name", [], "any", false, false, false, 173), "html", null, true);
                yield "</td>
\t\t\t\t\t\t\t<td>";
                // line 174
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["skill"], "value", [], "any", false, false, false, 174), "html", null, true);
                yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['skill'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 177
            yield "\t\t\t\t\t</table>
\t\t\t\t</td>
\t\t\t\t<!-- SKILLS_END -->
\t\t\t\t";
        }
        // line 181
        yield "
\t\t\t\t";
        // line 182
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_AFTER_SKILLS")), "html", null, true);
        yield "

\t\t\t\t";
        // line 184
        if (($context["quests_enabled"] ?? null)) {
            // line 185
            yield "\t\t\t\t<!-- QUESTS -->
\t\t\t\t<td width=\"40%\" valign=\"top\">
\t\t\t\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t\t\t\t\t<tr bgcolor=\"";
            // line 188
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 188), "html", null, true);
            yield "\">
\t\t\t\t\t\t\t<td colspan=\"2\" class=\"white\"><b>Quests</b></td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            // line 191
            $context["i"] = 0;
            // line 192
            yield "\t\t\t\t\t\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["quests"] ?? null));
            foreach ($context['_seq'] as $context["name"] => $context["done"]) {
                // line 193
                yield "\t\t\t\t\t\t";
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 194
                yield "\t\t\t\t\t\t<tr bgcolor=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
                yield "\">
\t\t\t\t\t\t\t<td valign=\"top\">";
                // line 195
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["name"], "html", null, true);
                yield "</TD>
\t\t\t\t\t\t\t<td><img src=\"images/";
                // line 196
                if ($context["done"]) {
                    yield "true";
                } else {
                    yield "false";
                }
                yield ".png\" border=\"0\"/></td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['name'], $context['done'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 199
            yield "\t\t\t\t\t</table>
\t\t\t\t</td>
\t\t\t\t<!-- QUESTS_END -->
\t\t\t\t";
        }
        // line 203
        yield "
\t\t\t\t";
        // line 204
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_AFTER_QUESTS")), "html", null, true);
        yield "

\t\t\t\t";
        // line 206
        if (CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "characters", [], "any", false, false, false, 206), "equipment", [], "any", false, false, false, 206)) {
            // line 207
            yield "\t\t\t\t<!-- EQUIPMENT -->
\t\t\t\t<td width=\"100\" valign=\"top\">
\t\t\t\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t\t\t\t\t<tr bgcolor=\"";
            // line 210
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 210), "html", null, true);
            yield "\">
\t\t\t\t\t\t\t<td colspan=\"2\" class=\"white\"><b>Equipment</b></td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t<tr bgcolor=\"";
            // line 213
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(1), "html", null, true);
            yield "\">
\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t<table width=\"100\" align=\"center\" cellspacing=\"0\" cellpadding=\"0\" style=\"background: #808080; border:1px solid #808080;\">
\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t\t\t\t<table cellspacing=\"0\" style=\"background: #292929;\">
\t\t\t\t\t\t\t\t\t\t\t\t<tr><td style=\"border:1px solid #808080;\">";
            // line 219
            yield (($_v0 = ($context["equipment"] ?? null)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0[2] ?? null) : null);
            yield "</td></tr><tr><td style=\"border:1px solid #808080;\">";
            yield (($_v1 = ($context["equipment"] ?? null)) && is_array($_v1) || $_v1 instanceof ArrayAccess ? ($_v1[6] ?? null) : null);
            yield "</td></tr><tr><td style=\"border:1px solid #808080;\">";
            yield (($_v2 = ($context["equipment"] ?? null)) && is_array($_v2) || $_v2 instanceof ArrayAccess ? ($_v2[9] ?? null) : null);
            yield "</td></tr>
\t\t\t\t\t\t\t\t\t\t\t\t<tr height=\"11px\"><td>";
            // line 220
            if ( !(null === ($context["skull"] ?? null))) {
                yield "<img src=\"images/";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["skull"] ?? null), "html", null, true);
                yield ".gif\">";
            }
            yield "</td></tr>
\t\t\t\t\t\t\t\t\t\t\t</table>
\t\t\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t\t\t\t<table cellspacing=\"0\" style=\"background: #292929;\">
\t\t\t\t\t\t\t\t\t\t\t\t<tr><td style=\"border:1px solid #808080;\">";
            // line 225
            yield (($_v3 = ($context["equipment"] ?? null)) && is_array($_v3) || $_v3 instanceof ArrayAccess ? ($_v3[1] ?? null) : null);
            yield "</td></tr><tr><td style=\"border:1px solid #808080;\">";
            yield (($_v4 = ($context["equipment"] ?? null)) && is_array($_v4) || $_v4 instanceof ArrayAccess ? ($_v4[4] ?? null) : null);
            yield "</td></tr><tr><td style=\"border:1px solid #808080;\">";
            yield (($_v5 = ($context["equipment"] ?? null)) && is_array($_v5) || $_v5 instanceof ArrayAccess ? ($_v5[7] ?? null) : null);
            yield "</td></tr><tr><td style=\"border:1px solid #808080;\">";
            yield (($_v6 = ($context["equipment"] ?? null)) && is_array($_v6) || $_v6 instanceof ArrayAccess ? ($_v6[8] ?? null) : null);
            yield "</td></tr>
\t\t\t\t\t\t\t\t\t\t\t</table>
\t\t\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t\t\t\t<table cellspacing=\"0\" style=\"background: #292929;\">
\t\t\t\t\t\t\t\t\t\t\t\t<tr><td style=\"border:1px solid #808080;\">";
            // line 230
            yield (($_v7 = ($context["equipment"] ?? null)) && is_array($_v7) || $_v7 instanceof ArrayAccess ? ($_v7[3] ?? null) : null);
            yield "</td></tr><tr><td style=\"border:1px solid #808080;\">";
            yield (($_v8 = ($context["equipment"] ?? null)) && is_array($_v8) || $_v8 instanceof ArrayAccess ? ($_v8[5] ?? null) : null);
            yield "</td></tr><tr><td style=\"border:1px solid #808080;\">";
            yield (($_v9 = ($context["equipment"] ?? null)) && is_array($_v9) || $_v9 instanceof ArrayAccess ? ($_v9[10] ?? null) : null);
            yield "</td></tr>
\t\t\t\t\t\t\t\t\t\t\t</table>
\t\t\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t</table>
\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t</table>
\t\t\t\t</td>
\t\t\t\t<!-- EQUIPMENT_END -->
\t\t\t\t";
        }
        // line 241
        yield "
\t\t\t\t";
        // line 242
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_AFTER_EQUIPMENT")), "html", null, true);
        yield "
\t\t\t</tr>
\t\t</table>

\t\t";
        // line 246
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_BEFORE_DEATHS")), "html", null, true);
        yield "

\t\t";
        // line 248
        if ((Twig\Extension\CoreExtension::length($this->env->getCharset(), ($context["deaths"] ?? null)) > 0)) {
            // line 249
            yield "\t\t<!-- DEATHS -->
\t\t<br/>
\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t\t<tr bgcolor=\"";
            // line 252
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 252), "html", null, true);
            yield "\">
\t\t\t\t<td colspan=\"2\" class=\"white\"><b>Character Deaths</b></td>
\t\t\t</tr>
\t\t\t";
            // line 255
            $context["i"] = 0;
            // line 256
            yield "\t\t\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["deaths"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["death"]) {
                // line 257
                yield "\t\t\t<tr bgcolor=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
                yield "\">
\t\t\t\t<td width=\"20%\" align=\"center\">";
                // line 258
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, $context["death"], "time", [], "any", false, false, false, 258), "j M Y, H:i"), "html", null, true);
                yield "</td>
\t\t\t\t<td>";
                // line 259
                yield CoreExtension::getAttribute($this->env, $this->source, $context["death"], "description", [], "any", false, false, false, 259);
                yield "</td>
\t\t\t</tr>

\t\t\t";
                // line 262
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 263
                yield "\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['death'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 264
            yield "\t\t</table>
\t\t<!-- DEATHS_END -->
\t\t";
        }
        // line 267
        yield "\t\t";
        if ((Twig\Extension\CoreExtension::length($this->env->getCharset(), ($context["frags"] ?? null)) > 0)) {
            // line 268
            yield "\t\t<!-- FRAGS -->
\t\t<br/>
\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t\t<tr bgcolor=\"";
            // line 271
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 271), "html", null, true);
            yield "\">
\t\t\t\t<td colspan=\"2\" class=\"white\"><b>Victims</b></td>
\t\t\t</tr>
\t\t\t";
            // line 274
            $context["i"] = 0;
            // line 275
            yield "\t\t\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["frags"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["frag"]) {
                // line 276
                yield "\t\t\t<tr bgcolor=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
                yield "\">
\t\t\t\t<td width=\"20%\" align=\"center\">";
                // line 277
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, $context["frag"], "time", [], "any", false, false, false, 277), "j M Y, H:i"), "html", null, true);
                yield "</td>
\t\t\t\t<td>";
                // line 278
                yield CoreExtension::getAttribute($this->env, $this->source, $context["frag"], "description", [], "any", false, false, false, 278);
                yield " (";
                if (CoreExtension::getAttribute($this->env, $this->source, $context["frag"], "unjustified", [], "any", false, false, false, 278)) {
                    yield "<span style=\"color: red; font-size: 10px\">Unjustified</span>";
                } else {
                    yield "<span style=\"color: green; font-size: 10px\">Justified</span>";
                }
                yield ")</td>
\t\t\t</tr>
\t\t\t";
                // line 280
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 281
                yield "\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['frag'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 282
            yield "\t\t</table>
\t\t<!-- FRAGS_END -->
\t\t";
        }
        // line 285
        yield "
\t\t";
        // line 286
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_BEFORE_SIGNATURE")), "html", null, true);
        yield "

\t\t";
        // line 288
        if ($this->env->getFunction('setting')->getCallable()("core.signature_enabled")) {
            // line 289
            yield "\t\t<!-- SIGNATURE -->
\t\t<script type=\"text/javascript\">
\t\t\tfunction showSignLinks()
\t\t\t{
\t\t\t\tif(document.getElementById('signLinks').style.display == \"none\")
\t\t\t\t{
\t\t\t\t\tdocument.getElementById('signLinks').style.display = \"inline\";
\t\t\t\t\tdocument.getElementById('signText').innerHTML = \"Hide links\";
\t\t\t\t}
\t\t\t\telse
\t\t\t\t{
\t\t\t\t\tdocument.getElementById('signLinks').style.display = \"none\";
\t\t\t\t\tdocument.getElementById('signText').innerHTML = \"Show links\";
\t\t\t\t}
\t\t\t}
\t\t</script>
\t\t<br/>
\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\"><tr bgcolor=\"";
            // line 306
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 306), "html", null, true);
            yield "\"><td colspan=2 class=\"white\"><b>Signature</b></td></tr>
\t\t\t<tr bgcolor=\"";
            // line 307
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 307), "html", null, true);
            yield "\"><td align=\"center\" valign=\"top\">
\t\t\t\t<img src=\"";
            // line 308
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["signature_url"] ?? null), "html", null, true);
            yield "\" alt=\"Signature for player ";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getName", [], "method", false, false, false, 308), "html", null, true);
            yield "\">
\t\t\t\t<br/>
\t\t\t\t<b><a href=\"#\" onclick=\"showSignLinks(); return false;\" id=\"signText\">Show links</a></b>
\t\t\t\t<br/>
\t\t\t\t<table id=\"signLinks\" style=\"display: none;\">
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td>Website:</td>
\t\t\t\t\t\t<td><input type=\"text\" value=\"<a href=&quot;";
            // line 315
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["player_link"] ?? null), "html", null, true);
            yield "&quot;><img src=&quot;";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["signature_url"] ?? null), "html", null, true);
            yield "&quot;></a>\" style=\"width: 400px;\" onclick=\"this.select()\"></td>
\t\t\t\t\t</tr>
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td>Forum:</td>
\t\t\t\t\t\t<td><input type=\"text\" value=\"[URL=";
            // line 319
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["player_link"] ?? null), "html", null, true);
            yield "][IMG]";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["signature_url"] ?? null), "html", null, true);
            yield "[/IMG][/URL]\" style=\"width: 400px;\" onclick=\"this.select()\"></td>
\t\t\t\t\t</tr>
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td>Direct link:</td>
\t\t\t\t\t\t<td><input type=\"text\" value=\"";
            // line 323
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["signature_url"] ?? null), "html", null, true);
            yield "\" style=\"width: 400px;\" onclick=\"this.select()\"></td>
\t\t\t\t\t</tr>
\t\t\t\t</table>
\t\t\t</td></tr>
\t\t</table>
\t\t<!-- SIGNATURE_END -->
\t\t";
        }
        // line 330
        yield "\t\t";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_AFTER_SIGNATURE")), "html", null, true);
        yield "
\t\t";
        // line 331
        if ( !CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "isHidden", [], "method", false, false, false, 331)) {
            // line 332
            yield "\t\t";
            $context["rows"] = 0;
            // line 333
            yield "\t\t<!-- ACCOUNT_INFORMATION -->
\t\t<br/><br/>
\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t\t<tr bgcolor=\"";
            // line 336
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 336), "html", null, true);
            yield "\">
\t\t\t\t<td colspan=\"2\" class=\"white\"><b>Account Information</b></td>
\t\t\t</tr>

\t\t\t";
            // line 340
            $context["realName"] = CoreExtension::getAttribute($this->env, $this->source, ($context["account"] ?? null), "getRLName", [], "method", false, false, false, 340);
            // line 341
            yield "\t\t\t";
            if ( !Twig\Extension\CoreExtension::testEmpty(($context["realName"] ?? null))) {
                // line 342
                yield "\t\t\t";
                $context["rows"] = (($context["rows"] ?? null) + 1);
                // line 343
                yield "\t\t\t<tr bgcolor=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
                yield "\">
\t\t\t\t<td width=\"20%\">Real name:</td>
\t\t\t\t<td>";
                // line 345
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["realName"] ?? null), "html", null, true);
                yield "</td>
\t\t\t</tr>
\t\t\t";
            }
            // line 348
            yield "
\t\t\t";
            // line 349
            $context["group"] = CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getGroup", [], "method", false, false, false, 349);
            // line 350
            yield "\t\t\t";
            if ((CoreExtension::getAttribute($this->env, $this->source, ($context["group"] ?? null), "isLoaded", [], "method", false, false, false, 350) && (CoreExtension::getAttribute($this->env, $this->source, ($context["group"] ?? null), "getId", [], "method", false, false, false, 350) != 1))) {
                // line 351
                yield "\t\t\t";
                $context["rows"] = (($context["rows"] ?? null) + 1);
                // line 352
                yield "\t\t\t<tr bgcolor=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
                yield "\">
\t\t\t\t<td>Position:</td>
\t\t\t\t<td>";
                // line 354
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::capitalize($this->env->getCharset(), CoreExtension::getAttribute($this->env, $this->source, ($context["group"] ?? null), "getName", [], "method", false, false, false, 354)), "html", null, true);
                yield "</td>
\t\t\t</tr>
\t\t\t";
            }
            // line 357
            yield "
\t\t\t";
            // line 358
            $context["realLocation"] = CoreExtension::getAttribute($this->env, $this->source, ($context["account"] ?? null), "getLocation", [], "method", false, false, false, 358);
            // line 359
            yield "\t\t\t";
            if ( !Twig\Extension\CoreExtension::testEmpty(($context["realLocation"] ?? null))) {
                // line 360
                yield "\t\t\t";
                $context["rows"] = (($context["rows"] ?? null) + 1);
                // line 361
                yield "\t\t\t<tr bgcolor=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
                yield "\">
\t\t\t\t<td width=\"20%\">Location:</td>
\t\t\t\t<td>";
                // line 363
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["realLocation"] ?? null), "html", null, true);
                yield "</td>
\t\t\t</tr>
\t\t\t";
            }
            // line 366
            yield "
\t\t\t";
            // line 367
            $context["rows"] = (($context["rows"] ?? null) + 1);
            // line 368
            yield "\t\t\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["rows"] ?? null)), "html", null, true);
            yield "\">
\t\t\t\t<td width=\"20%\">Created:</td>
\t\t\t\t<td>";
            // line 370
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, ($context["account"] ?? null), "getCreated", [], "method", false, false, false, 370), "j F Y, g:i a"), "html", null, true);
            yield "
\t\t\t\t\t";
            // line 371
            if ((CoreExtension::matches("/^\\d+\$/", ($context["bannedUntil"] ?? null)) || (($context["bannedUntil"] ?? null) == "-1"))) {
                // line 372
                yield "\t\t\t\t\t\t<span style=\"color: red\">[Banished ";
                if ((($context["bannedUntil"] ?? null) == "-1")) {
                    yield "forever";
                } else {
                    yield "until ";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(($context["bannedUntil"] ?? null), "d F Y, h:s"), "html", null, true);
                }
                yield "]</span>
\t\t\t\t\t";
            } else {
                // line 374
                yield "\t\t\t\t\t";
                yield ($context["bannedUntil"] ?? null);
                yield "
\t\t\t\t\t";
            }
            // line 376
            yield "\t\t\t\t</td>
\t\t\t</tr>
\t\t</table>
\t\t<!-- ACCOUNT_INFORMATION_END -->
\t\t";
            // line 380
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_AFTER_ACCOUNT")), "html", null, true);
            yield "
\t\t<!-- CHARACTERS_LIST -->
\t\t<br/><br/>
\t\t<table border=\"0\" cellspacing=\"1\" cellpadding=\"4\" width=\"100%\">
\t\t\t<tr bgcolor=\"";
            // line 384
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 384), "html", null, true);
            yield "\">
\t\t\t\t<td colspan=4 class=\"white\"><b>Characters</b></td>
\t\t\t</tr>
\t\t\t<tr bgcolor=\"";
            // line 387
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 387), "html", null, true);
            yield "\">
\t\t\t\t<td width=\"62%\"><B>Name</b></td>
\t\t\t\t<td width=\"30%\"><B>Level</b></td>
\t\t\t\t<td width=\"8%\"><b>Status</b></td>
\t\t\t\t<td><b>&#160;</b></td>
\t\t\t</tr>
\t\t\t";
            // line 393
            $context["i"] = 0;
            // line 394
            yield "\t\t\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["account_players"] ?? null));
            $context['loop'] = [
              'parent' => $context['_parent'],
              'index0' => 0,
              'index'  => 1,
              'first'  => true,
            ];
            if (is_array($context['_seq']) || (is_object($context['_seq']) && $context['_seq'] instanceof \Countable)) {
                $length = count($context['_seq']);
                $context['loop']['revindex0'] = $length - 1;
                $context['loop']['revindex'] = $length;
                $context['loop']['length'] = $length;
                $context['loop']['last'] = 1 === $length;
            }
            foreach ($context['_seq'] as $context["_key"] => $context["player"]) {
                // line 395
                yield "\t\t\t\t";
                if (( !CoreExtension::getAttribute($this->env, $this->source, $context["player"], "isHidden", [], "method", false, false, false, 395) && ((($_v10 = $this->env->getFunction('config')->getCallable()("characters")) && is_array($_v10) || $_v10 instanceof ArrayAccess ? ($_v10["deleted"] ?? null) : null) ||  !CoreExtension::getAttribute($this->env, $this->source, $context["player"], "isDeleted", [], "method", false, false, false, 395)))) {
                    // line 396
                    yield "\t\t\t\t";
                    $context["i"] = (($context["i"] ?? null) + 1);
                    // line 397
                    yield "\t\t\t<tr bgcolor=\"";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
                    yield "\">
\t\t\t\t<td>
\t\t\t\t\t<nobr>";
                    // line 399
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
                    yield ".&#160;";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getName", [], "method", false, false, false, 399), "html", null, true);
                    if (CoreExtension::getAttribute($this->env, $this->source, $context["player"], "isDeleted", [], "method", false, false, false, 399)) {
                        yield "<span style=\"color: red\"> [DELETED]</span>";
                    }
                    yield "</nobr>
\t\t\t\t</td>

\t\t\t\t<td>";
                    // line 402
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getLevel", [], "method", false, false, false, 402), "html", null, true);
                    yield " ";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getVocationName", [], "method", false, false, false, 402), "html", null, true);
                    yield "</td>
\t\t\t\t<td>";
                    // line 403
                    if (CoreExtension::getAttribute($this->env, $this->source, $context["player"], "isOnline", [], "method", false, false, false, 403)) {
                        yield "<b><span style=\"color: green\">Online</span></b>";
                    }
                    yield "</td>
\t\t\t\t<td>
\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
\t\t\t\t\t\t<form action=\"";
                    // line 406
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("characters"), "html", null, true);
                    yield "\" method=\"post\">
\t\t\t\t\t\t\t";
                    // line 407
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
                    yield "
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"name\" value=\"";
                    // line 410
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getName", [], "method", false, false, false, 410), "html", null, true);
                    yield "\"/>
\t\t\t\t\t\t\t\t\t";
                    // line 411
                    $context["button_name"] = "View";
                    // line 412
                    yield "\t\t\t\t\t\t\t\t\t";
                    yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.base.html.twig");
                    yield "
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</form>
\t\t\t\t\t</table>
\t\t\t\t</td>
\t\t\t</tr>
\t\t\t\t";
                }
                // line 420
                yield "\t\t\t";
                ++$context['loop']['index0'];
                ++$context['loop']['index'];
                $context['loop']['first'] = false;
                if (isset($context['loop']['revindex0'], $context['loop']['revindex'])) {
                    --$context['loop']['revindex0'];
                    --$context['loop']['revindex'];
                    $context['loop']['last'] = 0 === $context['loop']['revindex0'];
                }
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['player'], $context['_parent'], $context['loop']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 421
            yield "\t\t</table>
\t\t<!-- CHARACTERS_LIST_END -->
\t\t";
        }
        // line 424
        yield "\t\t";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, Twig\Extension\CoreExtension::constant("HOOK_CHARACTERS_AFTER_CHARACTERS")), "html", null, true);
        yield "
\t\t";
        // line 425
        if (($context["canEdit"] ?? null)) {
            // line 426
            yield "\t\t\t<a href=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
            yield "?p=players&id=";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getId", [], "method", false, false, false, 426), "html", null, true);
            yield "\" title=\"Edit in Admin Panel\" target=\"_blank\">
\t\t\t\t<img src=\"images/edit.png\"/>Edit
\t\t\t</a>
\t\t";
        }
        // line 430
        yield "\t\t</td>
\t\t<td>
\t\t\t<img src=\"";
        // line 432
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/general/blank.gif\" width=\"10\" height=\"1\" border=\"0\">
\t\t</td>
\t</tr>
</table>
<br/><br/>";
        // line 436
        yield ($context["search_form"] ?? null);
        yield "
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "characters.html.twig";
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
        return array (  1107 => 436,  1100 => 432,  1096 => 430,  1086 => 426,  1084 => 425,  1079 => 424,  1074 => 421,  1060 => 420,  1048 => 412,  1046 => 411,  1042 => 410,  1036 => 407,  1032 => 406,  1024 => 403,  1018 => 402,  1007 => 399,  1001 => 397,  998 => 396,  995 => 395,  977 => 394,  975 => 393,  966 => 387,  960 => 384,  953 => 380,  947 => 376,  941 => 374,  930 => 372,  928 => 371,  924 => 370,  918 => 368,  916 => 367,  913 => 366,  907 => 363,  901 => 361,  898 => 360,  895 => 359,  893 => 358,  890 => 357,  884 => 354,  878 => 352,  875 => 351,  872 => 350,  870 => 349,  867 => 348,  861 => 345,  855 => 343,  852 => 342,  849 => 341,  847 => 340,  840 => 336,  835 => 333,  832 => 332,  830 => 331,  825 => 330,  815 => 323,  806 => 319,  797 => 315,  785 => 308,  781 => 307,  777 => 306,  758 => 289,  756 => 288,  751 => 286,  748 => 285,  743 => 282,  737 => 281,  735 => 280,  724 => 278,  720 => 277,  715 => 276,  710 => 275,  708 => 274,  702 => 271,  697 => 268,  694 => 267,  689 => 264,  683 => 263,  681 => 262,  675 => 259,  671 => 258,  666 => 257,  661 => 256,  659 => 255,  653 => 252,  648 => 249,  646 => 248,  641 => 246,  634 => 242,  631 => 241,  613 => 230,  599 => 225,  587 => 220,  579 => 219,  570 => 213,  564 => 210,  559 => 207,  557 => 206,  552 => 204,  549 => 203,  543 => 199,  530 => 196,  526 => 195,  521 => 194,  518 => 193,  513 => 192,  511 => 191,  505 => 188,  500 => 185,  498 => 184,  493 => 182,  490 => 181,  484 => 177,  475 => 174,  471 => 173,  466 => 172,  463 => 171,  458 => 170,  456 => 169,  450 => 166,  445 => 163,  443 => 162,  438 => 160,  431 => 156,  421 => 153,  415 => 151,  413 => 150,  410 => 149,  404 => 146,  398 => 144,  395 => 143,  393 => 142,  390 => 141,  384 => 138,  378 => 136,  375 => 135,  373 => 134,  362 => 131,  356 => 129,  354 => 128,  351 => 127,  343 => 124,  337 => 122,  334 => 121,  332 => 120,  329 => 119,  318 => 111,  314 => 110,  310 => 109,  304 => 106,  295 => 101,  292 => 100,  290 => 99,  287 => 98,  281 => 95,  275 => 93,  272 => 92,  270 => 91,  264 => 88,  258 => 86,  256 => 85,  253 => 84,  247 => 81,  241 => 79,  238 => 78,  236 => 77,  233 => 76,  227 => 73,  221 => 71,  218 => 70,  216 => 69,  213 => 68,  207 => 65,  201 => 63,  198 => 62,  196 => 61,  193 => 60,  187 => 57,  181 => 55,  178 => 54,  176 => 53,  170 => 50,  164 => 48,  162 => 47,  159 => 46,  153 => 43,  147 => 41,  144 => 40,  142 => 39,  136 => 36,  130 => 34,  128 => 33,  112 => 30,  106 => 28,  104 => 27,  97 => 23,  94 => 22,  82 => 20,  80 => 19,  77 => 18,  67 => 14,  65 => 13,  61 => 12,  56 => 10,  53 => 9,  51 => 8,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "characters.html.twig", "/var/www/html/system/templates/characters.html.twig");
    }
}
