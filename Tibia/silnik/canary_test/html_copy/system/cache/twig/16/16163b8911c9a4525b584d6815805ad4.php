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

/* forum.boards.html.twig */
class __TwigTemplate_f3d7e78a892762d45ceb69aa0f0fccfe extends Template
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
        yield "<b>Boards</b>
<table width=\"100%\">
\t<thead>
\t<tr bgcolor=\"";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 4), "html", null, true);
        yield "\" class=\"white\">
\t\t<th>
\t\t\t<span style=\"font-size: 10px\"><b>Board</b></span>
\t\t</th>
\t\t<th>
\t\t\t<span style=\"font-size: 10px\"><b>Posts</b></span>
\t\t</th>
\t\t<th>
\t\t\t<span style=\"font-size: 10px\"><b>Threads</b></span>
\t\t</th>
\t\t<th align=\"center\">
\t\t\t<span style=\"font-size: 10px\"><b>Last Post</b></span>
\t\t</th>
\t\t";
        // line 17
        if (($context["canEdit"] ?? null)) {
            // line 18
            yield "\t\t\t<th>
\t\t\t\t<span style=\"font-size: 10px\"><b>Options</b></span>
\t\t\t</th>
\t\t";
        }
        // line 22
        yield "\t</tr>
\t</thead>
\t";
        // line 24
        $context["i"] = 0;
        // line 25
        yield "\t";
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["boards"] ?? null));
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
        foreach ($context['_seq'] as $context["_key"] => $context["board"]) {
            // line 26
            yield "\t";
            $context["i"] = (($context["i"] ?? null) + 1);
            // line 27
            yield "\t<tr bgcolor=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
            yield "\">
\t\t<td>
\t\t\t<a href=\"";
            // line 29
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["board"], "link", [], "any", false, false, false, 29), "html", null, true);
            yield "\">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["board"], "name", [], "any", false, false, false, 29), "html", null, true);
            yield "</a><br /><small>";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["board"], "description", [], "any", false, false, false, 29), "html", null, true);
            yield "</small>
\t\t</td>
\t\t<td>";
            // line 31
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["board"], "posts", [], "any", false, false, false, 31), "html", null, true);
            yield "</td>
\t\t<td>";
            // line 32
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["board"], "threads", [], "any", false, false, false, 32), "html", null, true);
            yield "</td>
\t\t<td>
\t\t";
            // line 34
            if ( !(null === CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, $context["board"], "last_post", [], "any", false, false, false, 34), "name", [], "any", false, false, false, 34))) {
                // line 35
                yield "\t\t";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, $context["board"], "last_post", [], "any", false, false, false, 35), "date", [], "any", false, false, false, 35), "d.m.y H:i:s"), "html", null, true);
                yield "<br/>by ";
                yield CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, $context["board"], "last_post", [], "any", false, false, false, 35), "player_link", [], "any", false, false, false, 35);
                yield "
\t\t";
            } else {
                // line 37
                yield "\t\tNo posts
\t\t";
            }
            // line 39
            yield "\t\t</td>
\t\t";
            // line 40
            if (($context["canEdit"] ?? null)) {
                // line 41
                yield "\t\t\t<td>
\t\t\t\t";
                // line 42
                yield Twig\Extension\CoreExtension::include($this->env, $context, "forum.admin.links.html.twig", ["id" => CoreExtension::getAttribute($this->env, $this->source, $context["board"], "id", [], "any", false, false, false, 42), "hide" => CoreExtension::getAttribute($this->env, $this->source, $context["board"], "hide", [], "any", false, false, false, 42), "i" => ($context["i"] ?? null)]);
                yield "
\t\t\t</td>
\t\t";
            }
            // line 45
            yield "\t</tr>
\t";
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
        unset($context['_seq'], $context['_key'], $context['board'], $context['_parent'], $context['loop']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 47
        yield "</table>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "forum.boards.html.twig";
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
        return array (  165 => 47,  150 => 45,  144 => 42,  141 => 41,  139 => 40,  136 => 39,  132 => 37,  124 => 35,  122 => 34,  117 => 32,  113 => 31,  104 => 29,  98 => 27,  95 => 26,  77 => 25,  75 => 24,  71 => 22,  65 => 18,  63 => 17,  47 => 4,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "forum.boards.html.twig", "/var/www/html/system/templates/forum.boards.html.twig");
    }
}
