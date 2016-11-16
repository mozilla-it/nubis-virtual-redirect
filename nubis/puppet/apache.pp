# Define how Apache should be installed and configured
# We should try to recycle the puppetlabs-apache puppet module in the future:
# https://github.com/puppetlabs/puppetlabs-apache
#

include nubis_discovery

nubis::discovery::service {
  $project_name:
    tags     => [ 'apache' ],
    port     => 80,
    check    => '/usr/bin/curl -If http://localhost',
    interval => '30s',
}

class {
    'apache':
      default_mods        => true,
      mpm_module          => 'event',
      default_vhost       => false,
      default_confd_files => false,
      service_enable      => false,
      service_ensure      => false;
    'apache::mod::headers':;
    'apache::mod::rewrite':;
    'apache::mod::expires':;
    'apache::mod::status':;
    'apache::mod::remoteip':
      proxy_ips => [ '127.0.0.1', '10.0.0.0/8' ];
}

apache::vhost { 'redirects':
    port              => 80,
    default_vhost     => true,
    docroot           => '/var/www/html',
    docroot_owner     => 'root',
    docroot_group     => 'root',
    block             => ['scm'],
    setenvif          => 'X_FORWARDED_PROTO https HTTPS=on',
    access_log_format => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    custom_fragment   => 'FileETag None',
    headers           => [
      "set X-Nubis-Version ${project_version}",
      "set X-Nubis-Project ${project_name}",
      "set X-Nubis-Build   ${packer_build_name}",
    ],
    rewrites          => [
      {
        comment      => 'HTTPS redirect',
        rewrite_cond => ['%{HTTP:X-Forwarded-Proto} =http'],
        rewrite_rule => ['. https://%{HTTP:Host}%{REQUEST_URI} [L,R=permanent]'],
      }
    ]
}

apache::vhost { 'whatsdeployed.paas.allizom.org non-ssl':
  servername      => 'whatsdeployed.paas.allizom.org',
  port            => 80,
  docroot         => '/var/www/html',
  redirect_status => 'temp',
  redirect_dest   => 'http://whatsdeployed.io/'
}

apache::vhost { 'kildare.stage.mozilla.com':
  servername      => 'kildare.stage.mozilla.com',
  port            => 80,
  docroot         => '/var/www/html',
  redirect_status => 'permanent',
  redirect_dest   => 'https://www.allizom.org'
}

apache::vhost { 'prs.paas.allizom.org':
  servername      => 'prs.paas.allizom.org',
  port            => 80,
  docroot         => '/var/www/html',
  redirect_status => 'temp',
  redirect_dest   => 'http://prs.mozilla.io/'
}

apache::vhost { 'jugband.paas.allizom.org':
  servername      => 'jugband.paas.allizom.org',
  port            => 80,
  docroot         => '/var/www/html',
  redirect_status => 'temp',
  redirect_dest   => 'http://jugband.herokuapp.com/'
}

apache::vhost { 'socialapi-demo.paas.allizom.org':
  servername      => 'socialapi-demo.paas.allizom.org',
  port            => 80,
  docroot         => '/var/www/html',
  redirect_status => 'temp',
  redirect_dest   => 'https://socialapi-demo.herokuapp.com/'
}

apache::vhost { 'affiliates.mozilla.org':
  servername    => 'affiliates.mozilla.org',
  port          => 80,
  docroot       => '/var/www/html',
  rewrites      => [{
    rewrite_rule => [
      '^/media/uploads/(.*)$ https://s3.amazonaws.com/affiliates-banners/media/uploads/$1 [R=302]',
      '^/referral/(.*)$ https://mozilla.org/firefox/desktop/129 [R=302]',
      '^/(.+)$ https://www.mozilla.org/contribute/friends/ [R=302]',
    ]
  }],
  serveraliases => [
    'affiliates.allizom.org',
  ]
}

apache::vhost { 'join.mozilla.org':
  servername    => 'join.mozilla.org',
  port          => 80,
  docroot       => '/var/www/html',
  rewrites      => [ { rewrite_rule => ['^/.*$ https://donate.mozilla.org/? [R=307]'] } ],
  serveraliases => [
    'join-dev.allizom.org',
    'join.allizom.org',
  ]
}
