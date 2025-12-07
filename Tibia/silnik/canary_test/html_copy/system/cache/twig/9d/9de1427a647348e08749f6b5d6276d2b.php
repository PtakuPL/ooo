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

/* forum.add_board.html.twig */
class __TwigTemplate_5ec97747a39547503e7408c466cbdb52 extends Template
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
        yield "<form method=\"post\" action=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["link"] ?? null), "html", null, true);
        yield "\">
\t";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t";
        // line 3
        if ((($context["action"] ?? null) == "edit_board")) {
            // line 4
            yield "\t<input type=\"hidden\" name=\"id\" value=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["id"] ?? null), "html", null, true);
            yield "\" />
\t";
        }
        // line 6
        yield "\t<table width=\"100%\" border=\"0\" cellspacing=\"1\" cellpadding=\"4\">
\t\t<tr>
\t\t\t<td bgcolor=\"";
        // line 8
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vdarkborder", [], "any", false, false, false, 8), "html", null, true);
        yield "\" class=\"white\"><b>";
        if ((($context["action"] ?? null) == "edit")) {
            yield "Edit";
        } else {
            yield "Add";
        }
        yield " board</b></td>
\t\t</tr>
\t\t<tr>
\t\t\t<td bgcolor=\"";
        // line 11
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 11), "html", null, true);
        yield "\">
\t\t\t\t<table border=\"0\" cellpadding=\"1\">
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td>Name:</td>
\t\t\t\t\t\t<td><input name=\"name\" value=\"";
        // line 15
        if ( !(null === ($context["name"] ?? null))) {
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["name"] ?? null), "html", null, true);
        }
        yield "\" size=\"29\" maxlength=\"29\"/></td>
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td>Description:</td>
\t\t\t\t\t\t<td><textarea name=\"description\" maxlength=\"300\" cols=\"50\" rows=\"5\">";
        // line 18
        if ( !(null === ($context["description"] ?? null))) {
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["description"] ?? null), "html", null, true);
        }
        yield "</textarea></td>
\t\t\t\t\t<tr/>
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td>Access:</td>
\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t<select name=\"access\">
\t\t\t\t\t\t\t\t";
        // line 24
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["groups"] ?? null));
        foreach ($context['_seq'] as $context["id"] => $context["group"]) {
            // line 25
            yield "\t\t\t\t\t\t\t\t\t<option value=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["group"], "id", [], "any", false, false, false, 25), "html", null, true);
            yield "\"";
            if ((($context["access"] ?? null) == CoreExtension::getAttribute($this->env, $this->source, $context["group"], "id", [], "any", false, false, false, 25))) {
                yield " selected";
            }
            yield ">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["group"], "name", [], "any", false, false, false, 25), "html", null, true);
            yield "</option>
\t\t\t\t\t\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['id'], $context['group'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 27
        yield "\t\t\t\t\t\t\t</select>
\t\t\t\t\t\t</td>
\t\t\t\t\t</tr>
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td>Guild:</td>
\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t<select name=\"guild\">
\t\t\t\t\t\t\t\t<option value=\"0\"";
        // line 34
        if ((($context["guild"] ?? null) == 0)) {
            yield " selected";
        }
        yield ">----</option>
\t\t\t\t\t\t\t\t";
        // line 35
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["guilds"] ?? null));
        foreach ($context['_seq'] as $context["_key"] => $context["guild_"]) {
            // line 36
            yield "\t\t\t\t\t\t\t\t\t<option value=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["guild_"], "id", [], "any", false, false, false, 36), "html", null, true);
            yield "\"";
            if ((($context["guild"] ?? null) == CoreExtension::getAttribute($this->env, $this->source, $context["guild_"], "id", [], "any", false, false, false, 36))) {
                yield " selected";
            }
            yield ">";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["guild_"], "name", [], "any", false, false, false, 36), "html", null, true);
            yield "</option>
\t\t\t\t\t\t\t\t";
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['_key'], $context['guild_'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 38
        yield "\t\t\t\t\t\t\t</select>
\t\t\t\t\t\t</td>
\t\t\t\t\t</tr>
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td colspan=\"2\" align=\"center\">
\t\t\t\t\t\t\t";
        // line 43
        yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.submit.html.twig");
        yield "
\t\t\t\t\t\t</td>
\t\t\t\t\t</tr>
\t\t\t\t</table>
\t\t\t</td>
\t\t</tr>
\t</table>
</form>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "forum.add_board.html.twig";
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
        return array (  161 => 43,  154 => 38,  139 => 36,  135 => 35,  129 => 34,  120 => 27,  105 => 25,  101 => 24,  90 => 18,  82 => 15,  75 => 11,  63 => 8,  59 => 6,  53 => 4,  51 => 3,  47 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "forum.add_board.html.twig", "/var/www/html/system/templates/forum.add_board.html.twig");
    }
}
