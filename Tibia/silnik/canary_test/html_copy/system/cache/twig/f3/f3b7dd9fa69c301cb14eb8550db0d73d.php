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

/* forum.new_thread.html.twig */
class __TwigTemplate_84e3babce17489bba84a3366316d477b extends Template
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
        yield "<form method=\"post\">
\t";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t<input type=\"hidden\" name=\"action\" value=\"new_thread\" />
\t<input type=\"hidden\" name=\"section_id\" value=\"";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["section_id"] ?? null), "html", null, true);
        yield "\" />
\t<input type=\"hidden\" name=\"subtopic\" value=\"forum\" />
\t<input type=\"hidden\" name=\"save\" value=\"save\" />
\t<table width=\"100%\">
\t\t<tr bgcolor=\"";
        // line 8
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 8), "html", null, true);
        yield "\">
\t\t\t<td colspan=\"2\">
\t\t\t\t<span style=\"color: white\"><b>Post New Reply</b></span>
\t\t\t</td>
\t\t</tr>
\t\t<tr bgcolor=\"";
        // line 13
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 13), "html", null, true);
        yield "\">
\t\t\t<td width=\"180\"><b>Character:</b></td>
\t\t\t<td>
\t\t\t\t<select name=\"char_id\"><option value=\"0\">(Choose character)</option>
\t\t\t\t\t";
        // line 17
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["players"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["player"]) {
            // line 18
            yield "\t\t\t\t\t<option value=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "id", [], "any", false, false, false, 18), "html", null, true);
            yield "\"";
            if ((CoreExtension::getAttribute($this->env, $this->source, $context["player"], "id", [], "any", false, false, false, 18) == ($context["post_player_id"] ?? null))) {
                yield " selected=\"selected\"";
            }
            yield ">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "name", [], "any", false, false, false, 18), "html", null, true);
            yield "</option>
\t\t\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['player'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 20
        yield "\t\t\t\t</select>
\t\t\t</td>
\t\t</tr>
\t\t<tr bgcolor=\"";
        // line 23
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 23), "html", null, true);
        yield "\">
\t\t\t<td><b>Topic:</b></td>
\t\t\t<td><input type=\"text\" name=\"topic\" value=\"";
        // line 25
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["post_thread"] ?? null));
        yield "\" size=\"40\" maxlength=\"60\" /> (Optional)</td>
\t\t</tr>
\t\t<tr bgcolor=\"";
        // line 27
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 27), "html", null, true);
        yield "\">
\t\t\t<td valign=\"top\"><b>Message:</b><span style=\"font-size: 10px\"><br />You can use:<br />[player]Nick[/player]<br />[url]http://address.com/[/url]<br />[img]http://images.com/images3.gif[/img]<br />[code]Code[/code]<br />[b]<b>Text</b>[/b]<br />[i]<i>Text</i>[/i]<br />[u]<u>Text</u>[/u]<br />and smileys:<br />;) , :) , :D , :( , :rolleyes:<br />:cool: , :eek: , :o , :p</span></td>
\t\t\t<td><textarea rows=\"10\" cols=\"60\" name=\"text\">";
        // line 29
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["post_text"] ?? null));
        yield "</textarea><br />(Max. 15,000 letters)</td>
\t\t</tr>
\t\t<tr bgcolor=\"";
        // line 31
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 31), "html", null, true);
        yield "\">
\t\t\t<td valign=\"top\">Options:</td>
\t\t\t<td>
\t\t\t\t<label>
\t\t\t\t\t<input type=\"checkbox\" name=\"smile\" value=\"1\"";
        // line 35
        if (($context["post_smile"] ?? null)) {
            yield " checked=\"checked\"";
        }
        yield "/>Disable Smileys in This Post
\t\t\t\t</label>
\t\t\t\t";
        // line 37
        if (($context["canEdit"] ?? null)) {
            // line 38
            yield "\t\t\t\t<br/>
\t\t\t\t<label>
\t\t\t\t\t<input type=\"checkbox\" name=\"html\" value=\"1\"";
            // line 40
            if (($context["post_html"] ?? null)) {
                yield " checked=\"checked\"";
            }
            yield "/>Enable HTML in this post (moderator only)
\t\t\t\t</label>
\t\t\t";
        }
        // line 43
        yield "\t\t\t</td>
\t\t</tr>
\t</table>
\t<div style=\"text-align:center\">
\t\t<input type=\"submit\" value=\"Post Thread\" />
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
        return "forum.new_thread.html.twig";
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
        return array (  144 => 43,  136 => 40,  132 => 38,  130 => 37,  123 => 35,  116 => 31,  111 => 29,  106 => 27,  101 => 25,  96 => 23,  91 => 20,  76 => 18,  72 => 17,  65 => 13,  57 => 8,  50 => 4,  45 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "forum.new_thread.html.twig", "/var/www/html/system/templates/forum.new_thread.html.twig");
    }
}
