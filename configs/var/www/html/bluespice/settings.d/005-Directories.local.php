<?php
//File: 005-Directories.local.php
// Cache directory.
// If this is not set database will be used.
// Must be writable by webserver.

$wgCacheDirectory = getenv( 'BLUESPICE_DATA_PATH' ) . "/cache";

$wgUploadDirectory = getenv( 'BLUESPICE_DATA_PATH' ) . "/images";
$wgUploadPath = "$wgScriptPath/nsfr_img_auth.php";
$wgEnableUploads = true;

define( 'BS_DATA_DIR', getenv( 'BLUESPICE_DATA_PATH' ) . "/data" );

define( 'BSCONFIGDIR', getenv( 'BLUESPICE_DATA_PATH' ) . "/config" );
define( 'BSDATADIR', BS_DATA_DIR );
//..: compiled_templates (Widgets)

// This often causes problems. Only if really needed.
// Must be writable by webserver.
#$wgTmpDirectory = "/opt/bluespice/tmp";

// Only if Widgets is enabled.
// If this is not set $IP/extensions/Widgets/compiled_templates will be used.
// Must be writable by webserver.
#$wgWidgetsCompileDir = "/opt/bluespice/widgets";
