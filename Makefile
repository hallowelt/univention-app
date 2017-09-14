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

.PHONY: all
all: docker

.PHONY: docker
docker:
	if [ `systemctl is-active docker` = "inactive" ] ; then sudo systemctl start docker; fi
	sudo docker build -t $(docker_repo)/univention-app-image:$(app_version) .
	sudo docker login -u $(docker_login) -p $(docker_pwd)
	sudo docker push $(docker_repo)/univention-app-image:$(app_version)
