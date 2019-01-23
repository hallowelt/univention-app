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
				"userbasedn" => 'cn=users,'.getenv( 'LDAP_BASE' ),
				"groupbasedn" => 'cn=groups,'.getenv( 'LDAP_BASE' ),
				"searchattribute" => "uid",
				"usernameattribute" => "uid",
				"realnameattribute" => "displayname",
				"emailattribute" => "mail",
				"grouprequest" => "MediaWiki\\Extension\\LDAPProvider\\UserGroupsRequest\\GroupMember::factory",
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
					"realname" => "displayname",
					"nickname" => "uid"
				]
			],
			"groupsync" => [
				"mapping" => [
					"mechanism" => "MediaWiki\\Extension\\LDAPGroups\\SyncMechanism\\AllGroups::factory",
					"locally-managed" => [ "bot", "bureaucrat", "sysop" ]
				]
			]
		]
	];

	return new \MediaWiki\Extension\LDAPProvider\DomainConfigProvider\InlinePHPArray( $config );
};

$LDAPProviderCacheTime = 300;
$LDAPProviderCacheType = CACHE_MEMCACHED;

$bsgPermissionConfig[ 'autocreateaccount' ] = array( 'type' => 'global', "roles" => [ 'autocreateaccount' ] );
$wgGroupPermissions['Domain Admins']['read'] = true;
$wgGroupPermissions['Domain Users']['read'] = true;
$wgHooks[ 'SetupAfterCache' ][] = function() {
	$GLOBALS[ 'bsgGroupRoles' ][ 'Domain Admins' ][ 'admin' ] = true;
	$GLOBALS[ 'bsgGroupRoles' ][ 'Domain Users' ][ 'editor' ] = true;
	$GLOBALS[ 'bsgGroupRoles' ][ '*' ][ 'reader' ] = false;
	$GLOBALS[ 'bsgGroupRoles' ][ 'user' ][ 'reader' ] = true;
	$GLOBALS[ 'bsgGroupRoles' ][ '*' ][ 'autocreateaccount' ] = true;
};