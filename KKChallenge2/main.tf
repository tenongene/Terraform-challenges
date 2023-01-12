terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
} 


# Create a docker image resource
resource "docker_image" "php-httpd-image" {
  name = "php-httpd:challenge"
  build {
    path = "lamp_stack/php_httpd"
    label = {
      challenge : "second"
    }
  }
}

resource "docker_image" "mariadb-image" {
  name = "mariadb:challenge"
  build {
    path = "lamp_stack/custom_db"
    label = {
      challenge : "second"
    }
  }
}

#Create docker containers
resource "docker_container" "php-httpd" {
  name    = "webserver"
  image   = docker_image.php-httpd-image.latest
  hostname = "php-httpd"

  labels {
    label = "challenge"
    value = "second"
  }
  networks_advanced {
    name = "my_network"
  }
  ports {
    internal = 80
    external = 80
  }

  volumes {
    host_path = "/root/code/terraform-challenges/challenge2/lamp_stack/website_content/"
    container_path = "/var/www/html"
  }


  depends_on = [
    docker_image.php-httpd-image
  ]
}

resource "docker_container" "phpmyadmin" {
  name    = "db_dashboard"
  image   = "phpmyadmin/phpmyadmin"
  hostname = "phpmyadmin"
  links = (["${docker_container.mariadb.name}"])

  labels {
    label = "challenge"
    value = "second"
  }

  networks_advanced {
    name = "my_network"
  }
  ports {
    internal = 80
    external = 8081
  }

  depends_on = [
    docker_container.mariadb
  ]
}

resource "docker_container" "mariadb" {
  name    = "db"
  image   = docker_image.mariadb-image.latest
  hostname = "db"

  labels {
    label = "challenge"
    value = "second"
  }
  networks_advanced {
    name = "my_network"
  }
  ports {
    internal = 3306
    external = 3306
  }
  
  volumes {
    volume_name = docker_volume.mariadb_volume.name
    container_path = "/var/lib/mysql"
  }

  env = [ "MYSQL_ROOT_PASSWORD=1234", "MYSQL_DATABASE=simple-website" ]

  depends_on = [
    docker_image.mariadb-image
  ]
}

##create db volume
resource "docker_volume" "mariadb_volume" {
  name = "mariadb-volume"
}

#create private network
resource "docker_network" "private_network" {
  name = "my_network"
  attachable = true
  labels {
    label = "challenge"
    value = "second"
  }
}