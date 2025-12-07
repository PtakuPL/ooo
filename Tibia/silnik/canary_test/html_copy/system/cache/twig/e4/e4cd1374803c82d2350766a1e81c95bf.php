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

/* admin.settings.html.twig */
class __TwigTemplate_f8209b4ecc1e5a88f7d8ddfc508b86f3 extends Template
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
        yield "<div class=\"card card-primary card-outline card-outline-tabs\">
\t<div class=\"card-header\">
\t\t<h5 class=\"m-0\">Settings</h5>
\t</div>
\t<div class=\"card-body\">
\t\t<form id=\"settings\" method=\"post\">
\t\t\t<div class=\"row\">
\t\t\t\t<div class=\"col-md-12\">
\t\t\t\t\t<div class=\"box\">
\t\t\t\t\t\t<div class=\"box-body\">
\t\t\t\t\t\t\t<button name=\"save\" type=\"submit\" class=\"btn btn-primary\">Save</button>
\t\t\t\t\t\t</div>
\t\t\t\t\t\t<br/>
\t\t\t\t\t\t";
        // line 14
        yield ($context["settingsParsed"] ?? null);
        yield "
\t\t\t\t\t</div>
\t\t\t\t</div>
\t\t\t</div>
\t\t</form>
\t</div>
</div>
<style>
\t.setting-default {
\t\twhite-space: pre-wrap;
\t}
</style>
<script>
\tfunction doShowHide(el, show)
\t{
\t\tif (show) {
\t\t\t\$(el).show()
\t\t}
\t\telse {
\t\t\t\$(el).hide()
\t\t}
\t}

";
        // line 37
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["settings"] ?? null));
        foreach ($context['_seq'] as $context["key"] => $context["value"]) {
            // line 38
            yield "\t";
            if (CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", true, true, false, 38)) {
                // line 39
                yield "\t\t\$(function () {
\t\t\t\$('input[name=\"settings[";
                // line 40
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v0 = CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", false, false, false, 40)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0[0] ?? null) : null), "html", null, true);
                yield "]\"]').change(function () {
\t\t\t\tperformChecks_";
                // line 41
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["key"], "html", null, true);
                yield "(this);
\t\t\t});

\t\t\t";
                // line 44
                if (((($_v1 = (($_v2 = ($context["settings"] ?? null)) && is_array($_v2) || $_v2 instanceof ArrayAccess ? ($_v2[(($_v3 = CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", false, false, false, 44)) && is_array($_v3) || $_v3 instanceof ArrayAccess ? ($_v3[0] ?? null) : null)] ?? null) : null)) && is_array($_v1) || $_v1 instanceof ArrayAccess ? ($_v1["type"] ?? null) : null) == "boolean")) {
                    // line 45
                    yield "\t\t\tperformChecks_";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["key"], "html", null, true);
                    yield "('input[name=\"settings[";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v4 = CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", false, false, false, 45)) && is_array($_v4) || $_v4 instanceof ArrayAccess ? ($_v4[0] ?? null) : null), "html", null, true);
                    yield "]\"]:checked');
\t\t\t";
                } else {
                    // line 47
                    yield "\t\t\tperformChecks_";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["key"], "html", null, true);
                    yield "('input[name=\"settings[";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v5 = CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", false, false, false, 47)) && is_array($_v5) || $_v5 instanceof ArrayAccess ? ($_v5[0] ?? null) : null), "html", null, true);
                    yield "]\"]');
\t\t\t";
                }
                // line 49
                yield "\t\t});

\t\tfunction performChecks_";
                // line 51
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["key"], "html", null, true);
                yield "(el)
\t\t{
\t\t\tlet success = false;
\t\t\tlet thisVal = \$(el).val();

\t\t\tlet operator = '";
                // line 56
                yield (($_v6 = CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", false, false, false, 56)) && is_array($_v6) || $_v6 instanceof ArrayAccess ? ($_v6[1] ?? null) : null);
                yield "';
\t\t\tif (operator === '>') {
\t\t\t\tsuccess = thisVal > Number('";
                // line 58
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v7 = CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", false, false, false, 58)) && is_array($_v7) || $_v7 instanceof ArrayAccess ? ($_v7[2] ?? null) : null), "html", null, true);
                yield "');
\t\t\t}
\t\t\telse if (operator === '<') {
\t\t\t\tsuccess = thisVal < Number('";
                // line 61
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v8 = CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", false, false, false, 61)) && is_array($_v8) || $_v8 instanceof ArrayAccess ? ($_v8[2] ?? null) : null), "html", null, true);
                yield "');
\t\t\t}
\t\t\telse if (operator === '==' || operator === '=') {
\t\t\t\tsuccess = thisVal == '";
                // line 64
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v9 = CoreExtension::getAttribute($this->env, $this->source, $context["value"], "show_if", [], "any", false, false, false, 64)) && is_array($_v9) || $_v9 instanceof ArrayAccess ? ($_v9[2] ?? null) : null), "html", null, true);
                yield "';
\t\t\t}

\t\t\tdoShowHide('#row_";
                // line 67
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["key"], "html", null, true);
                yield "', success);
\t\t}
\t";
            }
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['key'], $context['value'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 71
        yield "</script>
";
        // line 72
        yield ($context["script"] ?? null);
        yield "
<!-- jQuery Form Submit No Refresh + Toastify -->
<link rel=\"stylesheet\" type=\"text/css\" href=\"";
        // line 74
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "tools/css/toastify.min.css\">
<script type=\"text/javascript\" src=\"";
        // line 75
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "tools/js/toastify.min.js\"></script>
<script>
\t\$.ajaxSetup({
\t\theaders: {
\t\t\t'X-CSRF-TOKEN': \$('meta[name=\"csrf-token\"]').attr('content')
\t\t}
\t});

\tconst noChangesText = \"No changes has been made\";

\t\$('form')
\t\t.each(function(){
\t\t\t\$(this).data('serialized', \$(this).serialize())
\t\t})
\t\t.on('change input', function(){
\t\t\tconst disable = \$(this).serialize() === \$(this).data('serialized');
\t\t\t\$(this)
\t\t\t\t.find('input:submit, button:submit')
\t\t\t\t.prop('disabled', disable)
\t\t\t\t.prop('title', disable ? noChangesText : '')
\t\t\t;
\t\t})
\t\t.find('input:submit, button:submit')
\t\t.prop('disabled', true)
\t\t.prop('title', noChangesText)
\t;

\t\$('#settings').on('submit', function(e) {
\t\te.preventDefault();

\t\t\$.ajax({
\t\t\ttype: 'POST',
\t\t\turl: '";
        // line 107
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "tools/settings_save.php?plugin=";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["settingsKeyName"] ?? null), "html", null, true);
        yield "',
\t\t\tdata : \$(this).serialize(),
\t\t\tsuccess : function(response) {
\t\t\t\tToastify({
\t\t\t\t\tposition: 'center',
\t\t\t\t\ttext: response,
\t\t\t\t\tduration: 3000,
\t\t\t\t\tescapeMarkup: false,
\t\t\t\t}).showToast();

\t\t\t\tlet \$settings = \$('#settings');
\t\t\t\t\$settings.data('serialized', \$settings.serialize());
\t\t\t\t\$settings
\t\t\t\t\t.find('input:submit, button:submit')
\t\t\t\t\t.prop('disabled', true)
\t\t\t\t\t.prop('title', noChangesText);
\t\t\t},
\t\t\terror : function(response) {
\t\t\t\tToastify({
\t\t\t\t\tposition: 'center',
\t\t\t\t\ttext: response.responseText,
\t\t\t\t\tduration: 3000,
\t\t\t\t\tstyle: {
\t\t\t\t\t\tbackground: 'red',
\t\t\t\t\t},
\t\t\t\t\tescapeMarkup: false,
\t\t\t\t}).showToast();
\t\t\t}
\t\t});
\t});
</script>

<script>
";
        // line 140
        $context['_parent'] = $context;
        $context['_seq'] = CoreExtension::ensureTraversable(($context["settings"] ?? null));
        foreach ($context['_seq'] as $context["key"] => $context["value"]) {
            // line 141
            yield "\t";
            if ((CoreExtension::getAttribute($this->env, $this->source, $context["value"], "type", [], "any", false, false, false, 141) == "password")) {
                // line 142
                yield "\t\t\t\$(function () {
\t\t\t\t\$('#show-hide-";
                // line 143
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["key"], "html", null, true);
                yield " a').on('click', function(event) {
\t\t\t\t\tevent.preventDefault();

\t\t\t\t\tconst \$showHideIcon = \$('#show-hide-";
                // line 146
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["key"], "html", null, true);
                yield " i');
\t\t\t\t\tconst \$showHideInput = \$('#show-hide-";
                // line 147
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($context["key"], "html", null, true);
                yield " input');
\t\t\t\t\tif(\$showHideInput.attr('type') === 'text'){
\t\t\t\t\t\t\$showHideInput.attr('type', 'password');
\t\t\t\t\t\t\$showHideIcon.addClass('fa-eye-slash');
\t\t\t\t\t\t\$showHideIcon.removeClass('fa-eye');
\t\t\t\t\t}else if(\$showHideInput.attr(\"type\") === 'password'){
\t\t\t\t\t\t\$showHideInput.attr('type', 'text');
\t\t\t\t\t\t\$showHideIcon.removeClass('fa-eye-slash');
\t\t\t\t\t\t\$showHideIcon.addClass('fa-eye');
\t\t\t\t\t}
\t\t\t\t});
\t\t\t});
\t";
            }
        }
        $_parent = $context['_parent'];
        unset($context['_seq'], $context['key'], $context['value'], $context['_parent']);
        $context = array_intersect_key($context, $_parent) + $_parent;
        // line 161
        yield "</script>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "admin.settings.html.twig";
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
        return array (  291 => 161,  271 => 147,  267 => 146,  261 => 143,  258 => 142,  255 => 141,  251 => 140,  213 => 107,  178 => 75,  174 => 74,  169 => 72,  166 => 71,  156 => 67,  150 => 64,  144 => 61,  138 => 58,  133 => 56,  125 => 51,  121 => 49,  113 => 47,  105 => 45,  103 => 44,  97 => 41,  93 => 40,  90 => 39,  87 => 38,  83 => 37,  57 => 14,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "admin.settings.html.twig", "/var/www/html/system/templates/admin.settings.html.twig");
    }
}
