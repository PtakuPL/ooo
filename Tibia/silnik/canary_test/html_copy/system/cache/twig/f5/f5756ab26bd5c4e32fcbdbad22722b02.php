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

/* forum.remove_post.html.twig */
class __TwigTemplate_3ff99e39661a5db1edc46f96e33966ab extends Template
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
        yield "<form action=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("forum"), "html", null, true);
        yield "\" method=\"post\" style=\"display: inline\"
\t";
        // line 2
        if ((CoreExtension::getAttribute($this->env, $this->source, ($context["post"] ?? null), "first_post", [], "any", false, false, false, 2) != CoreExtension::getAttribute($this->env, $this->source, ($context["post"] ?? null), "id", [], "any", false, false, false, 2))) {
            // line 3
            yield "\t\tonclick=\"return confirm('Are you sure you want remove post of ";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, CoreExtension::getAttribute($this->env, $this->source, ($context["post"] ?? null), "player", [], "any", false, false, false, 3), "getName", [], "method", false, false, false, 3), "html", null, true);
            yield "?')\"
\t";
        } else {
            // line 5
            yield "\t\tonclick=\"return confirm('Are you sure you want remove thread > ";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["post"] ?? null), "post_topic", [], "any", false, false, false, 5), "html", null, true);
            yield " <?')\"
\t";
        }
        // line 7
        yield ">
\t";
        // line 8
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t<input type=\"hidden\" name=\"action\" value=\"remove_post\" />
\t<input type=\"hidden\" name=\"id\" value=\"";
        // line 10
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["post"] ?? null), "id", [], "any", false, false, false, 10), "html", null, true);
        yield "\" />
\t<input type=\"image\" src=\"/images/del.png\" border=\"0\" alt=\"Delete\" title=\"";
        // line 11
        if ((CoreExtension::getAttribute($this->env, $this->source, ($context["post"] ?? null), "first_post", [], "any", false, false, false, 11) != CoreExtension::getAttribute($this->env, $this->source, ($context["post"] ?? null), "id", [], "any", false, false, false, 11))) {
            yield "Remove Post";
        } else {
            yield "Remove Thread";
        }
        yield "\" />
</form>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "forum.remove_post.html.twig";
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
        return array (  73 => 11,  69 => 10,  64 => 8,  61 => 7,  55 => 5,  49 => 3,  47 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "forum.remove_post.html.twig", "/var/www/html/system/templates/forum.remove_post.html.twig");
    }
}
