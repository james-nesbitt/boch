<?php
/**
* Drush Aliases
*/

// Core project site : {project}
$aliases['{project}'] = array(
  'uri' => '{project}.dev',
  'root' => '/app/source/www',
  'databases' => array (
    'default' => array (
      'default' => array (
        'driver' => 'mysql',
        'database' => '{project}',
        'username' => '{project}',
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
      'account-name' => '{project}',
      'account-pass' => 'Y0lw7pqPn5by22qnzfpDMbIIjXnK3a',
      'account-mail' => '{project}@{project}.test.com',
      'site-name' => '{project}',
      'site-mail' => '{project}@{project}.test.com',
      'yes' => FALSE,
    ),
  ),
);
