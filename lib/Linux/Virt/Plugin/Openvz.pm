package Linux::Virt::Plugin::Openvz;
# ABSTRACT: OpenVZ plugin for Linux::Virt

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

extends 'Linux::Virt::Plugin';

sub _init_priority { return 10; }

sub is_vm {
    my $self = shift;

    # OpenVZ
    if ( -d "/proc/vz" && -e "/proc/vz/veinfo" && !-e "/proc/vz/version" ) {
        my $ret = qx(/bin/cat /proc/vz/veinfo | /usr/bin/wc -l);
        chomp($ret);
        if ( $ret == 1 ) {
            return 1;
        }
    } ## end if ( -d "/proc/vz" && ...)
    return;
} ## end sub is_vm

sub is_host {
    my $self = shift;

    # OpenVZ
    if ( -d "/proc/vz" && -e "/proc/vz/veinfo" ) {
        my $ret = qx(/bin/cat /proc/vz/veinfo | /usr/bin/wc -l);
        chomp($ret);
        if ( $ret >= 1 && -e "/proc/vz/version" ) {
            return 1;
        }
    } ## end if ( -d "/proc/vz" && ...)
    return;
} ## end sub is_host

sub vms {
    my $self        = shift;
    my $vserver_ref = shift;
    my $opts        = shift || {};

    return unless -x '/usr/sbin/vzlist';

    local $ENV{LANG} = "C";
    my $OVZ;
    if ( !open( $OVZ, '-|', "/usr/sbin/vzlist" ) ) {
        my $msg = "Could not execute /usr/sbin/vzlist! Is vzctl installed?: $!";
        $self->logger()->log( message => $msg, level => 'warning', );
        return;
    }
    while ( my $line = <$OVZ> ) {
        next if $line =~ m/^\s+CTID\s+NPROC\s+STATUS\s+IP_ADDR\s+HOSTNAME/;
        my ( $ctid, $nrpoc, $status, $ip, $hostname ) = split /\s+/, $line;
        next unless $status =~ m/running/;
        $hostname =~ s/^\s+//;
        $hostname =~ s/\s+$//;
        my $name = $hostname;
        $vserver_ref->{$name}{'virt'}{'type'}   = 'openvz';
        $vserver_ref->{$name}{'ctx'}            = $ctid;
        $vserver_ref->{$name}{'proc'}           = $nrpoc;
        $vserver_ref->{$name}{'ips'}{$ip}{'ip'} = $ip;

    } ## end while ( my $line = <$OVZ>)
    close($OVZ);

    return 1;
} ## end sub vms

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Linux::Virt::Plugin::Openvz - OpenVZ plugin for Linux::Virt.

=method is_host

Returns a true value if this is run on a OpenVZ capable host.

=method is_vm

Returns a true value if this is run inside an OpenVZ VE.

=method vms

List all running OpenVZ VMs.

=cut
