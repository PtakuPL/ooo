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

/* menu.js.html.twig */
class __TwigTemplate_f50e7bd1381b7a2657d1252249a0ac7a extends Template
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
        yield "var list = new Array();
";
        // line 2
        $context["i"] = 0;
        // line 3
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable($this->env->getFunction('config')->getCallable()("menu_categories"));
        foreach ($context['_seq'] as $context["id"] => $context["cat"]) {
            // line 4
            yield "\t";
            if ((((CoreExtension::getAttribute($this->env, $this->source, $context["cat"], "id", [], "any", false, false, false, 4) != "shops") || $this->env->getFunction('setting')->getCallable()("core.gifts_system")) && (Twig\Extension\CoreExtension::length($this->env->getCharset(), (($_v0 = ($context["menus"] ?? null)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0[$context["id"]] ?? null) : null)) > 0))) {
                // line 5
                yield "\t\tlist[";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
                yield "] = '";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["cat"], "id", [], "any", false, false, false, 5), "html", null, true);
                yield "';
\t\t";
                // line 6
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 7
                yield "\t";
            }
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['id'], $context['cat'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 9
        yield "
function initMenu()
{
\tvar length = list.length;
\tfor(i = 0; i < length; i++)
\t{
\t\tif(list[i] == category)
\t\t{
\t\t\tdocument.getElementById(list[i]).className = 'tab-active';
\t\t\tdocument.getElementById(list[i] + \"-submenu\").style.display = 'block';
\t\t}
\t\telse
\t\t{
\t\t\tdocument.getElementById(list[i]).className = 'tab';
\t\t\tdocument.getElementById(list[i] + \"-submenu\").style.display = 'none';
\t\t}
\t}
}

function menuSwitch(cat)
{
\tcategory = cat;
\tinitMenu();
}
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "menu.js.html.twig";
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
        return array (  70 => 9,  63 => 7,  61 => 6,  54 => 5,  51 => 4,  47 => 3,  45 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "menu.js.html.twig", "/var/www/html/templates/kathrine/menu.js.html.twig");
    }
}
