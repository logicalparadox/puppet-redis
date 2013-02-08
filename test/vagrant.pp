
class { 'redis':
    redis_ver => '2.6.9'
}

redis::service { 'redis_6379':
    port   => '6379'
}
