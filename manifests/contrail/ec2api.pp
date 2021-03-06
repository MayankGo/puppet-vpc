###
## Class: rjil::contrail::ec2api
###

class rjil::contrail::ec2api (
  $db_provision = true,
  $keystone_user_create = false,
  $ec2api_public_port  = 443,
){

  if $db_provision {
    include ::mysql::server
    include ::ec2api::db::mysql
    include ::ec2api::db::sync
    Class['::ec2api::db::mysql']->Class['::ec2api::db::sync']
  }

  if $keystone_user_create {
    include ::ec2api::keystone::auth
  }

  rjil::test::check { 'ec2api':
    type    => 'tcp',
    address => '127.0.0.1',
    port    => $ec2api_public_port,
  }

  rjil::jiocloud::consul::service { 'ec2api':
    tags          => ['real'],
    port          => $ec2api_public_port,
  }

  include ::ec2api

  $ec2_api_logs=['ec2api', 'ec2-api']

  rjil::jiocloud::logrotate { $ec2_api_logs:
    logdir => '/var/log',
    su => true,
    su_owner => 'root',
  }

}



