<?php
/**
* Drush Aliases
*
* @NOTE these aliases are not correct, they are prepatory
* as we don't know what the hosting situation for this client
* will be
*
*/

// DEV site : bmnr.dev.wunderkraut.nl
$aliases['bmnr'] = array(
  'uri' => 'bmnr.dev.wunderkraut.nl',
  'root' => '/var/www/bmnr.dev.wunderkraut.nl',
  'remote-host' => 'bmnr.dev.wunderkraut.nl',
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

// ACC site : bmnr.acc.wunderkraut.nl
$aliases['bmnr'] = array(
  'uri' => 'bmnr.acc.wunderkraut.nl',
  'root' => '/var/www/bmnr.acc.wunderkraut.nl',
  'remote-host' => 'bmnr.acc.wunderkraut.nl',
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
