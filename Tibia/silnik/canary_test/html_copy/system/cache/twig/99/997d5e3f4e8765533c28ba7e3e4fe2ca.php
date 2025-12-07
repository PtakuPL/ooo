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

/* forum.show_thread.html.twig */
class __TwigTemplate_a4e4cab12622f8cd6b179e166dc411fb extends Template
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
        yield "<a href=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
        yield "\">Boards</a> >> <a href=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()(("forum/board/" . CoreExtension::getAttribute($this->env, $this->source, ($context["section"] ?? null), "id", [], "any", false, false, false, 1))), "html", null, true);
        yield "\">";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["section"] ?? null), "name", [], "any", false, false, false, 1), "html", null, true);
        yield "</a> >> <b>";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["thread_starter"] ?? null), "post_topic", [], "any", false, false, false, 1), "html", null, true);
        yield "</b>
<br/><br/>
<a href=\"";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
        yield "?action=new_post&thread_id=";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["thread_id"] ?? null), "html", null, true);
        yield "\"><img src=\"images/forum/post.gif\" border=\"0\" /></a><br/>
<br/>
Page: ";
        // line 5
        yield ($context["links_to_pages"] ?? null);
        yield "<br/>
<table width=\"100%\">
\t<tr bgcolor=\"";
        // line 7
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 7), "html", null, true);
        yield "\" width=\"100%\">
\t\t<td colspan=\"2\">
\t\t\t<span style=\"font-size: 18px\"><b>";
        // line 9
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["thread_starter"] ?? null), "post_topic", [], "any", false, false, false, 9), "html", null, true);
        yield "</b></span>
\t\t\t<span style=\"font-size: 10px\"><br/>
\t\t\tby ";
        // line 11
        yield ($context["author_link"] ?? null);
        yield "</span>
\t\t</td>
\t</tr>
\t<tr bgcolor=\"";
        // line 14
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 14), "html", null, true);
        yield "\">
\t\t<td width=\"200\" class=\"white\">
\t\t\t<span style=\"font-size: 10px\"><b>Author</b></span>
\t\t</td>
\t\t<td>&nbsp;</td>
\t</tr>

\t";
        // line 21
        $context["i"] = 0;
        // line 22
        yield "\t";
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["posts"] ?? null));
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
        foreach ($context['_seq'] as $context["_key"] => $context["post"]) {
            // line 23
            yield "\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
            yield "\">
\t\t";
            // line 24
            $context["i"] = (($context["i"] ?? null) + 1);
            // line 25
            yield "\t\t<td valign=\"top\">";
            yield CoreExtension::getAttribute($this->env, $this->source, $context["post"], "player_link", [], "any", false, false, false, 25);
            yield "<br/>
\t\t\t";
            // line 26
            if (CoreExtension::getAttribute($this->env, $this->source, $context["post"], "outfit", [], "any", true, true, false, 26)) {
                // line 27
                yield "\t\t\t<img style=\"margin-left:";
                if (CoreExtension::inFilter(CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, $context["post"], "player", [], "any", false, false, false, 27), "getLookType", [], "method", false, false, false, 27), $this->env->getFunction('setting')->getCallable()("core.outfit_images_wrong_looktypes"))) {
                    yield "-0px;margin-top:-0px;width:64px;height:64px;";
                } else {
                    yield "-60px;margin-top:-60px;width:128px;height:128px;";
                }
                yield "\" src=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "outfit", [], "any", false, false, false, 27), "html", null, true);
                yield "\" alt=\"player outfit\"/>
\t\t\t<br />
\t\t\t";
            }
            // line 30
            yield "\t\t\t<span style=\"font-size: 10px\">
\t\t\t\t";
            // line 31
            if (CoreExtension::getAttribute($this->env, $this->source, $context["post"], "group", [], "any", true, true, false, 31)) {
                // line 32
                yield "\t\t\t\t\tPosition: ";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "group", [], "any", false, false, false, 32), "html", null, true);
                yield "<br />
\t\t\t\t";
            }
            // line 34
            yield "
\t\t\t\tProfession: ";
            // line 35
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "vocation", [], "any", false, false, false, 35), "html", null, true);
            yield "<br />
\t\t\t\tLevel: ";
            // line 36
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, $context["post"], "player", [], "any", false, false, false, 36), "getLevel", [], "method", false, false, false, 36), "html", null, true);
            yield " <br />
\t\t\t\t";
            // line 37
            if (CoreExtension::getAttribute($this->env, $this->source, $context["post"], "guildRank", [], "any", true, true, false, 37)) {
                // line 38
                yield "\t\t\t\t\t";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["guildRank"] ?? null), "html", null, true);
                yield "<br />
\t\t\t\t";
            }
            // line 40
            yield "\t\t\t\t<br />Posts: ";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "author_posts_count", [], "any", false, false, false, 40), "html", null, true);
            yield "<br />
\t\t\t</span>
\t\t</td>
\t\t<td valign=\"top\" style=\"word-break: break-all\">";
            // line 43
            yield CoreExtension::getAttribute($this->env, $this->source, $context["post"], "content", [], "any", false, false, false, 43);
            yield " </td></tr>
\t\t<tr bgcolor=\"";
            // line 44
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
            yield "\">
\t\t\t<td>
\t\t\t\t<span style=\"font-size: 10px\">";
            // line 46
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "date", [], "any", false, false, false, 46), "d.m.y H:i:s"), "html", null, true);
            yield "
\t\t\t\t\t";
            // line 47
            if (CoreExtension::getAttribute($this->env, $this->source, $context["post"], "edited_by", [], "any", true, true, false, 47)) {
                // line 48
                yield "\t\t\t\t\t<br />Edited by ";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "edited_by", [], "any", false, false, false, 48), "html", null, true);
                yield "
\t\t\t\t\t<br />on ";
                // line 49
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "edit_date", [], "any", false, false, false, 49), "d.m.y H:i:s"), "html", null, true);
                yield "
\t\t\t\t\t";
            }
            // line 51
            yield "\t\t\t\t</span>
\t\t\t</td>
\t\t\t<td>
\t\t\t\t";
            // line 54
            if (($context["is_moderator"] ?? null)) {
                // line 55
                yield "\t\t\t\t\t";
                if ((CoreExtension::getAttribute($this->env, $this->source, $context["post"], "first_post", [], "any", false, false, false, 55) != CoreExtension::getAttribute($this->env, $this->source, $context["post"], "id", [], "any", false, false, false, 55))) {
                    // line 56
                    yield "\t\t\t\t\t\t";
                    yield Twig\Extension\CoreExtension::include($this->env, $context, "forum.remove_post.html.twig");
                    yield "
\t\t\t\t\t";
                } else {
                    // line 58
                    yield "\t\t\t\t\t\t<a href=\"";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
                    yield "?action=move_thread&id=";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "id", [], "any", false, false, false, 58), "html", null, true);
                    yield "\" title=\"Move Thread\"><img src=\"images/icons/arrow_right.gif\"/></a>
\t\t\t\t\t\t";
                    // line 59
                    yield Twig\Extension\CoreExtension::include($this->env, $context, "forum.remove_post.html.twig");
                    yield "
\t\t\t\t\t";
                }
                // line 61
                yield "\t\t\t\t";
            }
            // line 62
            yield "\t\t\t\t\t";
            if ((($context["logged"] ?? null) && ((CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, $context["post"], "player", [], "any", false, false, false, 62), "getAccount", [], "method", false, false, false, 62), "getId", [], "method", false, false, false, 62) == CoreExtension::getAttribute($this->env, $this->source, ($context["account_logged"] ?? null), "getId", [], "method", false, false, false, 62)) || ($context["is_moderator"] ?? null)))) {
                // line 63
                yield "\t\t\t\t\t\t<a href=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
                yield "?action=edit_post&id=";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "id", [], "any", false, false, false, 63), "html", null, true);
                yield "\" title=\"Edit Post\" target=\"_blank\">
\t\t\t\t\t\t\t<img src=\"images/edit.png\"/>
\t\t\t\t\t\t</a>
\t\t\t\t\t";
            }
            // line 67
            yield "\t\t\t\t\t";
            if (($context["logged"] ?? null)) {
                // line 68
                yield "\t\t\t\t\t\t<a href=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
                yield "?action=new_post&thread_id=";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["thread_id"] ?? null), "html", null, true);
                yield "&quote=";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["post"], "id", [], "any", false, false, false, 68), "html", null, true);
                yield "\" title=\"Quote Post\"><img src=\"images/icons/comment_add.png\"/></a>
\t\t\t\t\t";
            }
            // line 70
            yield "\t\t\t</td>
\t\t</tr>
\t\t";
            // line 72
            $context["i"] = (($context["i"] ?? null) + 1);
            // line 73
            yield "\t";
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
        unset($context['_seq'], $context['_key'], $context['post'], $context['_parent'], $context['loop']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 74
        yield "</table>
<br/>
<a href=\"";
        // line 76
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
        yield "?action=new_post&thread_id=";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["thread_id"] ?? null), "html", null, true);
        yield "\"><img src=\"images/forum/post.gif\" border=\"0\" /></a>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "forum.show_thread.html.twig";
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
        return array (  282 => 76,  278 => 74,  264 => 73,  262 => 72,  258 => 70,  248 => 68,  245 => 67,  235 => 63,  232 => 62,  229 => 61,  224 => 59,  217 => 58,  211 => 56,  208 => 55,  206 => 54,  201 => 51,  196 => 49,  191 => 48,  189 => 47,  185 => 46,  180 => 44,  176 => 43,  169 => 40,  163 => 38,  161 => 37,  157 => 36,  153 => 35,  150 => 34,  144 => 32,  142 => 31,  139 => 30,  126 => 27,  124 => 26,  119 => 25,  117 => 24,  112 => 23,  94 => 22,  92 => 21,  82 => 14,  76 => 11,  71 => 9,  66 => 7,  61 => 5,  54 => 3,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "forum.show_thread.html.twig", "/var/www/html/system/templates/forum.show_thread.html.twig");
    }
}
