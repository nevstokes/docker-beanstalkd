#!/usr/local/bin/php
<?php

include '../vendor/autoload.php';

use Pheanstalk\Pheanstalk as Beanstalkd;

$queue = new Beanstalkd('queue');

$queue
    ->useTube(getenv('beanstalkd_tube'))
    ->put("job payload goes here\n");

echo 'done', PHP_EOL;
