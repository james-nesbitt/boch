<?php
/**
* Drush Aliases
*
*/

// DEV site : {project}.dev
$aliases['{project}'] = array(
  'uri' => '{project}.dev',
  'root' => '/var/www/{project}.dev',
  'remote-host' => '{project}.dev',
  'remote-user' => 'developer',
  'path-aliases' => array('%dump-dir' => 'tmp/'),
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
  ),
);

// ACC site : {project}.acc
$aliases['{project}'] = array(
  'uri' => '{project}.acc',
  'root' => '/var/www/{project}.acc',
  'remote-host' => '{project}.acc',
  'remote-user' => 'developer',
  'path-aliases' => array('%dump-dir' => 'tmp/'),
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
  ),
);
