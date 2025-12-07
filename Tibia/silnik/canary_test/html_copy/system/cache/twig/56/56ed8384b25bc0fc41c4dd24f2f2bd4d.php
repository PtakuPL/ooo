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

/* admin.news.form.html.twig */
class __TwigTemplate_bce216b6601383807d1f5e25f7d4977c extends Template
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
        if (($context["action"] ?? null)) {
            // line 2
            yield "\t<div class=\"card card-info card-outline\">
\t\t<div class=\"card-header\">
\t\t\t<h5 class=\"m-0\">";
            // line 4
            if ((($context["action"] ?? null) == "edit")) {
                yield "Edit";
            } else {
                yield "Add";
            }
            yield " ";
            if ((($context["type"] ?? null) == Twig\Extension\CoreExtension::constant("NEWS"))) {
                yield "News";
            } elseif ((($context["type"] ?? null) == Twig\Extension\CoreExtension::constant("TICKER"))) {
                yield "Ticker";
            } else {
                yield "Article";
            }
            yield "</h5>
\t\t</div>
\t\t<form id=\"form\" role=\"form\" method=\"post\">
\t\t\t";
            // line 7
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t<input type=\"hidden\" name=\"action\" value=\"";
            // line 8
            yield (((($context["action"] ?? null) == "edit")) ? ("edit") : ("new"));
            yield "\" />
\t\t\t<div class=\"card-body \" id=\"page-edit-table\">
\t\t\t\t";
            // line 10
            if ((($context["action"] ?? null) == "edit")) {
                // line 11
                yield "\t\t\t\t\t<input type=\"hidden\" name=\"id\" value=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["news_id"] ?? null), "html", null, true);
                yield "\"/>
\t\t\t\t";
            }
            // line 13
            yield "
\t\t\t\t<div class=\"form-group row\">
\t\t\t\t\t<label for=\"title\">Title</label>
\t\t\t\t\t<input type=\"text\" id=\"title\" name=\"title\" class=\"form-control\" autocomplete=\"off\" style=\"cursor: auto;\" value=\"";
            // line 16
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["title"] ?? null), "html", null, true);
            yield "\" required>
\t\t\t\t</div>

\t\t\t\t<label for=\"editor\">Content</label>
\t\t\t\t<div class=\"form-group\">
\t\t\t\t\t<textarea class=\"form-control\" id=\"editor\" name=\"body\" maxlength=\"65000\" cols=\"50\" rows=\"5\">";
            // line 21
            yield ($context["body"] ?? null);
            yield "</textarea>
\t\t\t\t</div>

\t\t\t\t<div class=\"form-group row\">
\t\t\t\t\t<label for=\"select-type\">Type</label>
\t\t\t\t\t<select class=\"form-control\" name=\"type\" id=\"select-type\">
\t\t\t\t\t\t<option value=\"";
            // line 27
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("NEWS"), "html", null, true);
            yield "\" ";
            if ((($context["type"] ?? null) == Twig\Extension\CoreExtension::constant("NEWS"))) {
                yield "selected=\"selected\"";
            }
            if (((($context["action"] ?? null) == "edit") && (($context["type"] ?? null) != Twig\Extension\CoreExtension::constant("NEWS")))) {
                yield " disabled";
            }
            yield ">News</option>
\t\t\t\t\t\t<option value=\"";
            // line 28
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("TICKER"), "html", null, true);
            yield "\" ";
            if ((($context["type"] ?? null) == Twig\Extension\CoreExtension::constant("TICKER"))) {
                yield "selected=\"selected\"";
            }
            if (((($context["action"] ?? null) == "edit") && (($context["type"] ?? null) != Twig\Extension\CoreExtension::constant("TICKER")))) {
                yield " disabled";
            }
            yield ">Ticker</option>
\t\t\t\t\t\t<option value=\"";
            // line 29
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ARTICLE"), "html", null, true);
            yield "\" ";
            if ((($context["type"] ?? null) == Twig\Extension\CoreExtension::constant("ARTICLE"))) {
                yield "selected=\"selected\"";
            }
            if (((($context["action"] ?? null) == "edit") && (($context["type"] ?? null) != Twig\Extension\CoreExtension::constant("ARTICLE")))) {
                yield " disabled";
            }
            yield ">Article</option>
\t\t\t\t\t</select>
\t\t\t\t</div>

\t\t\t\t<div id=\"article-text\" class=\"form-group row\"";
            // line 33
            if (( !array_key_exists("type", $context) || (($context["type"] ?? null) != Twig\Extension\CoreExtension::constant("ARTICLE")))) {
                yield " style=\"display: none;\"";
            }
            yield ">
\t\t\t\t\t<label for=\"article_text\">Article short text</label>
\t\t\t\t\t\t<textarea class=\"form-control\" name=\"article_text\" id=\"article_text\" cols=\"50\" rows=\"5\">";
            // line 35
            if ( !Twig\Extension\CoreExtension::testEmpty(($context["article_text"] ?? null))) {
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["article_text"] ?? null), "html", null, true);
            }
            yield "</textarea>
\t\t\t\t</div>

\t\t\t\t<div id=\"article-image\" class=\"form-group row\"";
            // line 38
            if (( !array_key_exists("type", $context) || (($context["type"] ?? null) != Twig\Extension\CoreExtension::constant("ARTICLE")))) {
                yield " style=\"display: none;\"";
            }
            yield ">
\t\t\t\t\t<label for=\"article_image\">Article image</label>
\t\t\t\t\t\t<input class=\"form-control\" type=\"text\" name=\"article_image\" id=\"article_image\" value=\"";
            // line 40
            if ( !Twig\Extension\CoreExtension::testEmpty(($context["article_image"] ?? null))) {
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["article_image"] ?? null), "html", null, true);
            } else {
                yield "images/news/announcement.jpg";
            }
            yield "\"/>
\t\t\t\t</div>
\t\t\t\t<div class=\"form-group row\">
\t\t\t\t\t";
            // line 43
            if ((($context["action"] ?? null) == "edit")) {
                // line 44
                yield "\t\t\t\t\t\t";
                if (array_key_exists("player", $context)) {
                    // line 45
                    yield "\t\t\t\t\t\t\t<div class=\"col-sm-6 pl-0\">
\t\t\t\t\t\t\t\t<label for=\"author\">Author</label>
\t\t\t\t\t\t\t\t<select class=\"form-control\" id=\"author\" name=\"original_id\" disabled=\"disabled\">
\t\t\t\t\t\t\t\t\t<option value=\"";
                    // line 48
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getId", [], "method", false, false, false, 48), "html", null, true);
                    yield "\">";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["player"] ?? null), "getName", [], "method", false, false, false, 48), "html", null, true);
                    yield "</option>
\t\t\t\t\t\t\t\t</select>
\t\t\t\t\t\t\t</div>
\t\t\t\t\t\t";
                }
                // line 52
                yield "\t\t\t\t\t";
            }
            // line 53
            yield "
\t\t\t\t\t<div class=\"col-sm-";
            // line 54
            yield (((($context["action"] ?? null) == "edit")) ? ("6") : ("12"));
            yield " px-0\">
\t\t\t\t\t\t<label for=\"player_id\">";
            // line 55
            if ((($context["action"] ?? null) == "edit")) {
                yield "Modified by";
            } else {
                yield "Author";
            }
            yield "</label>
\t\t\t\t\t\t<select class=\"form-control\" name=\"player_id\" id=\"player_id\">
\t\t\t\t\t\t\t";
            // line 57
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["account_players"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["player"]) {
                // line 58
                yield "\t\t\t\t\t\t\t\t<option value=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getId", [], "method", false, false, false, 58), "html", null, true);
                yield "\"";
                if ((array_key_exists("player_id", $context) && (CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getId", [], "method", false, false, false, 58) == ($context["player_id"] ?? null)))) {
                    yield " selected=\"selected\"";
                }
                yield ">";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getName", [], "method", false, false, false, 58), "html", null, true);
                yield "</option>
\t\t\t\t\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['player'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 60
            yield "\t\t\t\t\t\t</select>

\t\t\t\t\t</div>
\t\t\t\t</div>

\t\t\t\t";
            // line 65
            if ((($context["action"] ?? null) != "edit")) {
                // line 66
                yield "\t\t\t\t\t<div class=\"form-group row\">
\t\t\t\t\t\t<label for=\"forum_section\">Create forum thread in section:</label>
\t\t\t\t\t\t\t<select class=\"form-control\" name=\"forum_section\" id=\"forum_section\">
\t\t\t\t\t\t\t\t<option value=\"-1\">None</option>
\t\t\t\t\t\t\t\t";
                // line 70
                $context['_parent'] = $context;
                $context['_seq'] = CoreExtension::ensureTraversable(($context["forum_boards"] ?? null));
                foreach ($context['_seq'] as $context["_key"] => $context["section"]) {
                    // line 71
                    yield "\t\t\t\t\t\t\t\t\t<option value=\"";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["section"], "id", [], "any", false, false, false, 71), "html", null, true);
                    yield "\" ";
                    if ((array_key_exists("forum_section", $context) && (($context["forum_section"] ?? null) == CoreExtension::getAttribute($this->env, $this->source, $context["section"], "id", [], "any", false, false, false, 71)))) {
                        yield "checked=\"yes\"";
                    }
                    yield ">";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["section"], "name", [], "any", false, false, false, 71), "html", null, true);
                    yield "</option>
\t\t\t\t\t\t\t\t";
                }
                $_parent = $context['_parent'];
                unset($context['_seq'], $context['_key'], $context['section'], $context['_parent']);
                $context = array_intersect_key($context, $_parent) + $_parent;
                // line 73
                yield "\t\t\t\t\t\t\t</select>
\t\t\t\t\t</div>
\t\t\t\t";
            } elseif ( !(null ===             // line 75
($context["comments"] ?? null))) {
                // line 76
                yield "\t\t\t\t\t<input type=\"hidden\" name=\"forum_section\" id=\"forum_section\" value=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["comments"] ?? null), "html", null, true);
                yield "\"/>
\t\t\t\t";
            }
            // line 78
            yield "
\t\t\t\t<div class=\"form-group row\">
\t\t\t\t\t<label for=\"category\">Category</label>
\t\t\t\t\t<div class=\"col-sm-12\">
\t\t\t\t\t\t";
            // line 82
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["categories"] ?? null));
            foreach ($context['_seq'] as $context["id"] => $context["cat"]) {
                // line 83
                yield "\t\t\t\t\t\t\t<input type=\"radio\" name=\"category\" value=\"";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["id"], "html", null, true);
                yield "\" ";
                if ((((($context["category"] ?? null) == 0) && ($context["id"] == 1)) || (($context["category"] ?? null) == $context["id"]))) {
                    yield "checked=\"yes\"";
                }
                yield "/>
\t\t\t\t\t\t\t<img src=\"";
                // line 84
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
                yield "images/news/icon_";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["cat"], "icon_id", [], "any", false, false, false, 84), "html", null, true);
                yield "_small.gif\"/>
\t\t\t\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['id'], $context['cat'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 86
            yield "\t\t\t\t\t</div>
\t\t\t\t</div>
\t\t\t</div>
\t\t\t<div class=\"card-footer\">
\t\t\t\t<button type=\"submit\" class=\"btn btn-info\"><i class=\"fas fa-update\"></i> ";
            // line 90
            yield (((($context["action"] ?? null) == "edit")) ? ("Update") : ("Add"));
            yield "</button>
\t\t\t\t<button type=\"button\" onclick=\"window.location = '";
            // line 91
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
            yield "?p=news';\" class=\"btn btn-danger float-right\"><i class=\"fas fa-cancel\"></i> Cancel</button>
\t\t\t</div>
\t\t</form>

\t</div>

\t";
            // line 97
            if ((($context["action"] ?? null) != "edit")) {
                // line 98
                yield "\t\t<script type=\"text/javascript\">
\t\t\t\$(document).ready(function () {
\t\t\t\t\$(\"#news-edit\").hide();

\t\t\t\t\$(\"#news-button\").click(function () {
\t\t\t\t\t\$(\"#news-edit\").toggle();
\t\t\t\t\treturn false;
\t\t\t\t});

\t\t\t\t\$('#select-type').change(function () {
\t\t\t\t\tvar value = \$('#select-type').val();
\t\t\t\t\tif (value === ";
                // line 109
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ARTICLE"), "html", null, true);
                yield ") {
\t\t\t\t\t\t\$('#article-text').show();
\t\t\t\t\t\t\$('#article-image').show();
\t\t\t\t\t} else {
\t\t\t\t\t\t\$('#article-text').hide();
\t\t\t\t\t\t\$('#article-image').hide();
\t\t\t\t\t}
\t\t\t\t});
\t\t\t});
\t\t</script>
\t";
            }
            // line 120
            yield "
\t";
            // line 121
            yield Twig\Extension\CoreExtension::include($this->env, $context, "tinymce.html.twig");
            yield "
\t<script type=\"text/javascript\">
\t\ttinymceInit();
\t</script>
";
        }
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "admin.news.form.html.twig";
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
        return array (  356 => 121,  353 => 120,  339 => 109,  326 => 98,  324 => 97,  315 => 91,  311 => 90,  305 => 86,  295 => 84,  286 => 83,  282 => 82,  276 => 78,  270 => 76,  268 => 75,  264 => 73,  249 => 71,  245 => 70,  239 => 66,  237 => 65,  230 => 60,  215 => 58,  211 => 57,  202 => 55,  198 => 54,  195 => 53,  192 => 52,  183 => 48,  178 => 45,  175 => 44,  173 => 43,  163 => 40,  156 => 38,  148 => 35,  141 => 33,  127 => 29,  116 => 28,  105 => 27,  96 => 21,  88 => 16,  83 => 13,  77 => 11,  75 => 10,  70 => 8,  66 => 7,  48 => 4,  44 => 2,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "admin.news.form.html.twig", "/var/www/html/system/templates/admin.news.form.html.twig");
    }
}
