# Docker-Compose Project with PHP Composer support
Foundation for a php project with composer support and SSL encryption.
E. g. useful for Symfony or Zend applications.

**Table of contents**
<!-- TOC depthFrom:2 depthTo:4 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Composer usage](#composer-usage)
	- [Composer wrapper script](#composer-wrapper-script)
	- [Install/Update php modules](#installupdate-php-modules)
- [Initialize new skeletons for popular frameworks](#initialize-new-skeletons-for-popular-frameworks)
	- [Symfony 4](#symfony-4)
	- [Zend Framework 3](#zend-framework-3)
	- [Zend Expressive](#zend-expressive)
- [Start and exit the application](#start-and-exit-the-application)
- [Sending Commands](#sending-commands)
	- [Useful docker commands](#useful-docker-commands)
	- [Execute arbitrary commands in PHP container](#execute-arbitrary-commands-in-php-container)
- [PHP extensions](#php-extensions)
- [Nginx Webserver](#nginx-webserver)
	- [Activate SSL](#activate-ssl)
	- [Disable SSL / Behind a reverse proxy](#disable-ssl-behind-a-reverse-proxy)
	- [Disable IPv6](#disable-ipv6)
	- [Log files](#log-files)
- [MariaDB Server (MySQL)](#mariadb-server-mysql)
	- [Change MySQL passwords and database name](#change-mysql-passwords-and-database-name)
	- [Initialize database with preset values](#initialize-database-with-preset-values)
- [Symfony](#symfony)
	- [Symfony console wrapper script](#symfony-console-wrapper-script)
	- [Install Symfony Debug Tools](#install-symfony-debug-tools)
	- [Install Doctrine ORM and update database](#install-doctrine-orm-and-update-database)
- [Zend](#zend)
	- [Install Zend Developer Toolbar](#install-zend-developer-toolbar)
	- [Install Doctrine ORM and update database](#install-doctrine-orm-and-update-database)
	- [Zend doctrine-module wrapper](#zend-doctrine-module-wrapper)
- [Notes](#notes)

<!-- /TOC -->


## Composer usage

### Composer wrapper script
The `composer.sh` script in the project root is a wrapper for running composer within the `/www` subdirectory.
Simply call the script with any flags/parameters you would give the usual composer command and they will be handed over.

E. g. to show the current used composer version, append the `--version` flag.
```bash
./bin/composer.sh --version
```

### Install/Update php modules
Run the `composer.sh` wrapper script with the `update` parameter to update your modules and dependencies to
the highest allowed version according to the [semver](https://semver.org/) definitions in `/www/composer.json`.
```bash
./bin/composer.sh update
```
This will ignore the exact specified versions in `/www/composer.lock` and update them afterwards with the new installed versions.

Run the `composer.sh` wrapper script with the `install` parameter to install your modules and dependencies with
the exact version given in `/www/composer.lock`.
```bash
./bin/composer.sh install
```
If there isn't already an `/www/composer.lock`, it will act like an *update* and install the highest allowed version
(within the [semver](https://semver.org/) definitions in `/www/composer.json`) and create a *.lock* file afterwards.

Clear the composer cache.
```bash
./bin/composer.sh clear-cache
```


## Initialize new skeletons for popular frameworks

### Symfony 4
Create a new skeleton for a **Symfony** application:
```bash
./bin/composer.sh create-project symfony/skeleton ./
```
The skeleton doesn't provide any controllers or routes. After starting the application, you will only see a default page,
showing that the basic framework is running. If you want to enable the *web-profiler toolbar* later, you need at least
one working route.

You may want to download the annotations plugin before, which enables defining routes directly within a controller.
```bash
./bin/composer.sh require annotations
```
Then create a simple controller, located in `/www/src/Controller/IndexController.php`, with an `indexAction` and
main route `"/"`.
```php
<?php
namespace App\Controller;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

class IndexController
{
    /**
     * @Route("/")
     */
    public function indexAction()
    {
        return new Response(
            '<html><body>It works!</body></html>'
        );
    }
}

```
Now you shouldn't see the default page of Symfony anymore, instead there is only a simple text telling you "*It works!*".

### Zend Framework 3
Create a new skeleton for a **Zend** application:
```bash
./bin/composer.sh create-project --stability="dev" zendframework/skeleton-application ./
```
If you want to enable the developer toolbar immediately while in *dev*-mode, make sure to answer with `n`
to the first question "*Do you want a minimal install (no optional packages)?*" and with `y` to the following question
"*Would you like to install the developer toolbar?*".
Then choose to inject the *ZendDeveloperTools* into the file `config/development.config.php.dist`
to keep them disabled later in production.

Most other optional enabled modules should be injected into `config/modules.config.php`,
so that they are available in both environments.

### Zend Expressive
Create a new skeleton for a **Zend Expressive** (minimalist *PSR-7* middleware) application:
```bash
./bin/composer.sh create-project zendframework/zend-expressive-skeleton ./
```
For further information see [Zend Expressive](https://docs.zendframework.com/zend-expressive/)
in official Zend documentation.


## Start and exit the application

To run the application the first time, let docker-compose automatically set up the containers:
```bash
docker-compose up -d --build
```

Starting/stopping already created containers:
```bash
docker-compose stop
docker-compose start
```

Destroy containers and release their resources (e. g. port mappings, volumes):
```bash
# remove only containers
docker-compose down
# remove containers and their stored data
docker-compose down -v
```
**Warning:** Usage of the parameter *-v* removes volumes and therefore stored data within them.
Don't use it, if you want to keep created and filled databases.
But it can be useful for cleaning the workspace, if you want to reset some test data
and recreate your structure with SQL imports or Doctrine.


## Sending Commands
Interacting with containers can be done by using the right `docker` and `docker-compose` commands
as well as using some useful wrapper scripts located in `/bin` subdirectory.

### Useful docker commands

Open a shell directly in a running php or nginx container:
```bash
docker-compose exec php /bin/ash
docker-compose exec www /bin/ash
```
Replace *php* with *www* and vice versa to open a shell in the php or nginx container.

Open a shell in the MariaDB container:
```bash
docker-compose exec db /bin/bash
```

### Execute arbitrary commands in PHP container
The `command.sh` wrapper script allows to execute any commands inside the php container in docker.

E. g. show the installed php version:
```bash
./bin/command.sh php --version
```

Run a composer diagnose  and bypass the `composer.sh` wrapper:
```bash
./bin/command.sh composer diagnose
```

Call the Symfony console and bypass the `console-sf.sh` wrapper:
```bash
./bin/command.sh php ./bin/console --version
./bin/command.sh php ./bin/console list
./bin/command.sh php ./bin/console list doctrine
```

Call the Doctrine ORM module directly and bypass the `doctrine-zf.sh` wrapper:
```bash
./bin/command.sh ./vendor/bin/doctrine-module list
./bin/command.sh ./vendor/bin/doctrine-module orm:schema-tool:update --dump-sql
```


## PHP extensions
Following extensions are already installed:
- mysqli
- pdo-mysql
- zip
- bzip2
- intl
- Xdebug
- OPcache
- APCu

Override the default settings by mounting your own `php.ini` file as `/usr/local/etc/php/php.ini` at runtime.
The configuration for `Xdebug` is located in `/usr/local/etc/php/conf.d/xdebug.ini`.

If you need more extensions (e. g. a module requires them), you could clone this
alpine based PHP7-FPM docker image [on GitHub](https://github.com/florianzier/php-fpm-alpine)
(visit on [Docker Hub](https://hub.docker.com/r/zierf/php/)) or use the
[official php](https://hub.docker.com/_/php/) and build your own docker image.

For further information how to install php extensions, see the "_How to install more PHP extensions_"
and following sections in the official PHP documentation on Docker Hub.


## Nginx Webserver

Depending on whether you want to use SSL encryption, it's necessary to put the certificate and
matching private key in the proper places.
Also Consider to disable SSL encryption if you use the application behind a reverse proxy and let the proxy handle it.

### Activate SSL
In order to have an active encryption, copy your certificate file into the path `/conf/ssl/certs/nginx.crt`.
The private key file should be copied to `/conf/ssl/private/nginx.key`.

In case the filenames shouldn't be changed to nginx.*ext* or the file extensions is something else (e. g. *.pem*),
it's needed to adjust the paths following paths in the `/conf/nginx.conf`:
```
    ssl_certificate     /etc/ssl/certs/nginx.crt;
    ssl_certificate_key /etc/ssl/private/nginx.key;
```

### Disable SSL / Behind a reverse proxy
Disabling SSL can be done by removing the first server block in `/conf/conf.d/vhost.conf`
and changing the listen directives in the second one.
```
    listen        443 ssl http2 default_server;
    listen   [::]:443 ssl http2 default_server ipv6only=on;
```
… will be replaced by …
```
    listen      80 default_server;
    listen [::]:80 default_server ipv6only=on;
```

### Disable IPv6
Simply remove the lines beginning with `listen [::]:…` in the `/conf/conf.d/vhost.conf` file.

### Log files
An `access.log` and `error.log` can be found in the `/logs/` subfolder after
a successfully start of the application (and some requests).


## MariaDB Server (MySQL)

### Change MySQL passwords and database name
There are some *MYSQL_*… environment variables to provide an initial database name, root password and username/password.
You could provide them in the `.env` file in the project root, they will be handed over to the MariaDB container.
For further information (available variables, alternative secrets file) see [Environment Variables / Docker Secrets](https://hub.docker.com/_/mariadb/) sections in the official MariaDB documentation on Docker Hub.

### Initialize database with preset values
It's possible to put some *.sql* scripts into the `/conf/initdb.d/` directory.
This way initial database structures or existing dumps can be loaded.
For further information (file extensions, execution order) see [Initializing a fresh instance](https://hub.docker.com/_/mariadb/)
section in the official MariaDB documentation on Docker Hub.


## Symfony

### Symfony console wrapper script
The `console-sf.sh` wrapper script allows to execute symfony commands as if you would directly call them
with `php bin/console …` (see also [How to Use the Console](https://symfony.com/doc/3.4/console/usage.html)).

Show Symfony version and environment:
```bash
./bin/console-sf.sh --version
```

Example to clear the development or production environment caches:
```bash
./bin/console-sf.sh cache:clear --no-warmup --env=dev
./bin/console-sf.sh cache:clear --no-warmup --env=prod
```

Show a list of all routes:
```bash
./bin/console-sf.sh debug:router
```

### Install Symfony Debug Tools
Before you install the *profiler*, follow the tutorial [Create your First Page in Symfony](https://symfony.com/doc/current/page_creation.html)
and create a controller with an index route if you don't have one already, otherwise you will see an Exception
with the message `No route found for "GET /"` after installation.

Alternatively you can execute the steps in **Symfony 4** section above and create a simple index route.
Afterwards install and activate the *web-profiler toolbar* by installing the *profiler* module:
```bash
./bin/composer.sh require --dev profiler
```
You can then configure the *web-profiler* in the `/www/config/packages/dev/web_profiler.yaml` file
and enable/disable the toolbar any time by setting `web_profiler.toolbar: false`.

### Install Doctrine ORM and update database
Install *Doctrine ORM* in Symfony:
```bash
./bin/composer.sh require doctrine maker
```
Follow the given instructions and modify the shown configuration files to connect to your database.
Adjust your MySQL *server_version* in `/www/config/packages/doctrine.yaml` and
change the `DATABASE_URL` in the file `/www/.env` to something like:
```bash
DATABASE_URL=mysql://user:password@db:3306/database
```
The default hostname of the server is `db` (same as the service-name defined in `/docker-compose.yml`).
Username, password and name of the database should match the *MYSQL_*… environment variables in the `/.env` file
(the one which can be found in project's main folder).

List available doctrine commands (e. g. create entities, update schema, create migrations):
```bash
./bin/console-sf.sh list doctrine
```
Example to create/update/validate database schema:
```bash
./bin/console-sf.sh doctrine:schema:create
./bin/console-sf.sh doctrine:schema:update --force
./bin/console-sf.sh doctrine:schema:update --dump-sql
./bin/console-sf.sh doctrine:schema:validate
```

For further information see [Databases and the Doctrine ORM](https://symfony.com/doc/current/doctrine.html)
in official Symfony documentation.


## Zend

### Install Zend Developer Toolbar
If you enable the developer toolbar with the following command (and after initializing the skeleton),
make sure to choose `config/development.config.php.dist` as file to inject the *ZendDeveloperTools* into,
so they will stay disabled later in production.
```bash
./bin/composer.sh require --dev zendframework/zend-developer-tools
```

### Install Doctrine ORM and update database
Install *Doctrine ORM* in Zend:
```bash
./bin/composer.sh require doctrine/doctrine-orm-module
```
Choose the `config/modules.config.php` as config file for injecting the new modules.

It's necessary to provide at least a small and rudimentary doctrine configuration file, before you can
use doctrine commands on your database.
Create a new file `/www/config/autoload/doctrine.global.php` with following content:
```php
<?php
use ContainerInteropDoctrine\EntityManagerFactory;

return [
    'dependencies' => [
        'factories' => [
            'doctrine.entity_manager.orm_default' => EntityManagerFactory::class,
        ],
    ],

    /**
     * For full configuration options, see
     * https://github.com/DASPRiD/container-interop-doctrine/blob/master/example/full-config.php
     */
    'doctrine' => [
        'connection' => [
            'orm_default' => [
                'params' => [
                    'url' => 'mysql://user:password@db/database',
                ],
            ],
        ],
        'driver' => [
            'orm_default' => [
                'class' => \Doctrine\Common\Persistence\Mapping\Driver\MappingDriverChain::class,
                'drivers' => [
                    //'App\Entity' => 'my_entity',
                ],
            ],
            /*'my_entity' => [
                'class' => \Doctrine\ORM\Mapping\Driver\AnnotationDriver::class,
                'cache' => 'array',
                'paths' => 'src/App/Entity/',
            ],*/
        ],
    ],
];

```
Most configuration lines are taken from the *Stack Overflow* post about [installing doctrine orm module with ZF3 skeleton app](https://stackoverflow.com/a/38210894).
The hostname of the server connection url is again `db` and username, password and name of the database
should match the *MYSQL_*… environment variables in the `/.env` file,
same as in the *Doctrine ORM* section in Symfony.

### Zend doctrine-module wrapper
There is also a wrapper for executing commands with the `doctrine-module` of Zend.

List available doctrine commands (e. g. create entities, update and validate schema):
```bash
./bin/doctrine-zf.sh list
```

Show basic information about all mapped entities:
```bash
./bin/doctrine-zf.sh orm:info
```

Example to create/update/validate database schema:
```bash
./bin/doctrine-zf.sh orm:schema-tool:create
./bin/doctrine-zf.sh orm:schema-tool:update --force
./bin/doctrine-zf.sh orm:schema-tool:update --dump-sql
./bin/doctrine-zf.sh orm:validate-schema
```



## Notes

- The `/conf/conf.d/vhost.conf` shares some configuration lines which can also be found in the official symfony documentation.
  Initializing and running a new Zend skeleton as described above was successful too.
  Though you should keep in mind some additions/adaptions may be needed if you choose another framework or add some new modules.
- You probably want to remove the `.env` file after initializing your database.
  At least it's advisable to never commit the altered `.env` file with login credentials for an application in production,
  so delete it from the cloned repository after you are done with this example and before officially working on it.
