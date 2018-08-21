
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
~~~~ ansible
- hosts: all
  become: yes

  tasks:
  - import_role:
      name: limepepper.wordpress
    vars:
      wp_site:
        - home: http://mywordpressblog.com
~~~~

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
        - home: http://mywordpressblog.com
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


      admins:
        - name: supervisor
          password: my_complex_password
          email: supervisor@example.com

## Important Settings

### `home` and/or `domain` variables

``` ansible
vars:
  wp_site:
    - home: http://mywordpressblog.com
```

The `home` variables is in the form of a URL, and the prefix `http://` or
`https://` is required. This corresponds to the wordpress options [WP_HOME](https://pressable.com/blog/2015/10/08/define-wp_siteurl-and-wp_home-to-optimize-wp-config/)
and is used for [WP_SITEURL](https://pressable.com/blog/2015/10/08/define-wp_siteurl-and-wp_home-to-optimize-wp-config/)
 unless that value is also provided.

The value is the value that you would type into a browser, e.g. if you set site like
`"home: http://mywordpressblog.com"` it would create configuration for http://mywordpressblog.com



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

### Users

#### Creating admin users

If you provide an array of `admins` in a site, it will create those users for that.
instance The default WP installation creates a default `supervisor` user, the
`admins` key can be used to set the password for that user. Otherwise the `supervisor` user will have a complex password generated and stored in
`/var/cache/ansible/store/wp_supervisor_pass`

~~~~
  wp_sites:
    - site: mywordpressblog.example.com
      admins:
        - name: supervisor
          password: my_complex_password
          email: supervisor@example.com
        - name: other_admin
          initial_password: my_complex_password2
          email: other_admin@example.com
~~~~

#### Creating editor users

Similarly to the admins key, the `users` key can be used to create user who can
create and edit their own blog posts.

~~~~
  wp_sites:
    - site: mywordpressblog.example.com
      users:
        - name: editor_user
          email: editor_user@example.com
~~~~

#### Setting initial passwords

You can choose to set an `initial_password` which will be assigned to the user
when it's created. However if the user exists, no changes will be made to their
password. In general this is most appropriate if you have users who will interact
with the site using the `wp-admin` site tools, but wish to set their password
to something specific to start out.

~~~~
  wp_sites:
    - site: mywordpressblog.example.com
      admins:
        - name: supervisor
          initial_password: changeme_password
          email: supervisor@example.com
~~~~

#### Forcing passwords

If a user is created with a `password` key. The password will be reset to that
value whenever the role is applied to the host. In general this is appropriate
if the site is completely managed by ansible.

~~~~
  wp_sites:
    - site: mywordpressblog.example.com
      admins:
        - name: supervisor
          password: changeme_password
          email: supervisor@example.com
~~~~

### Enabling test/dev settings

#### Using `enviro`

For testing purposes, the role takes a `enviro` option which can be set which
enables various options for testing, debugging and development.

~~~~
  wp_sites:
    - site: mywordpressblog.example.com
    - options:
      - enviro: dev
~~~~

##### site aliases

The `"enviro: dev"` will create additional apache/nginx site aliases with the suffix
`.testbox` which it will also add to `/etc/hosts` to facilitate inspect testing
of the installation locally. For example the above site would have an alias
http://mywordpressblog.example.com.testbox which would resolve locally on that host.

##### letsencryt testing/stage server

The `"enviro: dev"` will set the letsencrpt option to use the testing/staging
options and generate a self signed certificate.




### Using pre-installed mysql or apache/nginx

(currently not implemented)

You can suppress any installation and configuration of the apache/nginx or mysql
service by setting `option_webserver: no` and/or `option_mysql: no`

#### Using nginx

Switch to nginx instead of apache. (note: this is not very well tested...)

~~~~
  wp_sites:
    - site: mywordpressblog.somedomain.com
    - options:
        webserver: nginx
~~~~

#### `webserver: no`

In this case, the role will attempt to install into an existing `/var/www/` directory
on the host, and setup a config file for that service to use

~~~~
  wp_sites:
    - site: mywordpressblog.somedomain.com
    - options:
        webserver: no
~~~~

#### `mysql: no`

The role assumes that root can manage the database without a password


#### site Aliases (`aliases`)

If you provide a list of aliases, the role will configure those values as
ServerAliases in apache

~~~~
  wp_sites:
    - site: mywordpressblog.somedomain.com
      aliases:
        - www.mywordpressblog.somedomain.com
        - testsite.mywordpressblog.somedomain.com
~~~~




Example Playbook
----------------

## Example 1 ([test report #1](http://limepepper.co.uk/reports))

This example will create 2 sites,
- http://mywordpressblog.somedomain.com
- http://anotherwordpressblog.otherdomain.org

with some options set. There is a test case for this example at
[test report #1](http://limepepper.co.uk/reports)

~~~~
  - hosts: target_server

  - name: Install one or more WordPress sites
    import_role:
      name: limepepper.wordpress
    wp_sites:
      - site: mywordpressblog.somedomain.com
        aliases:
          - www.mywordpressblog.somedomain.com
        theme: twentyseventeen
        plugins:
          - disable-comments
      - { site: anotherwordpressblog.otherdomain.org, theme: just-pink }
~~~~

## Example 2 ([test report #1](http://limepepper.co.uk/reports/example2))

This example will create 2 sites,
- http://mywordpressblog.somedomain.com
- http://anotherwordpressblog.otherdomain.org

with some options set. There is a test case for this example at
[test report #1](http://limepepper.co.uk/reports)

~~~~
  - hosts: target_server

  - name: Install one or more WordPress sites
    import_role:
      name: limepepper.wordpress
    wp_sites:
      - site: mywordpressblog.somedomain.com
        aliases:
          - www.mywordpressblog.somedomain.com
        theme: twentyseventeen
        plugins:
          - disable-comments
      - { site: anotherwordpressblog.otherdomain.org, theme: just-pink }
~~~~


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



#### Notes
The var `site` is used to create a NameVirtualHost in the webserver for wordpress, and if
you enable letsencrypt it will be used for the common name of the certificate.
By default this will create the installation at `/var/www/#{site}`
and log files at `/var/log/apache/#{site}-access.log` or
`/var/log/httpd/#{site}-access.log` depending on whether the distro
is a RedHat or Debian flavor.

The `site` var should be unique in the list of sites
provided to `wp_sites` array to prevent over writing and if you want to configure
letsencypt ssl, it should already resolve to the correct IP. (Otherwise
letsencrypt validation will fail)

Obviously, DNS for `site` will need to point to your webserver if you want to be able to
access the server remotely.


License
-------

BSD

Author Information
------------------

Tom Hodder (tom at limepepper dot co dot uk)

