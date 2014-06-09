<?php
/**
* Drush Aliases
*/

// Core BM site : BMNR
$aliases['bmnr'] = array(
  'uri' => 'bmnr.dev',
  'root' => '/app/source/www',
  'databases' => array (
    'default' => array (
      'default' => array (
        'driver' => 'mysql',
        'database' => 'bmnr_drupal',
        'username' => 'bmnr',
        'password' => 'Y0lw7pqPn5by22qnzfpDMbIIjXnK3a',
      ),
    ),
  ),
  'path-aliases' => array(
    '%files' => '/app/source/www/sites/default/files',
    '%dump-dir' => '/app/source/DB',
  ),
  'command-specific' => array(
    'sql-sync' => array(
      'no-cache' => TRUE,
      'no-ordered-dump' => TRUE,
      'structure-tables' => array(
        'custom' => array(
          'cache',
          'cache_filter',
          'cache_menu',
          'cache_page',
          'cache_views_data',
          'history',
          'sessions',
        ),
      ),
    ),
    'site-install' => array(
      'account-name' => 'bmnr',
      'account-pass' => 'Y0lw7pqPn5by22qnzfpDMbIIjXnK3a',
      'account-mail' => 'bmnr@bmnr.wunderkraut.nl',
      'site-name' => 'BMNR : wknl',
      'site-mail' => 'info@bmnr.wunderkraut.nl',
      'yes' => FALSE,
    ),
  ),
);
