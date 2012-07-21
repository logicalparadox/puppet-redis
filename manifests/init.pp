class redis($redis_ver = '2.4.14') {

  $redis_tar = "redis-$redis_ver.tar.gz"
  $redis_dl = "http://redis.googlecode.com/files/$redis_tar"

  if defined(Package['curl']) == false {
    package { "curl":
      ensure => "installed"
    }
  }

  if defined(Package['build-essential']) == false {
    package { "build-essential":
      ensure => "installed"
    }
  }

  group { "redis":
    ensure => present
  }

  user { "redis":
      ensure        => present
    , gid           => "redis"
    , managehome    => true
    , home          => '/opt/redis'
    , shell         => '/bin/false'
    , comment       => 'redis-server'
    , require       => Group['redis']
  }

  exec { 'download_redis': 
      command       => "curl -o $redis_tar $redis_dl"
    , cwd           => '/tmp'
    , creates       => "/tmp/${redis_tar}"
    , require       => Package['curl']
    , path          => ['/usr/bin/', '/bin/']
  }
  
  exec { 'extract_redis':
      command       => "tar -xzf $redis_tar"
    , cwd           => "/tmp"
    , creates       => "/tmp/redis-${redis_ver}"
    , require       => Exec['download_redis']
    , path          => ['/usr/bin/', '/bin/']
  }

  file { "/tmp/redis-$redis_ver":
      ensure        => 'directory'
    , require       => Exec['extract_redis']
  }

  file { "/opt/redis": 
      ensure        => 'directory'
    , group         => 'redis'
    , owner         => 'redis'
    , require       => [ User['redis'], Group['redis'] ]
  }

  exec { 'install_redis':
      command       => 'make PREFIX=/opt/redis install'
    , cwd           => "/tmp/redis-${redis_ver}"
    , require       => [  File["/tmp/redis-${redis_ver}"]
                        , File['/opt/redis']
                        , Package['build-essential']
                        , User['redis'] ]
    , timeout       => 0
    , path          => [ '/usr/bin/', '/bin/', '/opt/redis/bin' ]
    , unless        => "which redis-server"
  }

}
