<?php

wfLoadExtension( 'Math' );

$wgMathValidModes = [ 'png' ];
$wgDefaultUserOptions['math'] = 'png';
$wgHiddenPrefs[] = 'math';
$wgTexvc = "/usr/local/bin/texvc";
