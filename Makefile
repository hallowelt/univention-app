# @copyright Copyright (c) 2017 Arthur Schiwon <blizzz@arthur-schiwon.de>
#
# @author Arthur Schiwon <blizzz@arthur-schiwon.de>
# @author Leonid Verhovskij <Verhovskij@hallowelt.com>
#
# @license GNU AGPL app_version 3 or any later app_version
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either app_version 3 of the
# License, or (at your option) any later app_version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

app_name=univention-app-image
app_version=2.27.2-ucs.2

ucs_version=4.1

docker_repo=bluespice
include config.mk

build_basepath=./files
build_mediawiki_path=mediawiki
build_mediawiki_filename=bluespice_free

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

.PHONY: all
all: docker

.PHONY: update
update:
	rm -f ./files/$(build_mediawiki_filename).zip; composer archive --working-dir $(build_basepath)/$(build_mediawiki_path) --format zip --dir .. --file $(build_mediawiki_filename)
	if [ `systemctl is-active docker` = "inactive" ] ; then systemctl start docker; fi
	docker build -t $(docker_repo)/$(app_name):$(app_version) .

.PHONY: run
run:
	docker run -it \
	-e "DB_HOST=$(db_host)" \
	-e "DB_NAME=$(db_name)" \
	-e "DB_USER=$(db_user)" \
	-e "DB_PASSWORD=$(db_pass)" \
	-v $(mount_var):/var/bluespice \
	-v $(mount_etc):/etc/bluespice \
	$(docker_repo)/$(app_name):$(app_version)

.PHONY: docker
docker:
	mkdir -p $(build_basepath)
	if [ ! -d $(build_basepath)/$(build_mediawiki_path) ] ; then\
		git clone -b REL1_27_univention --depth 1 https://github.com/hallowelt/mediawiki.git $(build_basepath)/$(build_mediawiki_path);\
	else\
		GIT_DIR=$(build_basepath)/$(build_mediawiki_path)/.git GIT_WORK_TREE=$(build_basepath)/$(build_mediawiki_path) git checkout REL1_27_univention;\
		GIT_DIR=$(build_basepath)/$(build_mediawiki_path)/.git GIT_WORK_TREE=$(build_basepath)/$(build_mediawiki_path) git pull;\
	fi
	composer update --working-dir $(build_basepath)/$(build_mediawiki_path)
	rm -f ./files/$(build_mediawiki_filename).zip; composer archive --working-dir $(build_basepath)/$(build_mediawiki_path) --format zip --dir .. --file $(build_mediawiki_filename)
	if [ `systemctl is-active docker` = "inactive" ] ; then systemctl start docker; fi
	docker build -t $(docker_repo)/$(app_name):$(app_version) .

.PHONY: push
push:
	docker login -u $(docker_login) -p $(docker_pwd)
	docker push $(docker_repo)/$(app_name):$(app_version)
