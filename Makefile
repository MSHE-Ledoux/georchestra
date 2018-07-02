# Docker related targets

DOCKER-COMPOSE-BIN=docker-compose

docker-pull-jetty:
	docker pull jetty:9-jre8

docker-build-ldap:
	docker pull dinkel/openldap
	$(DOCKER-COMPOSE-BIN) build ldap

docker-build-database:
	docker pull postgres:10
	$(DOCKER-COMPOSE-BIN) build database

docker-build-gn3: docker-pull-jetty
	cd geonetwork; \
	mvn -DskipTests clean install; \
	cd web; \
	mvn -P docker -DskipTests package docker:build

docker-build-geoserver: docker-pull-jetty
	cd geoserver/; \
	rm -rf geoserver-submodule/data/citewfs-1.1/workspaces/sf/sf/E*; \
	LANG=C mvn clean install -DskipTests; \
	cd webapp; \
	mvn clean install docker:build -Pdocker,colormap,mbtiles,wps-download,app-schema,control-flow,csw,feature-pregeneralized,gdal,importer,inspire,libjpeg-turbo,monitor,pyramid,wps -DskipTests

docker-build-geoserver-geofence: docker-pull-jetty
	cd geoserver; \
	rm -fr geoserver-submodule/data/citewfs-1.1/workspaces/sf/sf/E*; \
	LANG=C mvn clean install -Pgeofence -DskipTests; \
	cd webapp; \
	mvn clean install docker:build -Pdocker,colormap,mbtiles,wps-download,app-schema,control-flow,csw,feature-pregeneralized,gdal,importer,inspire,libjpeg-turbo,monitor,pyramid,wps,geofence -DskipTests

docker-build-console: build-deps docker-pull-jetty
	mvn clean package docker:build -Pdocker -DskipTests --pl console

docker-build-georchestra: build-deps docker-pull-jetty docker-build-database docker-build-ldap docker-build-geoserver docker-build-gn3
	mvn clean package docker:build -Pdocker -DskipTests --pl extractorapp,cas-server-webapp,security-proxy,mapfishapp,header,console,analytics,geowebcache-webapp,atlas

docker-build-dev:
	docker pull debian:stretch
	docker pull tianon/apache2
	$(DOCKER-COMPOSE-BIN) build smtp courier-imap webmail geodata

docker-stop-rm:
	$(DOCKER-COMPOSE-BIN) stop
	$(DOCKER-COMPOSE-BIN) rm -f

docker-clean-volumes:
	$(DOCKER-COMPOSE-BIN) down --volumes --remove-orphans

docker-clean-images:
	$(DOCKER-COMPOSE-BIN) down --rmi 'all' --remove-orphans

docker-clean-all:
	$(DOCKER-COMPOSE-BIN) down --volumes --rmi 'all' --remove-orphans

docker-build: docker-build-dev docker-build-gn3 docker-build-geoserver docker-build-georchestra


# WAR related targets

war-build-geoserver: build-deps
	cd geoserver/geoserver-submodule/src/; \
	mvn clean install -Pcolormap,mbtiles,wps-download,app-schema,control-flow,csw,feature-pregeneralized,gdal,importer,inspire,libjpeg-turbo,monitor,pyramid,wps,css -DskipTests; \
	cd ../../..; \
	mvn clean install -pl geoserver/webapp

war-build-geoserver-geofence: build-deps
	cd geoserver/geoserver-submodule/src/; \
	mvn clean install -Pcolormap,mbtiles,wps-download,app-schema,control-flow,csw,feature-pregeneralized,gdal,importer,inspire,libjpeg-turbo,monitor,pyramid,wps,css,geofence-server -Dserver=geofence-generic -DskipTests; \
	cd ../../..; \
	mvn clean install -pl geoserver/webapp

war-build-gn3:
	mvn clean install -f geonetwork/pom.xml -DskipTests

war-build-georchestra: war-build-gn3 war-build-geoserver
	mvn -Dmaven.test.skip=true clean install


# DEB related targets

deb-build-geoserver: war-build-geoserver
	cd geoserver; \
	mvn clean package deb:package -PdebianPackage --pl webapp

deb-build-geoserver-geofence: war-build-geoserver-geofence
	cd geoserver; \
	mvn clean package deb:package -PdebianPackage,geofence -Dserver=geofence-generic --pl webapp

deb-build-georchestra: war-build-georchestra build-deps deb-build-geoserver
	mvn package deb:package -pl atlas,cas-server-webapp,security-proxy,header,mapfishapp,extractorapp,analytics,geoserver/webapp,console,geonetwork/web,geowebcache-webapp -PdebianPackage -DskipTests

# Base geOrchestra config and common modules
build-deps:
	mvn -Dmaven.test.failure.ignore clean install --non-recursive
	mvn clean install -pl config -Dmaven.javadoc.failOnError=false
	mvn clean install -pl commons,epsg-extension,ogc-server-statistics -Dmaven.javadoc.failOnError=false
	cd config/; \
	mvn -Dserver=tpl install

# all
all: war-build-georchestra deb-build-georchestra docker-build
