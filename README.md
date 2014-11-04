# Destiny.gg
Vagrant code for the website [www.destiny.gg](http://www.destiny.gg/)

Note: This is not for production, the quality of this repo is very basic...

This VM takes the following IP `192.168.20.20` and the following ports `8181`, `8182`, `6379`, `8002`

These value van be changed in the `Vagrantfile` but changes to the rest of the setup code will need to follow.

# What this does NOT do

You cannot BUILD the website from within the vagrant VM.

You need to install Node and Glue [github.com/destinygg/website](https://github.com/destinygg/website)

This does not build the chat engine.


# How to run?

Download the latest vagrant [www.vagrantup.com](https://www.vagrantup.com/downloads.html)

Clone the [github.com/destinygg/website](https://github.com/destinygg/website)

```shell
git clone git@github.com:destinygg/website.git
```

Clone the vagrant repo into the website folder

```shell
git clone git@github.com:destinygg/vagrant.git ./vagrant
```

Clone this repo into the same folder as the destiny.gg repo.

Copy the `config.local.php` into your destiny.gg/config/ folder (if you do not already have one)
Take note of the ports and such...

Open `cmd` in the destiny.gg folder.

```shell
vagrant up
vagrant ssh
```

Optionally, you want to load the latest content (tweets, youtubes etc..)

```shell
php -f /vagrant/cron/index.php
```

The website should be available at http://localhost:8181/
MySQL at localhost:8002 default database name is `destiny_gg_dev`

You can login using http://localhost:8181/impersonate?userId=1

