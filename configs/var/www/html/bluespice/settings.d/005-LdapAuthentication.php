<?php

$wgGroupPermissions['Domain Admins']['siteadmin'] = true;
$wgGroupPermissions['Domain Admins']['wikiadmin'] = true;
$wgGroupPermissions['Domain Admins']['userrights'] = true;
$wgGroupPermissions['Domain Admins']['permissionmanager-viewspecialpage'] = true;
$wgGroupPermissions['Domain Admins']['groupmanager-viewspecialpage'] = true;
$wgGroupPermissions['Domain Admins']['usermanager-viewspecialpage'] = true;

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

$wgLDAPDomainNames                      = array( 'HW' );
$wgLDAPServerNames                      = array( 'HW' => getenv( 'DB_HOST' ) );
$wgLDAPProxyAgent                       = array( 'HW' => getenv( 'LDAP_HOSTDN' ));
$wgLDAPProxyAgentPassword               = array( 'HW' => file_get_contents( '/etc/machine.secret' ) );
$wgLDAPEncryptionType                   = array( 'HW' => 'clear' );
$wgLDAPSearchAttributes                 = array( 'HW' => 'uid' );
$wgLDAPBaseDNs                          = array( 'HW' => $sBaseDN );
$wgLDAPPreferences                      = array( 'HW' => array( 'email' => 'mail','realname' => 'displayname','nickname' => 'samaccountname' ) );
$wgLDAPGroupUseFullDN                   = array( 'HW' => true );
$wgLDAPGroupSearchNestedGroups          = array( 'HW' => true );
$wgLDAPGroupObjectclass                 = array( 'HW' => "univentionGroup" );
$wgLDAPGroupAttribute                   = array( 'HW' => "uniqueMember" );
$wgLDAPGroupNameAttribute               = array( 'HW' => "cn" );
$wgLDAPGroupUseRetrievedUsername        = array( 'HW' => false );
$wgLDAPLowerCaseUsername                = array( 'HW' => true );
$wgLDAPUseLDAPGroups                    = array( 'HW' => true );
$wgLDAPUseLocal                         = array( 'HW' => false );
$wgLDAPRequiredGroups                   = array( 'HW' => array( ) );
$wgLDAPAuthAttribute                    = array( 'HW' => 'bluespiceActivated=TRUE' );

//$wgLDAPDebug                            = 3;
//$wgDebugLogGroups['ldap']               = '/tmp/bluespice_ldap.log';
