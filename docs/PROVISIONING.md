# Provisioning

We use [Ansible](http://www.ansible.com) to provision both the local dev environment and the production server.

## Dev environment

Download suitable version of [Virtualbox](https://www.virtualbox.org/wiki/Downloads), [Vagrant](https://www.vagrantup.com/) and [Ansible](http://docs.ansible.com/intro_installation.html).

Clone the Bithub repo:

```
git clone git@github.com:bitovi/bithub.git && cd bithub`
```

Install a couple of useful Vagrant plugins:

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

It would be good to restart Vagrant machine after provisioning so that new kernel and vmbox additions gets reloaded, you can do that with `vagrant reload`.

```
ssh -p 2222 bithub@127.0.0.1
```

Also, guest machine should be accessable on IP 192.168.99.99, so you can point your local DNS record for bithub to that address.

You should be able now to run Bithub service within guest `foreman start [web|listener|crawler]`!

Here are the port mappings, check `Vagrantfile` and `ansible/site.yml` for additional info.

| host   | guest   | service        |
| :----- |:------- |:-------------- |
| 8080   | 80      | http           |
| 5433   | 5432    | postgres       |
| 15673  | 15672   | rabbitmq admin |
| 6380   | 6379    | redis

After `foreman start web` on guest, you should be able to access `http://127.0.0.1:8080` on your host machine.


## Server provisioning

Change directory to `ansible`, take a look at `server.yml`, change config if needed and run:

`ansible-playbook server.yml --vault-password-file .vault_pass.txt`

(Optionally run only tagged tasks by passing `-t _tag_name_` param)

`.vault_pass.txt` isn't in version control b/c it contains Ansible vault password in clear text.

Other passwords are stored in group/host vars and can be updated by running `ansible-vault edit group_vars/staging.yml`.

Check http://docs.ansible.com/playbooks_vault.html for more info about using Ansible vaults.
