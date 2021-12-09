#!/usr/bin/env bash

# Update keystone.conf
sed -i "s/KEYSTONE_DB_PASSWORD/${KEYSTONE_DB_PASSWORD}/g" /etc/keystone/keystone.conf
sed -i "s/KEYSTONE_DB_HOST/${KEYSTONE_DB_HOST}/g" /etc/keystone/keystone.conf


su -s /bin/sh -c 'keystone-manage db_sync' keystone

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

# Bootstrap keystone
keystone-manage bootstrap --bootstrap-username admin \
		--bootstrap-password 12345678 \
		--bootstrap-project-name admin \
		--bootstrap-role-name admin \
		--bootstrap-service-name keystone \
		--bootstrap-admin-url "${HTTP}://0.0.0.0:35357/v3" \
		--bootstrap-public-url "${HTTP}://0.0.0.0:5000/v3" \
		--bootstrap-internal-url "${HTTP}://0.0.0.0:5000/v3"

/usr/bin/keystone-all