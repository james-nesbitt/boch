<?php
/**
* Drush Aliases
*/

// Core site : {project.url}
$aliases['main'] = array(
  'uri' => '`[project.url}',
  'root' => '{project.root}',
  'remote-host' => '{project.host}',
  'remote-user' => '{project.sshuser}',
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
