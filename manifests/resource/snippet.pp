# define: nginx::resource::snippet
#
# This definition creates a reusable config snippet that can be included by other resources
#
# Parameters:
#   [*ensure*]      - Enables or disables the specified snippet (present|absent)
#   [*owner*]       - Defines owner of the .conf file
#   [*group*]       - Defines group of the .conf file
#   [*mode*]        - Defines mode of the .conf file
#   [*raw_content*] - Raw content that will be inserted into the snipped as-is
#
define nginx::resource::snippet (
  Enum['absent', 'present'] $ensure = 'present',
  String $owner                     = $nginx::global_owner,
  String $group                     = $nginx::global_group,
  Stdlib::Filemode $mode            = $nginx::global_mode,
  Optional[String] $raw_content     = undef,
) {
  if ! defined(Class['nginx']) {
    fail('You must include the nginx base class before using any defined resources')
  }
  if ! $nginx::snippets_dir {
    fail('Snippets are not supported without designating a snippets directory')
  }

  $name_sanitized = regsubst($name, ' ', '_', 'G')
  $config_file = "${nginx::snippets_dir}/${name_sanitized}.conf"

  concat { $config_file:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    notify  => Class['::nginx::service'],
    require => File[$nginx::snippets_dir],
  }

  concat::fragment { "snippet-${name_sanitized}-header":
    target  => $config_file,
    content => template('nginx/snippet/snippet_header.erb'),
    order   => '001',
  }
}
