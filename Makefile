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
app_version=3.0.0-alpha.ucs.1

ucs_version=4.3

docker_repo=bluespice
docker_login=`cat ~/.docker-account-user`
docker_pwd=`cat ~/.docker-account-pwd`

include config.mk

univention_build_basepath=/media/build/univention
univention_build_mediawiki_path=/mediawiki

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
#current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
current_dir := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: all
all: docker

.PHONY: run
run:
	docker run -it \
	-e "DB_HOST=$(db_host)" \
	-e "DB_NAME=$(db_name)" \
	-e "DB_USER=$(db_user)" \
	-e "DB_PASSWORD=$(db_pass)" \
	-v $(mount_var):/var/bluespice \
	-v $(mount_etc):/etc/bluespice \
	-p 80:80 -p 443:443 \
	--cap-add=SYS_PTRACE \
	-t \
$(docker_repo)/$(app_name):$(app_version)

.PHONY: docker
docker:
#	mkdir -p $(univention_build_basepath)
#	if [ ! -d $(univention_build_basepath)/$(univention_build_mediawiki_path) ] ; then\
#		git clone -b master_univention --depth 1 https://github.com/hallowelt/mediawiki.git $(univention_build_basepath)/$(univention_build_mediawiki_path);\
#	else\
#		GIT_DIR=$(univention_build_basepath)/$(univention_build_mediawiki_path)/.git GIT_WORK_TREE=$(univention_build_basepath)/$(univention_build_mediawiki_path) git pull;\
#	fi
#	composer update --working-dir $(univention_build_basepath)/$(univention_build_mediawiki_path)
#	composer archive --working-dir $(univention_build_basepath)/$(univention_build_mediawiki_path) --format zip --dir $(current_dir)codebase --file bluespice
#	if [ `systemctl is-active docker` = "inactive" ] ; then systemctl start docker; fi
	docker build -t $(docker_repo)/univention-app-image:$(app_version) .
#	docker login -u $(docker_login) -p $(docker_pwd)
#	docker push $(docker_repo)/univention-app-image:$(app_version)

.PHONY: push
push:
	docker login -u $(docker_login) -p $(docker_pwd)
	docker push $(docker_repo)/$(app_name):$(app_version)