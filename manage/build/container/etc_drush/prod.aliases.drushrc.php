<?php
/**
* Drush Aliases
*
* These are remote aliases designed to let you
* connect with remote environments directly
* using drush.
* 
* DEVELOPER: change these to match your remote
*   environments accordinagly.  Match the uri,
*   root, remote-user and remote-hosts; the rest
*   is somewhat generic.
*
* TO USE:
*   $/> drush @prod.dev cc all
*   $/> drush @prod.prod uli
*/

// DEV site : project.dev
$aliases['dev'] = array(
  'uri' => 'project.dev',
  'root' => '/var/www/project.dev',
  'remote-host' => 'project.dev',
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

// stage site : project.stage
$aliases['stage'] = array(
  'uri' => 'project.stage',
  'root' => '/var/www/project.stage',
  'remote-host' => 'project.stage',
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

// prod site : project.prod
$aliases['prod'] = array(
  'uri' => 'project.prod',
  'root' => '/var/www/project.prod',
  'remote-host' => 'project.prod',
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
