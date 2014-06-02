<?php
/**
* Drush Aliases
*/

// Core BM site : {project}
$aliases['main'] = array(
  'uri' => '{project.localurl}',
  'root' => '/app/source/www',
  'databases' => array (
    'default' => array (
      'default' => array (
        'driver' => 'mysql',
        'database' => '{project.db}',
        'username' => '{project.dbuser',
        'password' => '{project.dbpass}',
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
      'account-name' => '{project}',
      'account-pass' => '{project.accountpass}',
      'account-mail' => '{project.accountmail}',
      'site-name' => '{project} : wkbe',
      'site-mail' => 'info@{project}.be',
      'yes' => FALSE,
    ),
  ),
);

