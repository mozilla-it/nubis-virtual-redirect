file { "/etc/nubis.d/${project_name}":
  ensure  => file,
  owner   => root,
  group   => root,
  mode    => '0755',
  content =>  "#!/bin/bash -l
  # Runs once on instance boot, after all infra services are up and running
  # Start serving it

  service ${::apache::params::service_name} start
  "
}
