# In comparison to the puppetlabs-passenger module, this module does not set
# a specific version of passenger but installs the latest version available
# on the passenger rpm repo. No gems, no gcc required.
#
# Phusion Passenger is an application server for Ruby (Rack) and Python (WSGI)
# apps. It allows you to get your web apps online with the least amount of
# hassle, by taking care of pretty much all of the heavy lifting for you when
# it comes to managing your apps' processes and resources.

class passenger {
    include yum
    include yum::kermit
    include yum::epel # needed for the libev dep of passenger

    # cf puppetlabs-apache
    include apache
    #apache::mod { 'passenger': }
    class { 'apache::mod::passenger' :
        require => [  Yumrepo['passenger'], Class['yum::epel'],
                      File['RPM-GPG-KEY-passenger'], ],
    }
    # the puppetlabs base apache module v. 0.6.0 does not open the http port
    include apachefw

    # Override the configuration purge by puppetlabs-apache in httpd/conf.d
    file { 'passenger.conf' :
        ensure   => present,
        path     => '/etc/httpd/conf.d/passenger.conf',
        require  => Package[ 'mod_passenger', 'httpd' ],
        owner    => 'root',
        group    => 'root',
        mode     => '0644',
        notify   => Service[ 'httpd' ],
        # no source, it is provided by the package mod_passenger
    }

    file { 'RPM-GPG-KEY-passenger' :
        ensure => present,
        path   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-passenger',
        source => 'puppet:///modules/kermitrest/RPM-GPG-KEY-passenger',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }

    yumrepo { 'passenger' :
        baseurl    =>
            'http://passenger.stealthymonkeys.com/rhel/$releasever/$basearch',
        # some mirrors are out of date !
        #mirrorlist => 'http://passenger.stealthymonkeys.com/rhel/mirrors',
        descr      => 'Red Hat Enterprise $releasever - Phusion Passenger',
        enabled    => 1,
        gpgcheck   => 1,
        gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-passenger',
    }

}
