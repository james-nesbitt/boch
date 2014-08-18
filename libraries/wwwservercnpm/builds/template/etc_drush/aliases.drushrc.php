<?php
/**
* Drush Aliases
*
* This/These aliases are for local work, and 
* should allow you to connect to local Drupal
* projects for typical management.
* This assumes that you project has a root www
* folder, and that you have an sql database
* called "project" that can be accessed by user
* project:project
*
* TO USE:
*   $/> drush @local.project en -y views_ui
*   $/> drush @local.project site-install
*
*/

// Core project site : project
$aliases['project'] = array(
  'uri' => 'project.dev',
  'root' => '/app/source/www',
  'databases' => array (
    'default' => array (
      'default' => array (
        'driver' => 'mysql',
        'database' => 'project',
        'username' => 'project',
        'password' => 'project',
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
      'account-name' => 'project',
      'account-pass' => 'project',
      'account-mail' => 'project@project.test.com',
      'site-name' => 'project',
      'site-mail' => 'project@project.test.com',
      'yes' => FALSE,
    ),
  ),
);
