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

/* tinymce.html.twig */
class __TwigTemplate_bb12c82cbc053d9efdb81211a42eadb7 extends Template
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
        yield "<script type=\"text/javascript\" src=\"";
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "tools/ext/tinymce/tinymce.min.js\"></script>
<script type=\"text/javascript\">
\tlet unsaved = false;
\tlet lastContent = '';

\tfunction tinymceInit() {
\t\ttinymce.init({
\t\t\tselector: \"#editor\",
\t\t\tcontent_css: '";
        // line 9
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "template/style.css',
\t\t\ttheme: \"silver\",
\t\t\tplugins: 'preview searchreplace autolink directionality visualblocks visualchars fullscreen image link media codesample table charmap pagebreak nonbreaking anchor insertdatetime advlist lists wordcount help code emoticons',
\t\t\ttoolbar1: 'formatselect | bold italic strikethrough forecolor backcolor | emoticons link | alignleft aligncenter alignright alignjustify  | numlist bullist outdent indent  | removeformat code',
\t\t\tresize: 'both',
\t\t\timage_advtab: true,
\t\t\timages_upload_url: '";
        // line 15
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("ADMIN_URL"), "html", null, true);
        yield "tools/upload_image.php',
\t\t\timages_upload_credentials: true,

\t\t\trelative_urls: true,
\t\t\tdocument_base_url: \"";
        // line 19
        yield $this->env->getRuntime('Twig\Runtime\EscaperRuntime')->escape(Twig\Extension\CoreExtension::constant("BASE_URL"), "html", null, true);
        yield "\",

\t\t\ttable_class_list: [
\t\t\t\t{title: 'None', value: ''},
\t\t\t\t{title: 'Colored Table', value: 'myaac-table'},
\t\t\t],

\t\t\tlicense_key: 'gpl',

\t\t\tsetup: function (ed) {
\t\t\t\ted.on('NodeChange', function (e) {
\t\t\t\t\tif (ed.getContent() !== lastContent) {
\t\t\t\t\t\tunsaved = true;
\t\t\t\t\t}
\t\t\t\t});
\t\t\t}
\t\t});
\t}

\t\$(document).ready(function () {
\t\t\$(\":input\").change(function () { //triggers change in all input fields including text type
\t\t\tunsaved = true;
\t\t});

\t\t\$(\"#form\").submit(function (event) {
\t\t\tunsaved = false;
\t\t});

\t\tlastContent = \$(\"#editor\").val();
\t});

\tfunction unloadPage() {
\t\tif (unsaved) {
\t\t\treturn \"You have unsaved changes on this page. Do you want to leave this page and discard your changes or stay on this page?\";
\t\t}
\t}

\twindow.onbeforeunload = unloadPage;
</script>
";
        yield from [];
    }

    /**
     * @codeCoverageIgnore
     */
    public function getTemplateName(): string
    {
        return "tinymce.html.twig";
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
        return array (  70 => 19,  63 => 15,  54 => 9,  42 => 1,);
    }

    public function getSourceContext(): Source
    {
        return new Source("", "tinymce.html.twig", "/var/www/html/system/templates/tinymce.html.twig");
    }
}
