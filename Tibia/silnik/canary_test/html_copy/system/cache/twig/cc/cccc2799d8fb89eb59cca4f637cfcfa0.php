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

/* gallery.html.twig */
class __TwigTemplate_5f027f6c8a49e2c6b1e860f08a39fd76 extends Template
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
        yield "<div id=\"GalleryBox\" class=\"Themebox\" style=\"background-image:url(";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/themeboxes/gallery/gallerybox.gif);\">
\t<a href=\"?subtopic=gallery&image=";
        // line 2
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v0 = ($context["config"] ?? null)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0["gallery_image_id_from_database"] ?? null) : null), "html", null, true);
        yield "\" >
\t\t<img id=\"GalleryContent\" class=\"ThemeboxContent\" src=\"";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v1 = ($context["image"] ?? null)) && is_array($_v1) || $_v1 instanceof ArrayAccess ? ($_v1["thumb"] ?? null) : null), "html", null, true);
        yield "\" alt=\"Screenshot of the Day\" />
\t</a>
\t<div class=\"Bottom\" style=\"background-image:url(";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/general/box-bottom.gif);\"></div>
</div>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "gallery.html.twig";
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
        return array (  56 => 5,  51 => 3,  47 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "gallery.html.twig", "/var/www/html/templates/tibiacom/boxes/templates/gallery.html.twig");
    }
}
