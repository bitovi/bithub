BitHub
======

[![Code Climate](https://codeclimate.com/repos/526988e0f3ea00635800b307/badges/f701a19f0db7c8405157/gpa.png)](https://codeclimate.com/repos/526988e0f3ea00635800b307/feed) [![Build Status](https://magnum.travis-ci.com/bitovi/bithub.png?token=7ZMdK1bdsUC7QT7uNoUn&branch=master)](https://magnum.travis-ci.com/bitovi/bithub)

## Development environment setup

The easiest way to setup development environment is to use [Vagrant](https://www.vagrantup.com/) with provided [Ansible](http://ansible.com/) provisioning scripts.

Download suitable version of [Virtualbox](https://www.virtualbox.org/wiki/Downloads), [Vagrant](https://www.vagrantup.com/) and [Ansible](http://docs.ansible.com/intro_installation.html).

Clone Bithub repo:

```
git clone git@github.com:bitovi/bithub.git && cd bithub`
```

Install some useful Vagrant plugins:

```
vagrant plugin install sahara          // used for sandboxing
vagrant plugin install vagrant-vbguest // takes care of correct virtualbox guest additions
```

Fire up Vagrant with:

```
vagrant up
```

This will take some time (~30 mins), it will download Vagrant box (chef/debian-7.4) and run Ansible provisioning which consists of serveral steps:

- updating guest machine an installing some common packages
- installing and configuring services; nginx, postgresq, rabbitmq, redis
- compiling ruby and setting up environment for bithub

After all that is over you should be able to ssh into guest machine, your project directory on host will be mounted under `/vagrant` path on guest.

```
ssh -p 2222 bithub@127.0.0.1
```

You should be able now to run bithub service within guest `foreman start [web|listener|crawler]`!

Here are the port mappings, check `Vagrantfile` and `ansible/site.yml` for additional info.

| host   | guest   | service        |
| :----- |:------- |:-------------- |
| 8080   | 80      | http           |
| 5433   | 5432    | postgres       |
| 15673  | 15672   | rabbitmq admin |
| 6380   | 6379    | redis

After `foreman start web` on guest, you should be able to access `http://127.0.0.1:8080` on your host machine.
