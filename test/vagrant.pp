
class { 'redis':
    redis_ver => '2.4.13'
}

redis::service { 'redis_6379':
    port   => '6379'
}
