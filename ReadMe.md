# Docker-Compose Project with PHP Composer support
Foundation for a php project with composer support and SSL encryption.
E. g. useful for Symfony or Zend applications.


## Composer usage
The `composer.sh` script in the project root is a wrapper for running composer within the `/www` subdirectory.
Simply call the script with any flags/parameters you would give the usual composer command and they will be handed over.

E. g. to show the current used composer version, append the `--version` flag.
```bash
./bin/composer.sh --version
```


## Initialize new skeletons for popular frameworks
Create a new skeleton for a **Symfony** application:
```bash
./bin/composer.sh create-project symfony/skeleton ./
```

Create a new skeleton for a **Zend** application:
```bash
./bin/composer.sh create-project --stability="dev" zendframework/skeleton-application ./
```
If you want to enable the developer toolbar while in *dev*-mode, make sure to answer with *y* to the questions
"*Do you want a minimal install (no optional packages)?*" and "*Would you like to install the developer toolbar?*".
Then choose to inject the *ZendDeveloperTools* into the file `config/development.config.php.dist` to keep it disabled later in production.
Most other optional enabled modules should be injected into `config/modules.config.php`, so that they are available in both environments.

Create a new skeleton for a **Zend Expressive** (minimalist *PSR-7* middleware) application:
```bash
./bin/composer.sh create-project zendframework/zend-expressive-skeleton ./
```
For further information see [Zend Expressive](https://docs.zendframework.com/zend-expressive/) in official Zend documentation.


## SSL
Depending on whether you want to use SSL encryption, it's necessary to put the certificate and matching private key in the proper places.

### Activate SSL
In order to have an active encryption, copy your certificate file into the path `/conf/ssl/certs/nginx.crt`.
The private key file should be copied to `/conf/ssl/private/nginx.key`.

In case the filenames shouldn't be changed to nginx.*ext* or the file extensions is something else (e. g. *.pem*), it's needed to adjust the paths following paths in the `/conf/nginx.conf`:
```
    ssl_certificate     /etc/ssl/certs/nginx.crt;
    ssl_certificate_key /etc/ssl/private/nginx.key;
```

### Disable SSL / Usage behind a reverse proxy
Disabling SSL can be done by removing the first server block in `/conf/conf.d/vhost.conf` and changing the listen directives in the second one.
```
    listen        443 ssl http2 default_server;
    listen   [::]:443 ssl http2 default_server ipv6only=on;
```
… will be replaced by …
```
    listen      80 default_server;
    listen [::]:80 default_server ipv6only=on;
```

Consider also to disable SSL encryption if you use the application behind a reverse proxy and let the proxy handle it.


## Disable IPv6
Simply remove the lines beginning with `listen [::]:…` in the `/conf/conf.d/vhost.conf` file.



## Change MySQL passwords and database name
There are some *MYSQL_*… environment variables to provide an initial database name, root password and username/password.
You could provide them in the `.env` file in the project root, they will be handed over to the MariaDB container.
For further information (available variables, alternative secrets file) see [Environment Variables / Docker Secrets](https://hub.docker.com/_/mariadb/) sections in the official MariaDB documentation on DockerHub.

## Initialize database with preset values
It's possible to put some *.sql* scripts into the `/conf/initdb.d/` directory.
This way initial database structures or existing dumps can be loaded.
For further information (file extensions, execution order) see [Initializing a fresh instance](https://hub.docker.com/_/mariadb/) section in the official MariaDB documentation on DockerHub.


## Install and update modules
Run the `composer.sh` wrapper script with the `update` parameter to update your modules and dependencies to the highest allowed version according to the semver definitions in `/www/composer.json`.
```bash
./bin/composer.sh update
```
This will ignore the exact specified versions in `/www/composer.lock` and update them afterwards with the new installed versions.

Run the `composer.sh` wrapper script with the `install` parameter to install your modules and dependencies with the exact version given in `/www/composer.lock`.
```bash
./bin/composer.sh install
```
If there isn't already an `/www/composer.lock`, it will act like an *update* and install the highest allowed version (within the semver definitions in `/www/composer.json`) and create a *.lock* file afterwards.

Clear the composer cache.
```bash
./bin/composer.sh clear-cache
```


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
But it can be useful for cleaning the workspace, if you want to reset some test data and recreate your structure with SQL imports or Doctrine.


## Install PHP extensions
The *mysqli* and *pdo_mysql* extensions are already installed.
If you need some more (e. g. a module requires them), you can add them in the `/php-fpm/Dockerfile` and rebuild the *php* container wiht following command:
```bash
docker-compose build php
```
For further information see [How to install more PHP extensions](https://hub.docker.com/_/php/) and following sections in the official PHP documentation on DockerHub.


## Log files
An `access.log` and `error.log` can be found in the `/logs/` subfolder after a successfully start of the application (and some requests).


## Useful commands

### Open a shell directly in a running container.
Open a shell in php or nginx container.
```bash
docker-compose exec php /bin/ash
docker-compose exec www /bin/ash
```
Replace *php* with *www* and vice versa to open a shell in the php or nginx container.

Open a shell in the MariaDB container.
```bash
docker-compose exec db /bin/bash
```


## Use Symfony console commands
The `console-sf.sh` wrapper script allows to execute symfony commands as if you would directly call them with `php bin/console …` (see also [How to Use the Console](https://symfony.com/doc/3.4/console/usage.html)).

### Show Symfony version and environment.
```bash
./bin/console-sf.sh --version
```

### Example to clear the development or production environment caches.
```bash
./bin/console-sf.sh cache:clear --no-warmup --env=dev
./bin/console-sf.sh cache:clear --no-warmup --env=prod
```

### Show a list of all routes
```bash
./bin/console-sf.sh debug:router
```

### Install Doctrine ORM and update database
Install *Doctrine ORM* in Symfony.
```bash
./bin/composer.sh require doctrine maker
```
Follow the given instructions and modify the shown configuration files to connect to your database.
The default hostname of the server is `db` (same as service-name defined in `/docker-compose.yml`).
Username, password and name of the database should match the *MYSQL_*… environment variables in the `/.env` file.

List available doctrine commands (e. g. create entities, update schema, create migrations).
```bash
./bin/console-sf.sh list doctrine
```
Example to create/update/validate database schema.
```bash
./bin/console-sf.sh doctrine:schema:create
./bin/console-sf.sh doctrine:schema:update --force
./bin/console-sf.sh doctrine:schema:update --dump-sql
./bin/console-sf.sh doctrine:schema:validate
```

For further information see [Databases and the Doctrine ORM](https://symfony.com/doc/current/doctrine.html) in official Symfony documentation.


## Zend

### Install Doctrine ORM and update database
Install *Doctrine ORM* in Zend.
```bash
./bin/composer.sh require doctrine/doctrine-orm-module
```
Choose the `config/modules.config.php` as injected config file for the new modules.

It's necessary to provide at least a small and rudimentary doctrine configuration file, before you can use doctrine commands on your database.
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
                    'url' => 'mysql://user:password@db/framework',
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
The hostname of the server connection url is again `db` and username, password and name of the database should match the *MYSQL_*… environment variables in the `/.env` file,
same as in the *Doctrine ORM* section in Symfony.

List available doctrine commands (e. g. create entities, update and validate schema).
```bash
./bin/doctrine-zf.sh list
```

Show basic information about all mapped entities.
```bash
./bin/doctrine-zf.sh orm:info
```

Example to create/update/validate database schema.
```bash
./bin/doctrine-zf.sh orm:schema-tool:create
./bin/doctrine-zf.sh orm:schema-tool:update --force
./bin/doctrine-zf.sh orm:schema-tool:update --dump-sql
./bin/doctrine-zf.sh orm:validate-schema
```


## Execute an arbitrary command in php container
The `command.sh` wrapper script allows to execute any commands inside the php container in docker.

Call the Symfony console and bypass the `console-sf.sh` wrapper.
```bash
./bin/command.sh ./bin/console --version
./bin/command.sh ./bin/console list
./bin/command.sh ./bin/console list doctrine
```

Call the Doctrine ORM module directly and bypass the `doctrine-zf.sh` wrapper.
```bash
./bin/command.sh ./vendor/bin/doctrine-module list
./bin/command.sh ./vendor/bin/doctrine-module orm:schema-tool:update --dump-sql
```


## Notes

- The `/conf/conf.d/vhost.conf` shares some configuration lines which can also be found in the official symfony documentation.
  Initializing and running a new Zend skeleton as described above was successful too.
  Though you should keep in mind some additions/adaptions may be needed if you choose another framework or add some new modules.
- You probably want to remove the `.env` file after initializing your database.
  At least it's advisable to never commit the altered `.env` file with login credentials for an application in production,
  so delete it from the cloned repository after you are done with this example and before officially working on it.
