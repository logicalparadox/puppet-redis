define redis::service(
    $port = '6379'
  , $config_bind = '127.0.0.1'
  , $config_loglevel = 'notice'
  , $config_timeout = '300'
  , $ensure = 'running'
) { 

  file { 'redis_config': 
      ensure    => file
    , path      => "/opt/redis/redis_${port}.conf"
    , content   => template("${module_name}/redis.conf.erb")
    , require   => Class['redis']
  }

  file { 'redis_logfile':
      ensure    => file
    , path      => "/var/log/redis-${port}.log"
    , require   => Class['redis']
    , group     => 'redis'
    , owner     => 'redis'
  }

  file { 'redis_upstart': 
      ensure    => file
    , path      => "/etc/init/redis-server-${port}.conf"
    , content   => template("${module_name}/redis.upstart.erb")
    , require   => Class['redis']
  }

  file { "/etc/init.d/redis-server-${port}": 
      ensure    => link
    , target    => "/lib/init/upstart-job"
    , require   => File['redis_upstart']
  }

  service { "redis-server-${port}":
      ensure    => $ensure
    , provider  => 'upstart'
    , require   => [  Class['redis']
                    , File['redis_upstart']
                    , File["/etc/init.d/redis-server-${port}"]
                    , File['redis_logfile'] ]
    , subscribe => File["/etc/init.d/redis-server-${port}"]
  }

}
