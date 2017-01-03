# Define how Apache should be installed and configured
# We should try to recycle the puppetlabs-apache puppet module in the future:
# https://github.com/puppetlabs/puppetlabs-apache
#

class { 'nubis_apache':
}

file { '/var/www/html/index.html':
  ensure => present,
  source => 'puppet:///nubis/files/index.html'
}

apache::vhost { 'redirects':
    port               => 80,
    default_vhost      => true,
    docroot            => '/var/www/html',
    docroot_owner      => 'root',
    docroot_group      => 'root',
    block              => ['scm'],
    setenvif           => [
      'X_FORWARDED_PROTO https HTTPS=on',
      'Remote_Addr 127\.0\.0\.1 internal',
      'Remote_Addr ^10\. internal',
    ],
    access_log_env_var => '!internal',
    access_log_format  => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    custom_fragment    => "
# Clustered without coordination
FileETag None
",
    headers            => [
      "set X-Nubis-Version ${project_version}",
      "set X-Nubis-Project ${project_name}",
      "set X-Nubis-Build   ${packer_build_name}",
    ],
    rewrites           => [
      {
        comment      => 'HTTPS redirect',
        rewrite_cond => ['%{HTTP:X-Forwarded-Proto} =http'],
        rewrite_rule => ['. https://%{HTTP:Host}%{REQUEST_URI} [L,R=permanent]'],
      }
    ]
}

# bug 1220879
apache::vhost { 'whatsdeployed.paas.allizom.org':
  servername        => 'whatsdeployed.paas.allizom.org',
  port              => 80,
  redirect_status   => 'temp',
  redirect_dest     => 'http://whatsdeployed.io/',
  access_log_format => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{X-Forwarded-Proto}i\"',
  manage_docroot    => false,
  docroot           => false
}

# bug 1220879
apache::vhost { 'prs.paas.allizom.org':
  servername        => 'prs.paas.allizom.org',
  port              => 80,
  redirect_status   => 'temp',
  redirect_dest     => 'http://prs.mozilla.io/',
  access_log_format => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{X-Forwarded-Proto}i\"',
  manage_docroot    => false,
  docroot           => false
}

# bug 1232976
apache::vhost { 'affiliates.allizom.org':
  servername        => 'affiliates.allizom.org',
  port              => 80,
  access_log_format => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{X-Forwarded-Proto}i\"',
  rewrites          => [{
    rewrite_rule    => [
      '^/media/uploads/(.*)$ https://s3.amazonaws.com/affiliates-banners/media/uploads/$1 [R=302]',
      '^/referral/(.*)$ https://mozilla.org/firefox/desktop/129 [R=302]',
      '^/(.*)$ https://www.mozilla.org/contribute/friends/ [R=302]',
    ]
  }],
  manage_docroot    => false,
  docroot           => false,
  headers           => 'always set Cache-Control "max-age=3600"',
}

#bug 1263033
apache::vhost { 'join.allizom.org':
  servername        => 'join.allizom.org',
  port              => 80,
  access_log_format => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{X-Forwarded-Proto}i\"',
  rewrites          => [ { rewrite_rule => ['^/.*$ https://donate.mozilla.org/? [R=307]'] } ],
  serveraliases     => [
    'join-dev.allizom.org',
  ],
  manage_docroot    => false,
  docroot           => false
}

# bug 1323809
apache::vhost { 'status.mozilla.org':
  servername     => 'status.mozilla.org',
  port           => 80,
  rewrites       => [ { rewrite_rule => ['^/.*$ http://hardhat.mozilla.net/en-US/outages.html [R=307]'] } ],
  manage_docroot => false,
  docroot        => false
}
