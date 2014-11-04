<?php return array (

  'chat' => array (
    'host'    => 'www.destiny.gg',
    //'port'  => 9997
  ),

  'allowImpersonation'  => true,

  'cdn' => array (
    'domain'      => 'localhost',
    'port'        => '8182'
  ),

  'db' => array (
    'dbname'      => 'destiny_gg_dev',
    'user'        => 'root',
    'password'    => '',
    'host'        => 'localhost',
    'port'        => '8002'
  ),

  'oauth' => array(
    'callback'            => 'http://localhost:8181/auth/%s',
    'providers' => array(
      'google' => array (
        'clientId'        => '',
        'clientSecret'    => ''
      ),
      'twitch' => array (
        'clientId'        => '',
        'clientSecret'    => ''
      ),
      'reddit' => array (
        'clientId'        => '',
        'clientSecret'    => ''
      ),
      'twitter' => array (
        'clientId'        => '',
        'clientSecret'    => '',
        'token'           => '',
        'secret'          => ''
      )
    )
  ),

  'calendar'            => '',
  'twitter' => array (
    'user'              => 'Steven_Bonnell',
    'consumer_key'      => '',
    'consumer_secret'   => '' 
  ),

  'twitch' => array (
    'user'              => 'destiny',
    'client_id'         => '',
    'client_secret'     => '',
    'broadcaster' => array (
        'user'          => 'destiny'
    ) 
  ),

  'paypal' => array (
    'support_email'     => 'steven.bonnell.ii@gmail.com',
    'email'             => 'steven.bonnell.ii@gmail.com',
    'name'              => 'Steven Bonnell II',
    'api' => array (
      'endpoint'       => 'https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&token=',
      'ipn'            => 'http://localhost:8181/ipn'
    )
  ),

  'youtube' => array (
    'apikey'          => '',
    'playlistId'      => '',
    'user'            => 'Destiny'
  ),

  'analytics' => array (
    'account'         => '',
    'domainName'      => ''
  ),

  'googleads' => array (
    '300x250' => array (
      'google_ad_client' => '',
      'google_ad_slot'   => '' 
    ) 
  ),

  'lastfm' => array (
    'apikey'        => '',
    'user'          => '' 
  ),

  'commerce' => array (
    'receiver_email'    => ''
  )
);