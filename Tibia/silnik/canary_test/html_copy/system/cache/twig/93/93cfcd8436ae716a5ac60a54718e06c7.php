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

/* characters.form.html.twig */
class __TwigTemplate_32e9f15ec85fda590c06b2ab7228b47a extends Template
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
        yield "<br/>
<form action=\"";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("characters"), "html", null, true);
        yield "\" method=\"post\">
\t";
        // line 3
        $context["title"] = "Search Character";
        // line 4
        yield "\t";
        $context["tableClass"] = "Table1";
        // line 5
        yield "\t";
        $context["background"] = $this->env->getFunction('config')->getCallable()("darkborder");
        // line 6
        yield "\t";
        $context["content"] = ('' === $tmp = \Twig\Extension\CoreExtension::captureOutput((function () use (&$context, $macros, $blocks) {
            // line 7
            yield "\t\t<table width=\"100%\">
\t\t\t<tr>
\t\t\t\t<td style=\"vertical-align:middle\" class=\"LabelV150\">
\t\t\t\t\tCharacter Name:
\t\t\t\t</td>
\t\t\t\t<td style=\"width:170px\">
\t\t\t\t\t<input style=\"width:165px\" name=\"name\" value=\"\" size=\"29\" maxlength=\"29\"/>
\t\t\t\t</td>
\t\t\t\t<td>
\t\t\t\t\t";
            // line 16
            $context["button_name"] = "Submit";
            // line 17
            yield "\t\t\t\t\t";
            yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.base.html.twig");
            yield "
\t\t\t\t</td>
\t\t\t</tr>
\t\t</table>
\t";
            yield from [];
        })())) ? '' : new Markup($tmp, $this->env->getCharset());
        // line 22
        yield "\t";
        yield Twig\Extension\CoreExtension::include($this->env, $context, "tables.headline.html.twig");
        yield "
</form>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "characters.form.html.twig";
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
        return array (  83 => 22,  73 => 17,  71 => 16,  60 => 7,  57 => 6,  54 => 5,  51 => 4,  49 => 3,  45 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "characters.form.html.twig", "/var/www/html/system/templates/characters.form.html.twig");
    }
}
