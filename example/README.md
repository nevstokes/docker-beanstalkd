# Example usage

This is a very simple demonstration of Beanstalkd interaction using a pair of PHP FPM containers to generate and consume messages.

Firstly, set up and create the containers:

    $ make run

Watch the output of the consuming container:

    $ docker-compose logs -f consumer

In another terminal window, run the generation script to put a message on the queue and watch it appear — along with a timestamp — in the log output of the `consumer` container:

    $ docker-compose exec producer ./generate.php

Once you're suitable entertained, `^C` to stop watching the logs and then tear everything down with:

    $ make cleanup
