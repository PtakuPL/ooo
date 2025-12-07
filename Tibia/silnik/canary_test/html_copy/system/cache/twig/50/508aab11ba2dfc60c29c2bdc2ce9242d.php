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

/* networks.html.twig */
class __TwigTemplate_64e1333e1f6aa97f5720b20a3ae4375b extends Template
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
        if ((((($_v0 = ($context["config"] ?? null)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0["network_facebook"] ?? null) : null) != "") || ((($_v1 = ($context["config"] ?? null)) && is_array($_v1) || $_v1 instanceof ArrayAccess ? ($_v1["network_twitter"] ?? null) : null) != ""))) {
            // line 2
            yield "<div id=\"NetworksBox\" class=\"Themebox\" style=\"background-image:url(";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/themeboxes/networks/networksbox.png);\">
\t";
            // line 3
            if ( !Twig\Extension\CoreExtension::testEmpty((($_v2 = ($context["config"] ?? null)) && is_array($_v2) || $_v2 instanceof ArrayAccess ? ($_v2["network_facebook"] ?? null) : null))) {
                // line 4
                yield "\t<div id=\"FacebookBlock\">
\t\t<div id=\"FacebookLikeBox\">
\t\t\t<div class=\"fb-like-box fb_iframe_widget\" data-href=\"https://www.facebook.com/";
                // line 6
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v3 = ($context["config"] ?? null)) && is_array($_v3) || $_v3 instanceof ArrayAccess ? ($_v3["network_facebook"] ?? null) : null), "html", null, true);
                yield "\" data-width=\"175\" data-height=\"180\" data-show-faces=\"true\" data-stream=\"false\" data-border-color=\"none\" data-header=\"false\" fb-xfbml-state=\"rendered\">
\t\t\t\t<span style=\"vertical-align: bottom; width: 181px; height: 180px;\"></span>
\t\t\t</div>
\t\t</div>
\t\t<div id=\"FacebookSendBox\">
\t\t\t<div class=\"fb-send fb_iframe_widget\" data-href=\"https://www.facebook.com/";
                // line 11
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v4 = ($context["config"] ?? null)) && is_array($_v4) || $_v4 instanceof ArrayAccess ? ($_v4["network_facebook"] ?? null) : null), "html", null, true);
                yield "\" data-width=\"50\" data-height=\"20\" fb-xfbml-state=\"rendered\">
\t\t\t\t<span style=\"vertical-align: bottom; width: 50px; height: 20px;\"></span>
\t\t\t</div>
\t\t</div>
\t\t<div id=\"FacebookLikes\">
\t\t\t<div class=\"fb-like fb_edge_widget_with_comment fb_iframe_widget\" data-href=\"https://www.facebook.com/";
                // line 16
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v5 = ($context["config"] ?? null)) && is_array($_v5) || $_v5 instanceof ArrayAccess ? ($_v5["network_facebook"] ?? null) : null), "html", null, true);
                yield "\" data-send=\"false\" data-width=\"225\" data-show-faces=\"false\" fb-xfbml-state=\"rendered\">
\t\t\t\t<span style=\"height: 28px; width: 225px;\"></span>
\t\t\t</div>
\t\t</div>
\t</div>
\t";
            }
            // line 22
            yield "\t";
            if ( !Twig\Extension\CoreExtension::testEmpty((($_v6 = ($context["config"] ?? null)) && is_array($_v6) || $_v6 instanceof ArrayAccess ? ($_v6["network_twitter"] ?? null) : null))) {
                // line 23
                yield "\t<div id=\"TwitterBlock\">
\t\t<a href=\"https://twitter.com/";
                // line 24
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v7 = ($context["config"] ?? null)) && is_array($_v7) || $_v7 instanceof ArrayAccess ? ($_v7["network_twitter"] ?? null) : null), "html", null, true);
                yield "\" class=\"twitter-follow-button\" data-show-count=\"false\">Follow @";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v8 = ($context["config"] ?? null)) && is_array($_v8) || $_v8 instanceof ArrayAccess ? ($_v8["network_twitter"] ?? null) : null), "html", null, true);
                yield "</a>
\t\t<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
\t</div>
\t";
            }
            // line 28
            yield "\t<div class=\"Bottom\" style=\"background-image:url(";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/general/box-bottom.gif);\"></div>
</div>
";
        }
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "networks.html.twig";
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
        return array (  95 => 28,  86 => 24,  83 => 23,  80 => 22,  71 => 16,  63 => 11,  55 => 6,  51 => 4,  49 => 3,  44 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "networks.html.twig", "/var/www/html/templates/tibiacom/boxes/templates/networks.html.twig");
    }
}
