<?php


wfLoadExtensions( [
	'LDAPAuthentication2',
	'LDAPAuthorization',
	'LDAPGroups',
	'LDAPProvider',
	'LDAPUserInfo',
	'PluggableAuth'
] );

$LDAPAuthenticationAllowLocalLogin = false;
$LDAPAuthenticationUsernameNormalizer = 'strtolower';

$LDAPProviderDomainConfigProvider = function() {
	$config = [
		getenv('LDAP_MASTER') => [
			"connection" => [
				"server" => getenv( 'LDAP_MASTER' ),
				"port" => getenv( 'LDAP_SERVER_PORT' ),
				"user" => getenv( 'LDAP_HOSTDN' ),
				"pass" => file_get_contents( '/etc/machine.secret' ),
				"basedn" => getenv( 'LDAP_BASE' ),
				"userbasedn" => getenv( 'LDAP_BASE' ),
				"groupbasedn" => getenv( 'LDAP_BASE' ),
				"searchattribute" => "uid",
				"usernameattribute" => "uid",
				"realnameattribute" => "displayname",
				"emailattribute" => "mail",
				"grouprequest" => "MediaWiki\\Extension\\LDAPProvider\\UserGroupsRequest\\UserMemberOf::factory",
				"nestedgroups" => true
			],
			"authorization" => [
				"attributes-map" => [
					"bluespiceActivated" => "TRUE"
				]
			],
			"userinfo" => [
				"attributes-map" => [
					"email" => "mail",
					"realname" => "displayname"
				]
			],
			"groupsync" => [
				"mechanism" => "mappedgroups",
				"mapping" => [
					"sysop" => [
						"cn=Domain Admins,cn=groups,dc=example,dc=com"
					],
					"user" => [
						"cn=Domain Users,cn=groups,dc=example,dc=com"
					]
				]
			]
		]
	];

	return new \MediaWiki\Extension\LDAPProvider\DomainConfigProvider\InlinePHPArray( $config );
};

$LDAPProviderCacheTime = 300;
$LDAPProviderCacheType = CACHE_MEMCACHED;

$bsgPermissionConfig[ 'autocreateaccount' ] = array( 'type' => 'global', "roles" => [ 'autocreateaccount' ] );
$wgHooks[ 'SetupAfterCache' ][] = function() {
	$GLOBALS[ 'bsgGroupRoles' ][ '*' ][ 'reader' ] = false;
	$GLOBALS[ 'bsgGroupRoles' ][ 'user' ][ 'reader' ] = true;
	$GLOBALS[ 'bsgGroupRoles' ][ '*' ][ 'autocreateaccount' ] = true;
};