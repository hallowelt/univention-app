<?php
/*
$wgGroupPermissions['Domain Admins']['siteadmin'] = true;
$wgGroupPermissions['Domain Admins']['wikiadmin'] = true;
$wgGroupPermissions['Domain Admins']['userrights'] = true;
$wgGroupPermissions['Domain Admins']['permissionmanager-viewspecialpage'] = true;
$wgGroupPermissions['Domain Admins']['groupmanager-viewspecialpage'] = true;
$wgGroupPermissions['Domain Admins']['usermanager-viewspecialpage'] = true;
*/

$wgGroupPermissions['Domain Admins'] = $wgGroupPermissions['sysop'];

require_once "$IP/extensions/LdapAuthentication/LdapAuthentication.php";

$wgAuth = new LdapAuthenticationPlugin();

//Calculate basedb for ldap from given read only bind user
$arrLdapHostDN = explode(",", getenv( 'LDAP_HOSTDN' ));
$arrBaseDN = [];//dc=7761,dc=hallowelt,dc=intranet
foreach($arrLdapHostDN as $hostDN){
  if(strpos($hostDN, 'dc=') !== false){
    $arrBaseDN[] = $hostDN;
  }
}

$sBaseDN = join(',', $arrBaseDN);

$wgLDAPDomainNames                      = array( getenv('LDAP_MASTER') );
$wgLDAPServerNames                      = array( getenv('LDAP_MASTER') => getenv( 'DB_HOST' ) );
$wgLDAPProxyAgent                       = array( getenv('LDAP_MASTER') => getenv( 'LDAP_HOSTDN' ));
$wgLDAPProxyAgentPassword               = array( getenv('LDAP_MASTER') => file_get_contents( '/etc/machine.secret' ) );
$wgLDAPEncryptionType                   = array( getenv('LDAP_MASTER') => 'clear' );
$wgLDAPSearchAttributes                 = array( getenv('LDAP_MASTER') => 'uid' );
$wgLDAPBaseDNs                          = array( getenv('LDAP_MASTER') => $sBaseDN );
$wgLDAPPreferences                      = array( getenv('LDAP_MASTER') => array( 'email' => 'mail','realname' => 'displayname','nickname' => 'samaccountname' ) );
$wgLDAPGroupUseFullDN                   = array( getenv('LDAP_MASTER') => true );
$wgLDAPGroupSearchNestedGroups          = array( getenv('LDAP_MASTER') => true );
$wgLDAPGroupObjectclass                 = array( getenv('LDAP_MASTER') => "univentionGroup" );
$wgLDAPGroupAttribute                   = array( getenv('LDAP_MASTER') => "uniqueMember" );
$wgLDAPGroupNameAttribute               = array( getenv('LDAP_MASTER') => "cn" );
$wgLDAPGroupUseRetrievedUsername        = array( getenv('LDAP_MASTER') => false );
$wgLDAPLowerCaseUsername                = array( getenv('LDAP_MASTER') => true );
$wgLDAPUseLDAPGroups                    = array( getenv('LDAP_MASTER') => true );
$wgLDAPUseLocal                         = array( getenv('LDAP_MASTER') => false );
$wgLDAPRequiredGroups                   = array( getenv('LDAP_MASTER') => array( ) );
$wgLDAPAuthAttribute                    = array( getenv('LDAP_MASTER') => 'bluespiceActivated=TRUE' );

//$wgLDAPDebug                            = 3;
//$wgDebugLogGroups['ldap']               = '/tmp/bluespice_ldap.log';
