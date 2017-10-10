# Beanstalkd Docker Image

[![](https://images.microbadger.com/badges/image/nevstokes/beanstalkd.svg)](https://microbadger.com/images/nevstokes/beanstalkd "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/commit/nevstokes/beanstalkd.svg)](https://microbadger.com/images/nevstokes/beanstalkd "Get your own commit badge on microbadger.com")

Small [Busybox](https://www.busybox.net)-based, [UPX](https://upx.github.io)-compressed image for the general-purpose work queue Beanstalkd.

See http://kr.github.io/beanstalkd for general info.

Available from [Docker Hub](https://hub.docker.com/r/nevstokes/beanstalkd/)

    $ docker pull nevstokes/beanstalkd

Alternatively, build it yourself

    $ git clone https://github.com/nevstokes/docker-beanstalkd.git
    $ cd docker-beanstalkd
    $ make build


#### Caveat lector
This is the result of general tinkering and experimentation. Hopefully it will be something at least of interest to someone but it's likely unwise to be using this for anything critically important.
