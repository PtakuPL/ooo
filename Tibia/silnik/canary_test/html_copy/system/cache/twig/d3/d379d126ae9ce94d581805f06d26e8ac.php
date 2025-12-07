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

/* account.management.html.twig */
class __TwigTemplate_950c8087e0fa78d9a83f6757f23b3cfc extends Template
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
        yield "<div class=\"SmallBox\">
\t<div class=\"MessageContainer\">
\t\t<div class=\"BoxFrameHorizontal\" style=\"background-image:url(";
        // line 3
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-horizontal.gif);\"></div>
\t<div class=\"BoxFrameEdgeLeftTop\" style=\"background-image:url(";
        // line 4
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeRightTop\" style=\"background-image:url(";
        // line 5
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"Message\">
\t\t\t<div class=\"BoxFrameVerticalLeft\" style=\"background-image:url(";
        // line 7
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-vertical.gif);\"></div>
\t\t\t<div class=\"BoxFrameVerticalRight\" style=\"background-image:url(";
        // line 8
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-vertical.gif);\"></div>
\t\t\t<table>
\t\t\t\t<tr>
\t\t\t\t\t<td width=\"100%\"></td>
\t\t\t\t\t<td>
\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" >
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t\t\t<form action=\"";
        // line 16
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/logout"), "html", null, true);
        yield "\" method=\"post\" >
\t\t\t\t\t\t\t\t\t\t";
        // line 17
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
        yield "
\t\t\t\t\t\t\t\t\t\t";
        // line 18
        yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.logout.html.twig");
        yield "
\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</table>
\t\t\t\t\t</td>
\t\t\t\t</tr>
\t\t\t</table>
\t\t</div>
\t\t<div class=\"BoxFrameHorizontal\" style=\"background-image:url(";
        // line 27
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-horizontal.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeRightBottom\" style=\"background-image:url(";
        // line 28
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeLeftBottom\" style=\"background-image:url(";
        // line 29
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/box-frame-edge.gif);\"></div>
\t</div>
</div>
<br/>
<div style=\"text-align:center\">
\t<table style=\"margin-left: auto; margin-right: auto;\">
\t\t<tr>
\t\t\t<td>
\t\t\t\t<img src=\"";
        // line 37
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/headline-bracer-left.gif\" />
\t\t\t</td>
\t\t\t<td style=\"text-align:center;vertical-align:middle;horizontal-align:center;font-size:17px;font-weight:bold;\" >";
        // line 39
        yield ($context["welcome_message"] ?? null);
        yield "<br/></td>
\t\t\t<td><img src=\"";
        // line 40
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/headline-bracer-right.gif\" /></td>
\t\t</tr>
\t</table>
\t<br/>
</div>
";
        // line 46
        if (Twig\Extension\CoreExtension::testEmpty(($context["recovery_key"] ?? null))) {
            // line 47
            yield "<div class=\"SmallBox\">
\t<div class=\"MessageContainer\">
\t\t<div class=\"BoxFrameHorizontal\" style=\"background-image:url(";
            // line 49
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-horizontal.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeLeftTop\" style=\"background-image:url(";
            // line 50
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeRightTop\" style=\"background-image:url(";
            // line 51
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"Message\">
\t\t\t<div class=\"BoxFrameVerticalLeft\" style=\"background-image:url(";
            // line 53
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-vertical.gif);\"></div>
\t\t\t<div class=\"BoxFrameVerticalRight\" style=\"background-image:url(";
            // line 54
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-vertical.gif);\"></div>
\t\t\t<table>
\t\t\t\t<tr>
\t\t\t\t\t<td class=\"LabelV\" >Hint:</td>
\t\t\t\t\t<td style=\"width:100%;\" >You can register your account for increased protection. Click on \"Register Account\" and get your free recovery key today!</td>
\t\t\t\t</tr>
\t\t\t</table>
\t\t\t<div style=\"text-align:center\">
\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style=\"margin-left: auto; margin-right: auto;\">
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t<form action=\"";
            // line 65
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/register"), "html", null, true);
            yield "\" method=\"post\">
\t\t\t\t\t\t\t\t";
            // line 66
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t";
            // line 67
            yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.register_account.html.twig");
            yield "
\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t</td>
\t\t\t\t\t</tr>
\t\t\t\t</table>
\t\t\t</div>
\t\t</div>
\t\t<div class=\"BoxFrameHorizontal\" style=\"background-image:url(";
            // line 74
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-horizontal.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeRightBottom\" style=\"background-image:url(";
            // line 75
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeLeftBottom\" style=\"background-image:url(";
            // line 76
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-edge.gif);\"></div>
\t</div>
</div>
<br/>
";
        }
        // line 81
        yield "
";
        // line 82
        if (($context["email_request"] ?? null)) {
            // line 83
            yield "<div class=\"SmallBox\">
\t<div class=\"MessageContainer\">
\t\t<div class=\"BoxFrameHorizontal\" style=\"background-image:url(";
            // line 85
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-horizontal.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeLeftTop\" style=\"background-image:url(";
            // line 86
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeRightTop\" style=\"background-image:url(";
            // line 87
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"Message\">
\t\t\t<div class=\"BoxFrameVerticalLeft\" style=\"background-image:url(";
            // line 89
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-vertical.gif);\"></div>
\t\t\t<div class=\"BoxFrameVerticalRight\" style=\"background-image:url(";
            // line 90
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-vertical.gif);\"></div>
\t\t\t<table>
\t\t\t\t<tr>
\t\t\t\t\t<td class=\"LabelV\" >Note:</td>
\t\t\t\t\t<td style=\"width:100%;\" >A request has been submitted to change the email address of this account to <b>";
            // line 94
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["email_new"] ?? null), "html", null, true);
            yield "</b>. After <b>";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(($context["email_new_time"] ?? null), "j F Y, G:i:s"), "html", null, true);
            yield "</b> you can accept the new email address and finish the process. Please cancel the request if you do not want your email address to be changed! Also cancel the request if you have no access to the new email address!</td>
\t\t\t\t</tr>
\t\t\t</table>
\t\t\t<div style=\"text-align:center\">
\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
\t\t\t\t\t<tr>
\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t<form action=\"";
            // line 101
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/change-email"), "html", null, true);
            yield "\" method=\"post\">
\t\t\t\t\t\t\t\t";
            // line 102
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t";
            // line 103
            yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.edit.html.twig");
            yield "
\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t</td>
\t\t\t\t\t</tr>
\t\t\t\t</table>
\t\t\t</div>
\t\t</div>
\t\t<div class=\"BoxFrameHorizontal\" style=\"background-image:url(";
            // line 110
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-horizontal.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeRightBottom\" style=\"background-image:url(";
            // line 111
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-edge.gif);\"></div>
\t\t<div class=\"BoxFrameEdgeLeftBottom\" style=\"background-image:url(";
            // line 112
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/box-frame-edge.gif);\"></div>
\t</div>
</div>
<br/><br/>
";
        }
        // line 117
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, "HOOK_ACCOUNT_MANAGE_BEFORE_GENERAL_INFORMATION"), "html", null, true);
        yield "
<a name=\"General+Information\" ></a>
<div class=\"TopButtonContainer\">
\t<div class=\"TopButton\">
\t\t<a href=\"#top\">
\t\t\t<img style=\"border:0px;\" src=\"";
        // line 122
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/back-to-top.gif\" />
\t\t</a>
\t</div>
</div>
";
        // line 126
        $context["title"] = "General Information";
        // line 127
        $context["tableClass"] = "Table3";
        // line 128
        $context["content"] = ('' === $tmp = \Twig\Extension\CoreExtension::captureOutput((function () use (&$context, $macros, $blocks) {
            // line 129
            yield "<table style=\"width:100%;\" >
\t<tr>
\t\t<td>
\t\t\t<div class=\"TableShadowContainerRightTop\">
\t\t\t\t<div class=\"TableShadowRightTop\" style=\"background-image:url(";
            // line 133
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-rt.gif);\"></div>
\t\t\t</div>
\t\t\t<div class=\"TableContentAndRightShadow\" style=\"background-image:url(";
            // line 135
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-rm.gif);\">
\t\t\t\t<div class=\"TableContentContainer\">
\t\t\t\t\t<table class=\"TableContent\" width=\"100%\">
\t\t\t\t\t\t";
            // line 138
            if (( !CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "account_login_by_email", [], "any", false, false, false, 138) || CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "account_login_by_email_fallback", [], "any", false, false, false, 138))) {
                // line 139
                yield "\t\t\t\t\t\t<tr style=\"background-color: ";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 139), "html", null, true);
                yield ";\" >
\t\t\t\t\t\t\t<td class=\"LabelV\" >Account ";
                // line 140
                if (Twig\Extension\CoreExtension::constant("USE_ACCOUNT_NAME")) {
                    yield "Name";
                } else {
                    yield "Number";
                }
                yield ":</td>
\t\t\t\t\t\t\t<td style=\"width:90%;\" >";
                // line 141
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["account"] ?? null), "html", null, true);
                yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            }
            // line 144
            yield "\t\t\t\t\t\t<tr style=\"background-color: ";
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 144), "html", null, true);
            yield ";\" >
\t\t\t\t\t\t\t<td class=\"LabelV\" >Email Address:</td>
\t\t\t\t\t\t\t<td style=\"width:90%;\" >";
            // line 146
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["account_email"] ?? null), "html", null, true);
            yield ($context["email_change"] ?? null);
            yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t<tr style=\"background-color: ";
            // line 148
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 148), "html", null, true);
            yield ";\" >
\t\t\t\t\t\t\t<td class=\"LabelV\" >Created:</td>
\t\t\t\t\t\t\t<td>";
            // line 150
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate(($context["account_created"] ?? null), "j F Y, G:i:s"), "html", null, true);
            yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t<tr style=\"background-color: ";
            // line 152
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 152), "html", null, true);
            yield ";\" >
\t\t\t\t\t\t\t<td class=\"LabelV\" >Last Login:</td>
\t\t\t\t\t\t\t<td>";
            // line 154
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->extensions['Twig\Extension\CoreExtension']->formatDate("now", "j F Y, G:i:s"), "html", null, true);
            yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            // line 157
            yield "\t\t\t\t\t\t<tr style=\"background-color: ";
            yield CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "lightborder", [], "any", false, false, false, 157);
            yield ";\">
\t\t\t\t\t\t\t<td class=\"LabelV\" >Account Status:</td>
\t\t\t\t\t\t\t<td>";
            // line 159
            yield ($context["account_status"] ?? null);
            yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t<tr style=\"background-color: ";
            // line 161
            yield CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "darkborder", [], "any", false, false, false, 161);
            yield ";\" >
\t\t\t\t\t\t\t<td class=\"LabelV\" >Registered:</td>
\t\t\t\t\t\t\t<td>";
            // line 163
            yield ($context["account_registered"] ?? null);
            yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            // line 166
            yield "\t\t\t\t\t</table>
\t\t\t\t</div>
\t\t\t</div>
\t\t\t<div class=\"TableShadowContainer\">
\t\t\t\t<div class=\"TableBottomShadow\" style=\"background-image:url(";
            // line 170
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-bm.gif);\" >
\t\t\t\t\t<div class=\"TableBottomLeftShadow\" style=\"background-image:url(";
            // line 171
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-bl.gif);\"></div>
\t\t\t\t\t<div class=\"TableBottomRightShadow\" style=\"background-image:url(";
            // line 172
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-br.gif);\"></div>
\t\t\t\t</div>
\t\t\t</div>
\t\t</td>
\t</tr>
\t<tr>
\t\t<td>
\t\t\t<table class=\"InnerTableButtonRow\" cellpadding=\"0\" cellspacing=\"0\">
\t\t\t\t<tr>
\t\t\t\t\t<td>
\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td style=\"border:0;\" >
\t\t\t\t\t\t\t\t\t<form action=\"";
            // line 185
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/change-password"), "html", null, true);
            yield "\" method=\"post\">
\t\t\t\t\t\t\t\t\t\t";
            // line 186
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t\t\t";
            // line 187
            yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.change_password.html.twig");
            yield "
\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</table>
\t\t\t\t\t</td>
\t\t\t\t\t<td>
\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t\t\t<form action=\"";
            // line 197
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/change-email"), "html", null, true);
            yield "\" method=\"post\">
\t\t\t\t\t\t\t\t\t\t";
            // line 198
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "

\t\t\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"newemail\" value=\"\"/>
\t\t\t\t\t\t\t\t\t\t<input type=\"hidden\" name=\"newemaildate\" value=\"0\">
\t\t\t\t\t\t\t\t\t\t";
            // line 202
            yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.change_email.html.twig");
            yield "
\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</table>
\t\t\t\t\t</td>
\t\t\t\t\t<td width=\"100%\"></td>
\t\t\t\t\t";
            // line 210
            yield "\t\t\t\t\t";
            if (Twig\Extension\CoreExtension::testEmpty(($context["recovery_key"] ?? null))) {
                // line 211
                yield "\t\t\t\t\t<td>
\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t\t\t<form action=\"";
                // line 215
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/register"), "html", null, true);
                yield "\" method=\"post\">
\t\t\t\t\t\t\t\t\t\t";
                // line 216
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
                yield "
\t\t\t\t\t\t\t\t\t\t";
                // line 217
                yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.register_account.html.twig");
                yield "
\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</table>
\t\t\t\t\t</td>
\t\t\t\t\t";
            }
            // line 224
            yield "\t\t\t\t</tr>
\t\t\t</table>
\t\t</td>
\t</tr>
</table>
";
            yield from [];
        })())) ? '' : new Markup($tmp, $this->env->getCharset());
        // line 230
        yield from $this->loadTemplate("tables.headline.html.twig", "account.management.html.twig", 230)->unwrap()->yield($context);
        // line 231
        yield "<br/>
";
        // line 232
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, "HOOK_ACCOUNT_MANAGE_BEFORE_PUBLIC_INFORMATION"), "html", null, true);
        yield "
<a name=\"Public+Information\"></a>
<div class=\"TopButtonContainer\">
\t<div class=\"TopButton\">
\t\t<a href=\"#top\">
\t\t\t<img style=\"border:0px;\" src=\"";
        // line 237
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/back-to-top.gif\"/>
\t\t</a>
\t</div>
</div>
";
        // line 241
        $context["title"] = "Public Information";
        // line 242
        $context["tableClass"] = "Table5";
        // line 243
        $context["content"] = ('' === $tmp = \Twig\Extension\CoreExtension::captureOutput((function () use (&$context, $macros, $blocks) {
            // line 244
            yield "<table style=\"width:100%;\">
\t<tr>
\t\t<td>
\t\t\t<div class=\"TableShadowContainerRightTop\">
\t\t\t\t<div class=\"TableShadowRightTop\" style=\"background-image:url(";
            // line 248
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-rt.gif);\" ></div>
\t\t\t</div>
\t\t\t<div class=\"TableContentAndRightShadow\" style=\"background-image:url(";
            // line 250
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-rm.gif);\" >
\t\t\t\t<div class=\"TableContentContainer\">
\t\t\t\t\t<table class=\"TableContent\" width=\"100%\">
\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t<table style=\"width:100%;\">
\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t<td class=\"LabelV\" >Real Name:</td>
\t\t\t\t\t\t\t\t\t\t<td style=\"width:90%;\" >";
            // line 258
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["account_rlname"] ?? null), "html", null, true);
            yield "</td>
\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t<td class=\"LabelV\" >Location:</td>
\t\t\t\t\t\t\t\t\t\t<td style=\"width:90%;\" >";
            // line 262
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["account_location"] ?? null), "html", null, true);
            yield "</td>
\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t</table>
\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t<td align=right>
\t\t\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t\t\t\t\t<form action=\"";
            // line 270
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/change-info"), "html", null, true);
            yield "\" method=\"post\">
\t\t\t\t\t\t\t\t\t\t\t\t";
            // line 271
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t\t\t\t\t";
            // line 272
            yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.edit.html.twig");
            yield "
\t\t\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t</table>
\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t</table>
\t\t\t\t</div>
\t\t\t</div>
\t\t\t<div class=\"TableShadowContainer\">
\t\t\t\t<div class=\"TableBottomShadow\" style=\"background-image:url(";
            // line 283
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-bm.gif);\">
\t\t\t\t\t<div class=\"TableBottomLeftShadow\" style=\"background-image:url(";
            // line 284
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-bl.gif);\"></div>
\t\t\t\t\t<div class=\"TableBottomRightShadow\" style=\"background-image:url(";
            // line 285
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-br.gif);\"></div>  \t\t\t\t\t\t\t\t\t</div>
\t\t\t</div>
\t\t</td>
\t</tr>
</table>
";
            yield from [];
        })())) ? '' : new Markup($tmp, $this->env->getCharset());
        // line 291
        yield from $this->loadTemplate("tables.headline.html.twig", "account.management.html.twig", 291)->unwrap()->yield($context);
        // line 292
        yield "<br/>
";
        // line 293
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, "HOOK_ACCOUNT_MANAGE_BEFORE_ACCOUNT_LOGS"), "html", null, true);
        yield "
<a name=\"Account+Logs\" ></a>
<div class=\"TopButtonContainer\">
\t<div class=\"TopButton\">
\t\t<a href=\"#top\">
\t\t\t<img style=\"border:0px;\" src=\"";
        // line 298
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/back-to-top.gif\"/>
\t\t</a>
\t</div>
</div>
";
        // line 302
        $context["title"] = "Account Logs";
        // line 303
        $context["tableClass"] = "Table3";
        // line 304
        $context["content"] = ('' === $tmp = \Twig\Extension\CoreExtension::captureOutput((function () use (&$context, $macros, $blocks) {
            // line 305
            yield "<table style=\"width:100%;\">
\t<tr>
\t\t<td>
\t\t\t<div class=\"TableShadowContainerRightTop\">
\t\t\t\t<div class=\"TableShadowRightTop\" style=\"background-image:url(";
            // line 309
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-rt.gif);\"></div>
\t\t\t</div>
\t\t\t<div class=\"TableContentAndRightShadow\" style=\"background-image:url(";
            // line 311
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-rm.gif);\" >
\t\t\t\t<div class=\"TableContentContainer\" >
\t\t\t\t\t<table class=\"TableContent\" width=\"100%\">
\t\t\t\t\t\t<tr class=\"LabelH\">
\t\t\t\t\t\t\t<td style=\"width:60%\">Action</td>
\t\t\t\t\t\t\t<td style=\"width:25%\">Date</td>
\t\t\t\t\t\t\t<td style=\"width:15%\">IP</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            // line 320
            yield "\t\t\t\t\t\t";
            $context["i"] = 0;
            // line 321
            yield "\t\t\t\t\t\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["actions"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["action"]) {
                // line 322
                yield "\t\t\t\t\t\t\t";
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 323
                yield "\t\t\t\t\t\t<tr style=\"background-color: ";
                yield $this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null));
                yield "\">
\t\t\t\t\t\t\t<td>";
                // line 324
                yield CoreExtension::getAttribute($this->env, $this->source, $context["action"], "action", [], "any", false, false, false, 324);
                yield "</td>
\t\t\t\t\t\t\t<td>";
                // line 325
                yield $this->extensions['Twig\Extension\CoreExtension']->formatDate(CoreExtension::getAttribute($this->env, $this->source, $context["action"], "date", [], "any", false, false, false, 325), "jS F Y H:i:s");
                yield "</td>
\t\t\t\t\t\t\t<td>";
                // line 326
                yield CoreExtension::getAttribute($this->env, $this->source, $context["action"], "ip", [], "any", false, false, false, 326);
                yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['action'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 329
            yield "\t\t\t\t\t\t";
            // line 330
            yield "\t\t\t\t\t</table>
\t\t\t\t</div>
\t\t\t</div>
\t\t\t<div class=\"TableShadowContainer\" >
\t\t\t\t<div class=\"TableBottomShadow\" style=\"background-image:url(";
            // line 334
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-bm.gif);\" >
\t\t\t\t\t<div class=\"TableBottomLeftShadow\" style=\"background-image:url(";
            // line 335
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-bl.gif);\"></div>
\t\t\t\t\t<div class=\"TableBottomRightShadow\" style=\"background-image:url(";
            // line 336
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-br.gif);\"></div>
\t\t\t\t</div>
\t\t\t</div>
\t\t</td>
\t\t<td align=right>
\t\t</td>
\t</tr>
</table>
";
            yield from [];
        })())) ? '' : new Markup($tmp, $this->env->getCharset());
        // line 345
        yield from $this->loadTemplate("tables.headline.html.twig", "account.management.html.twig", 345)->unwrap()->yield($context);
        // line 346
        yield "<br/>
";
        // line 347
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, "HOOK_ACCOUNT_MANAGE_BEFORE_CHARACTERS"), "html", null, true);
        yield "
<a name=\"Characters\" ></a>
<div class=\"TopButtonContainer\">
\t<div class=\"TopButton\" >
\t\t<a href=\"#top\">
\t\t\t<img style=\"border:0px;\" src=\"";
        // line 352
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
        yield "/images/content/back-to-top.gif\" />
\t\t</a>
\t</div>
</div>
";
        // line 356
        $context["title"] = "Characters";
        // line 357
        $context["content"] = ('' === $tmp = \Twig\Extension\CoreExtension::captureOutput((function () use (&$context, $macros, $blocks) {
            // line 358
            yield "<table style=\"width:100%;\">
\t<tr>
\t\t<td>
\t\t\t<div class=\"TableShadowContainerRightTop\">
\t\t\t\t<div class=\"TableShadowRightTop\" style=\"background-image:url(";
            // line 362
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-rt.gif);\"></div>
\t\t\t</div>
\t\t\t<div class=\"TableContentAndRightShadow\" style=\"background-image:url(";
            // line 364
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-rm.gif);\">
\t\t\t\t<div class=\"TableContentContainer\">
\t\t\t\t\t<table class=\"TableContent\" width=\"100%\">
\t\t\t\t\t\t<tr class=\"LabelH\">
\t\t\t\t\t\t\t<td style=\"width:65%\">Name</td>
\t\t\t\t\t\t\t<td style=\"width:15%\">Level</td>
\t\t\t\t\t\t\t<td style=\"width:7%\">Status</td>
\t\t\t\t\t\t\t<td style=\"width:5%\">&#160;</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            // line 373
            $context["i"] = 0;
            // line 374
            yield "\t\t\t\t\t\t";
            $context['_parent'] = $context;
            $context['_seq'] = CoreExtension::ensureTraversable(($context["players"] ?? null));
            foreach ($context['_seq'] as $context["_key"] => $context["player"]) {
                // line 375
                yield "\t\t\t\t\t\t\t";
                $context["i"] = (($context["i"] ?? null) + 1);
                // line 376
                yield "\t\t\t\t\t\t<tr style=\"background-color: ";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getStyle')->getCallable()(($context["i"] ?? null)), "html", null, true);
                yield ";\">
\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t<nobr>";
                // line 378
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["i"] ?? null), "html", null, true);
                yield ". ";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getName", [], "method", false, false, false, 378), "html", null, true);
                if (CoreExtension::getAttribute($this->env, $this->source, $context["player"], "isDeleted", [], "method", false, false, false, 378)) {
                    yield "<span style=\"color: red\"><b> [ DELETED ] </b></span>";
                }
                yield "</nobr>
\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t<td>
\t\t\t\t\t\t\t\t<nobr>";
                // line 381
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getLevel", [], "method", false, false, false, 381), "html", null, true);
                yield " ";
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape((($_v0 = CoreExtension::getAttribute($this->env, $this->source, ($context["config"] ?? null), "vocations", [], "any", false, false, false, 381)) && is_array($_v0) || $_v0 instanceof ArrayAccess ? ($_v0[CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getVocation", [], "method", false, false, false, 381)] ?? null) : null), "html", null, true);
                yield "</nobr>
\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t";
                // line 383
                if (CoreExtension::getAttribute($this->env, $this->source, $context["player"], "isOnline", [], "method", false, false, false, 383)) {
                    // line 384
                    yield "\t\t\t\t\t\t\t<td><span style=\"color: green\"><b>Online</b></span></td>
\t\t\t\t\t\t\t";
                } else {
                    // line 386
                    yield "\t\t\t\t\t\t\t<td><span style=\"color: red\"><b>Offline</b></span></td>
\t\t\t\t\t\t\t";
                }
                // line 388
                yield "\t\t\t\t\t\t\t<td>";
                if ( !CoreExtension::getAttribute($this->env, $this->source, $context["player"], "isDeleted", [], "method", false, false, false, 388)) {
                    yield "[<a href=\"";
                    yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()(("account/characters/change-comment?name=" . $this->env->getFilter('urlencode')->getCallable()(CoreExtension::getAttribute($this->env, $this->source, $context["player"], "getName", [], "any", false, false, false, 388)))), "html", null, true);
                    yield "\" >Edit</a>]";
                }
                yield "</td>
\t\t\t\t\t\t</tr>
\t\t\t\t\t\t";
            }
            $_parent = $context['_parent'];
            unset($context['_seq'], $context['_key'], $context['player'], $context['_parent']);
            $context = array_intersect_key($context, $_parent) + $_parent;
            // line 391
            yield "\t\t\t\t\t</table>
\t\t\t\t</div>
\t\t\t</div>
\t\t\t<div class=\"TableShadowContainer\">
\t\t\t\t<div class=\"TableBottomShadow\" style=\"background-image:url(";
            // line 395
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-bm.gif);\" >
\t\t\t\t\t<div class=\"TableBottomLeftShadow\" style=\"background-image:url(";
            // line 396
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-bl.gif);\"></div>
\t\t\t\t\t<div class=\"TableBottomRightShadow\" style=\"background-image:url(";
            // line 397
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(($context["template_path"] ?? null), "html", null, true);
            yield "/images/content/table-shadow-br.gif);\"></div>
\t\t\t\t</div>
\t\t\t</div>
\t\t</td>
\t</tr>
\t<tr>
\t\t<td>
\t\t\t<table class=\"InnerTableButtonRow\" cellpadding=\"0\" cellspacing=\"0\" >
\t\t\t\t<tr>
\t\t\t\t\t<td>
\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" >
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t\t\t<form action=\"";
            // line 410
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/characters/create"), "html", null, true);
            yield "\" method=\"post\" >
\t\t\t\t\t\t\t\t\t\t";
            // line 411
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t\t\t";
            // line 412
            yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.create_character.html.twig");
            yield "
\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</table>
\t\t\t\t\t</td>
\t\t\t\t\t";
            // line 418
            if ($this->env->getFunction('setting')->getCallable()("core.account_change_character_name")) {
                // line 419
                yield "\t\t\t\t\t<td>
\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" >
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t\t\t<form action=\"";
                // line 423
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/characters/change-name"), "html", null, true);
                yield "\" method=\"post\" >
\t\t\t\t\t\t\t\t\t\t";
                // line 424
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
                yield "
\t\t\t\t\t\t\t\t\t\t";
                // line 425
                yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.change_name.html.twig");
                yield "
\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</table>
\t\t\t\t\t</td>
\t\t\t\t\t";
            }
            // line 432
            yield "\t\t\t\t\t";
            if ($this->env->getFunction('setting')->getCallable()("core.account_change_character_sex")) {
                // line 433
                yield "\t\t\t\t\t<td>
\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" >
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td style=\"border:0;\">
\t\t\t\t\t\t\t\t\t<form action=\"";
                // line 437
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/characters/change-sex"), "html", null, true);
                yield "\" method=\"post\">
\t\t\t\t\t\t\t\t\t\t";
                // line 438
                yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
                yield "
\t\t\t\t\t\t\t\t\t\t";
                // line 439
                yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.change_sex.html.twig");
                yield "
\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</table>
\t\t\t\t\t</td>
\t\t\t\t\t";
            }
            // line 446
            yield "\t\t\t\t\t<td style=\"width:100%;\" ></td>
\t\t\t\t\t<td>
\t\t\t\t\t\t<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t<td style=\"border: 0;\">
\t\t\t\t\t\t\t\t\t<form action=\"";
            // line 451
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('getLink')->getCallable()("account/characters/delete"), "html", null, true);
            yield "\" method=\"post\">
\t\t\t\t\t\t\t\t\t\t";
            // line 452
            yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('csrf')->getCallable()(), "html", null, true);
            yield "
\t\t\t\t\t\t\t\t\t\t";
            // line 453
            yield Twig\Extension\CoreExtension::include($this->env, $context, "buttons.delete_character.html.twig");
            yield "
\t\t\t\t\t\t\t\t\t</form>
\t\t\t\t\t\t\t\t</td>
\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t</table>
\t\t\t\t\t</td>
\t\t\t\t</tr>
\t\t\t</table>
\t\t</td>
\t</tr>
</table>
";
            yield from [];
        })())) ? '' : new Markup($tmp, $this->env->getCharset());
        // line 465
        yield from $this->loadTemplate("tables.headline.html.twig", "account.management.html.twig", 465)->unwrap()->yield($context);
        // line 466
        yield "<br/>
";
        // line 467
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape($this->env->getFunction('hook')->getCallable()($context, "HOOK_ACCOUNT_MANAGE_AFTER_CHARACTERS"), "html", null, true);
        yield "

<br/>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "account.management.html.twig";
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
        return array (  957 => 467,  954 => 466,  952 => 465,  936 => 453,  932 => 452,  928 => 451,  921 => 446,  911 => 439,  907 => 438,  903 => 437,  897 => 433,  894 => 432,  884 => 425,  880 => 424,  876 => 423,  870 => 419,  868 => 418,  859 => 412,  855 => 411,  851 => 410,  835 => 397,  831 => 396,  827 => 395,  821 => 391,  807 => 388,  803 => 386,  799 => 384,  797 => 383,  790 => 381,  779 => 378,  773 => 376,  770 => 375,  765 => 374,  763 => 373,  751 => 364,  746 => 362,  740 => 358,  738 => 357,  736 => 356,  729 => 352,  721 => 347,  718 => 346,  716 => 345,  703 => 336,  699 => 335,  695 => 334,  689 => 330,  687 => 329,  678 => 326,  674 => 325,  670 => 324,  665 => 323,  662 => 322,  657 => 321,  654 => 320,  643 => 311,  638 => 309,  632 => 305,  630 => 304,  628 => 303,  626 => 302,  619 => 298,  611 => 293,  608 => 292,  606 => 291,  596 => 285,  592 => 284,  588 => 283,  574 => 272,  570 => 271,  566 => 270,  555 => 262,  548 => 258,  537 => 250,  532 => 248,  526 => 244,  524 => 243,  522 => 242,  520 => 241,  513 => 237,  505 => 232,  502 => 231,  500 => 230,  491 => 224,  481 => 217,  477 => 216,  473 => 215,  467 => 211,  464 => 210,  454 => 202,  447 => 198,  443 => 197,  430 => 187,  426 => 186,  422 => 185,  406 => 172,  402 => 171,  398 => 170,  392 => 166,  387 => 163,  382 => 161,  377 => 159,  371 => 157,  366 => 154,  361 => 152,  356 => 150,  351 => 148,  345 => 146,  339 => 144,  333 => 141,  325 => 140,  320 => 139,  318 => 138,  312 => 135,  307 => 133,  301 => 129,  299 => 128,  297 => 127,  295 => 126,  288 => 122,  280 => 117,  272 => 112,  268 => 111,  264 => 110,  254 => 103,  250 => 102,  246 => 101,  234 => 94,  227 => 90,  223 => 89,  218 => 87,  214 => 86,  210 => 85,  206 => 83,  204 => 82,  201 => 81,  193 => 76,  189 => 75,  185 => 74,  175 => 67,  171 => 66,  167 => 65,  153 => 54,  149 => 53,  144 => 51,  140 => 50,  136 => 49,  132 => 47,  130 => 46,  122 => 40,  118 => 39,  113 => 37,  102 => 29,  98 => 28,  94 => 27,  82 => 18,  78 => 17,  74 => 16,  63 => 8,  59 => 7,  54 => 5,  50 => 4,  46 => 3,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "account.management.html.twig", "/var/www/html/templates/tibiacom/account.management.html.twig");
    }
}
