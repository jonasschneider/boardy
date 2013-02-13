# Boardy
Boardy is a dashboard that shows pings to hosts.

![](http://puu.sh/21Bwq)

## Installation
Clone this repo, and install dependencies:

    $ git://github.com/jonasschneider/boardy.git
    $ brew install coreutils
    $ bundle install

Set up hosts to watch:

    $ echo "BOARDYHOSTS=google.com,github.com" > .env

Let [foreman](https://github.com/ddollar/foreman) run it:

    $ foreman start

## Contributing
Fork, hack, pullreq. Extensions welcome.

## License
Copyright 2013 Jonas Schneider. Licensed under GPLv3, MIT, Ruby, WTFPL, choose what suits you.
