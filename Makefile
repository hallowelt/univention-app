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

app_name=bluespice
app_version=2.27.2

ucs_version=4.1

docker_repo=bluespice
docker_login=`cat ~/.docker-account-user`
docker_pwd=`cat ~/.docker-account-pwd`

univention_build_basepath=/media/build/univention
univention_build_mediawiki_path=/mediawiki

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

.PHONY: all
all: docker

.PHONY: docker
docker:
	#mkdir -p $univention_build_basepath

	#if [ !-f $univention_build_basepath/$univention_build_mediawiki_path ]; then
	#	git clone -b REL1_27_univention --depth 1 https://github.com/hallowelt/mediawiki.git $univention_build_basepath/$univention_build_mediawiki_path
	#else
	#	GIT_DIR=$univention_build_basepath/$univention_build_mediawiki_path/.git GIT_WORK_TREE=$univention_build_basepath/$univention_build_mediawiki_path git pull
	#fi

	#composer update --working-dir $univention_build_basepath/$univention_build_mediawiki_path
	#composer archive --working-dir $univention_build_basepath/$univention_build_mediawiki_path --format zip --dir $current_dir/files --file bluespice

	if [ `systemctl is-active docker` = "inactive" ] ; then systemctl start docker; fi
	docker build -t $(docker_repo)/univention-app-image:$(app_version) .
	docker login -u $(docker_login) -p $(docker_pwd)
	docker push $(docker_repo)/univention-app-image:$(app_version)
