#!/usr/local/bin/php
<?php

include '../vendor/autoload.php';

use Pheanstalk\Pheanstalk as Beanstalkd;

$queue = new Beanstalkd('queue');

$queue
    ->watch(getenv('beanstalkd_tube'))
    ->ignore('default');

while ($queue->getConnection()->isServiceListening()) {
    $job = $queue->reserve();

    echo date('Y-m-d H:i:s'), PHP_EOL;
    echo $job->getData();

    $queue->delete($job);

    sleep(getenv('consumer_pause'));
}
