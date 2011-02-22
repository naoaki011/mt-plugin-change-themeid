package ChangeThemeID::Plugin;

use strict;

sub cfg_prefs {
    my ($cb, $app, $param, $tmpl) = @_;

    my $plugin = MT->component('ChangeThemeID');
    my $blog = $app->blog;

    # set theme info to param
    my @themes;
    require MT::Theme;
    my $themes = MT::Theme->load_all_themes();
    for my $theme (values %$themes) {
        next if ($theme->{class} ne $blog->class && $theme->{class} ne 'both');
        push @themes, {
            fjcti_id => $theme->{id},
            fjcti_label => $theme->name || $theme->label,
            fjcti_blog_theme_id => ($theme->{id} eq $blog->theme_id)
        };
    }
    $param->{fjcti_themes} = \@themes;
    if ($blog->theme_id) {
        my $theme = $themes->{$blog->theme_id};
        $param->{fjcti_cur_theme_id} = $blog->theme_id;
        $param->{fjcti_cur_theme_name} = $theme->name || $theme->label;
    }
    else {
        $param->{fjcti_cur_theme_name} = $plugin->translate('Not defined');
    }

    # customize cfg_prefs template
    my $host_node = $tmpl->getElementById('has-license');
    my $node = $tmpl->createElement('app:setting');
    $node->setAttribute('id', 'theme_id');
    $node->setAttribute('label', $plugin->translate('Theme ID'));
    my $html = <<HERE;
<span id="fjcti_cur_theme_id"><mt:if name="fjcti_cur_theme_id"><\$mt:var name="fjcti_cur_theme_id"\$>(<\$mt:var name="fjcti_cur_theme_name"\$>)<mt:else><\$mt:var name="fjcti_cur_theme_name"\$></mt:if></span>
<select name="theme_id" id="theme_id" class="full-width" style="display : none;">
    <option value=""><__trans phrase="Not defined"></option>
<mt:loop name="fjcti_themes">
    <option value="<\$mt:var name="fjcti_id"\$>"<mt:if name="fjcti_blog_theme_id"> selected="selected"</mt:if>><\$mt:var name="fjcti_id"\$>(<\$mt:var name="fjcti_label"\$>)</option>
</mt:loop>
</select>
&nbsp;<button id="fjcti_change_theme_id" onclick="jQuery(this).hide(); jQuery('#fjcti_cur_theme_id').hide(); jQuery('#theme_id').show(); return false;"><__trans phrase="Change theme ID"></button>
HERE
    $html = $plugin->translate_templatized($html);
    $node->innerHTML($html);
    $tmpl->insertAfter($node, $host_node);
}

1;
