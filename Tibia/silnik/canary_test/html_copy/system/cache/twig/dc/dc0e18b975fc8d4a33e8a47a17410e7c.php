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

/* templates.header.html.twig */
class __TwigTemplate_9e3f112776785f7ed22e41f999c04a04 extends Template
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
        yield "<meta charset=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["charset"] ?? null), "html", null, true);
        yield "\">
<meta http-equiv=\"content-language\" content=\"";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "language", [], "any", false, false, false, 2), "html", null, true);
        yield "\" />
<meta http-equiv=\"content-type\" content=\"text/html; charset=";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["charset"] ?? null), "html", null, true);
        yield "\" />
<!-- CSRF Token -->
<meta name=\"csrf-token\" content=\"";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrfToken')->getCallable()(), "html", null, true);
        yield "\">
";
        // line 6
        if ( !($context["is_admin"] ?? null)) {
            // line 7
            yield "<base href=\"";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
            yield "\" />
<title>";
            // line 8
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["title"] ?? null), "html", null, true);
            yield "</title>
";
        }
        // line 10
        yield "<meta name=\"description\" content=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('setting')->getCallable()("core.meta_description"), "html", null, true);
        yield "\" />
<meta name=\"keywords\" content=\"";
        // line 11
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('setting')->getCallable()("core.meta_keywords"), "html", null, true);
        yield ", myaac, wodzaac\" />
<meta name=\"generator\" content=\"MyAAC\" />
<link rel=\"stylesheet\" type=\"text/css\" href=\"";
        // line 13
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "tools/css/messages.css\" />
<script type=\"text/javascript\" src=\"";
        // line 14
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "tools/ext/jquery/jquery.min.js\"></script>
<noscript>
\t<div class=\"warning\" style=\"text-align: center; font-size: 14px;\">
\t\tYour browser does not support JavaScript or its disabled!<br/>
\t\tPlease turn it on, or be aware that some features on this website will not work correctly.
\t</div>
</noscript>
";
        // line 21
        if ( !Twig\Extension\CoreExtension::constant("MYAAC_ADMIN", null, true)) {
            // line 22
            yield "\t";
            yield Twig\Extension\CoreExtension::include($this->env, $context, "tables.style.html.twig");
            yield "
";
        }
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "templates.header.html.twig";
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
        return array (  98 => 22,  96 => 21,  86 => 14,  82 => 13,  77 => 11,  72 => 10,  67 => 8,  62 => 7,  60 => 6,  56 => 5,  51 => 3,  47 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "templates.header.html.twig", "/var/www/html/system/templates/templates.header.html.twig");
    }
}
