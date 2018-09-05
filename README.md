Master branch: [![Build Status](https://travis-ci.org/limepepper/ansible-role-wordpress.svg?branch=master)](https://travis-ci.org/limepepper/ansible-role-wordpress)

Wordpress
=========

This role installs and configures the latest version of wordpress on a linux
host and configures apache and mysql to support that site.

It is tested against the main distro versions, i.e. CentOS, Debian, Ubuntu,
and Fedora. Results of integration tests are available `here`.

Optional features include:

- configure SSL
- Update wordpress core
- update plugins, themes, translations
- multisite

The role has been tested against at least the following distribution versions.

- ubuntu 16.04
- ubuntu 17.10
- centos 7
- debian 8
- debian 9
- fedora 28

## Requirements & Dependencies
- Ansible version >= 2.5

## Installation

Minimal use of this role assumes that apache and mysql are already installed
and available. Therefore you can just install the `wordpress` role like so

### Note:
for this to work. The user on the remote side (usually root) must have cli
permissions for the local mysql installation, or mysql user/host/password must
be provided in `vars`.

```
$ ansible-galaxy install limepepper.wordpress
```


If the server is completely fresh, with nothing installed, then you will need
to install the `apache` and `mysql` roles as well:

```
$ ansible-galaxy install \
      limepepper.apache \
      limepepper.mysql \
      limepepper.wordpress
```

## Minimal Configuration

The installation details are passed to the role as a yaml dict object named
`wp_site`. See advanced configuration in the wiki for configuring multiple sites.

A basic playbook looks like this.
~~~ ansible
- hosts: all
  become: yes

  tasks:
  - import_role:
      name: limepepper.wordpress
    vars:
      wp_site:
        - url: http://mywordpressblog.com
          mysql_password: xxxxxxxx
~~~

This will cause the following actions:

- install wordpress into `/var/www/mywordpressblog.com`
- create a mysql database called `wp_mywordpressblog_com`
- create mysql user with a random strong password
- configure an apache virtualhost for http://mywordpressblog.com
- configure wp-config.php appropriately
- initialize salts and hashes for improved security


## Full Configuration of apache, mysql and wordpress

A basic playbook that configures the `AMP` stack looks like this.
~~~~ ansible
- hosts: all
  become: yes

  tasks:
  - import_role:
      name: limepepper.mysql

  - import_role:
      name: limepepper.apache

  - import_role:
      name: limepepper.wordpress
    vars:
      wp_site:
        - url: http://mywordpressblog.com
~~~~




Role Variables
--------------

Configuration is provided by either a yaml dictionary object named `wp_site`,
or as a list of dict objects named `wp_sites`. At least one of those values is
required for anything useful to happen.

A simple example of vars to create a single site, with the theme `twentysixteen`
and the `disable-comments` plugin

~~~~ ansible
vars:
  wp_site:
    home: http://mywordpressblog.com
    theme: twentysixteen
    plugins:
      - disable-comments
~~~~

Or you can create several separate wordpress installation in one go;

~~~~
vars:
  wp_sites:
    - home: http://mywordpressblog.com
      aliases: www.mywordpressblog.com
      theme: twentyseventeen
    - home: http://myotherwordpressblog.com
      aliases: www.myotherwordpressblog.com
      theme: twentysixteen
      plugins:
      - disable-comments
      - recaptcha-in-wp-comments-form

~~~~

which will result in 2 installations, at;

``` bash
/var/www/mywordpressblog.com
/var/www/myotherwordpressblog.com
```

The role can also be used to manage admin users, editors and subscribers/
```
vars:
  wp_site:
    home: http://mywordpressblog.com
    theme: twentysixteen
    plugins:
      - disable-comments
    admins:
      - name: supervisor
        password: my_complex_password
        email: supervisor@example.com
    users:
      - name: editor_user
        email: editor_user@example.com
```

In the example above, the user `editor_user` would be created, and it's password
stored in
` ~/.local/share/ansible/limepepper.wordpress/mywordpressblog.com/editor_user`
on the workstation running ansible, under the user home directory of the user
running ansible.

The issue with the configuration above, is that ansible will reset the users
passwords on every run, which may not be desired, if you want the user to be able
to change their own password. In that case, it's possible to set an initial
password when the user is created, but then the password is left untouched;

```
vars:
  wp_site:
    home: http://mywordpressblog.com
    admins:
      - name: supervisor
        initial_password: changeme_password
        email: supervisor@example.com
```

## Important Settings

### `home` variable

The `home` variables is in the form of a URL, and the prefix `http://` or
`https://` is required. This corresponds to the wordpress options [WP_HOME](https://pressable.com/blog/2015/10/08/define-wp_siteurl-and-wp_home-to-optimize-wp-config/)
and is used for [WP_SITEURL](https://pressable.com/blog/2015/10/08/define-wp_siteurl-and-wp_home-to-optimize-wp-config/)
 unless that value is also provided.

``` ansible
vars:
  wp_site:
    home: http://mywordpressblog.com
```

The value is the value that you would type into a browser

### `install_path` variable

This var is used to override the wordpress installation directory.

``` ansible
vars:
  wp_site:
    home: http://mywordpressblog.com
    install_path: /var/lib/wordpress/mywordpressblog
```

will install wordpress into `/var/lib/wordpress/mywordpressblog` and configure
apache to point at that directory.

## Optional Settings

### plugins

If you provide a list of plugins, the role will install and activate those plugins
into the wordpress installation. It uses the default https://wordpress.org/plugins/
repository to obtain the plugin for download.

~~~~
  wp_sites:
    - site: www.mywordpressblog.somedomain.com
      plugins:
      - recaptcha-in-wp-comments-form
      - woocommerce
~~~~

* Plugins may require additional configuration in `wp-admin/settings` post-installation

### theme

If you provide a theme, the role will install and activate that theme
into the wordpress installation. It uses the default https://wordpress.org/themes/
repository to obtain the theme for download.

~~~~
  wp_sites:
    - site: www.mywordpressblog.somedomain.com
      theme: twentyseventeen
~~~~

* A theme may require additional configuration in `wp-admin/settings` post-installation


### Using pre-installed mysql or apache/nginx

(currently not implemented)

You can suppress any installation and configuration of the apache/nginx or mysql
service by setting `option_webserver: no` and/or `option_mysql: no`


Dependencies
------------

## Ansible Version Requirements

`ansible version >= 2.4`

This role uses
[import_role](https://docs.ansible.com/ansible/2.4/import_role_module.html) and
[import_tasks](https://docs.ansible.com/ansible/2.4/import_tasks_module.html)
instead of the deprecated
[import](http://docs.ansible.com/ansible/latest/include_module.html) module, and
so depends on ansible version `>= 2.4` on the workstation.

## Role Requirements

This role attempts to install and configure apache/nginx and mysql using the following
roles;

* [limepepper.apache](https://github.com/limepepper/ansible-role-apache)
* [limepepper.mysql](https://github.com/limepepper/ansible-role-mysql)

If a webserver or mysql is already installed, those dependencies can be supressed

In addition, this role can install an SSL cert using letsencrypt, if that option
is selected, the letsencrypt role is required

* [limepepper.letsencrypt](https://github.com/limepepper/ansible-role-letsencrypt)



License
-------

BSD

Author Information
------------------

Tom Hodder (tom at limepepper dot co dot uk)

