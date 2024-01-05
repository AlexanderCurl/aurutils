package AUR::Query;
use strict;
use warnings;
use v5.20;
use Carp;

use Exporter qw(import);
our @EXPORT = qw(urlencode query query_multi);
our $VERSION = 'unstable';

=head1 NAME

AUR::Query - Retrieve data from AurJSON

=head1 SYNOPSIS

  use AUR::Query;

  # type=search, one GET request per argument
  my $search = query(term => 'foo', type => 'search', by => 'name-desc');

  # type=info, one POST request for multiple arguments
  my @info = query_multi(terms => ['bar', 'baz'], type => 'info');

=head1 DESCRIPTION

This module offers perl aur(1) scripts a direct way to retrieve data from AurJson
using GET or POST requests. Arguments are url-encoded beforehand.

=head1 AUTHORS

Alad Wenter <https://github.com/AladW>

=cut

# environment variables
our $aur_location = $ENV{AUR_LOCATION}  // 'https://aur.archlinux.org';
our $aur_rpc      = $ENV{AUR_QUERY_RPC} // $aur_location . "/rpc";
our $aur_rpc_ver  = $ENV{AUR_QUERY_RPC_VERSION} // 5;
our $aur_splitno  = $ENV{AUR_QUERY_RPC_SPLITNO} // 5000;

=item urlencode()

=cut

# https://code.activestate.com/recipes/577450-perl-url-encode-and-decode/#c6
sub urlencode {
    my $s = shift;
    $s =~ s/([^A-Za-z0-9])/sprintf("%%%2.2X", ord($1))/ge;
    return $s;
}

sub query_curl {
    my @cmd = ('curl', '-A', 'aurutils', '-fgLsSq', @_);
    
    if (defined $ENV{'AUR_DEBUG'}) {
        say STDERR join(" ", map(qq/'$_'/, @cmd));
    }
    my $str;
    my $child_pid = open(my $fh, "-|", @cmd) or die $!;

    if ($child_pid) { # parent process
        $str = <$fh>;
        croak 'response error (multi-line output)' if defined(<$fh>);

        waitpid($child_pid, 0);
    }
    # Return a generic error code on `curl` failure, to avoid overlap with
    # codes from other tools which use pipelines (`aur-repo`, `aur-vercmp`).
    # 2 is the same code returned if `curl` is not found in `open` above.
    exit (2) if $?;
    return $str;
}

=item query()

=cut

# XXX: accept arbitrary suffix/parameter instead of $by
sub query {
    my %args = (type => undef, term => undef, by => undef, callback => undef, @_);
    if (not defined $args{term}) {
        die 'query: no search term supplied';
    }
    my $term = urlencode($args{term});
    my $path = "$aur_rpc/v$aur_rpc_ver/$args{type}/$term";

    if (defined $args{by}) {
        $path = join('?by=', $path, $args{by});
    }
    my $response = query_curl($path);

    defined $args{callback} ? return $args{callback}->($response)
                            : return $response;
}

=item query_multi()

=cut

# XXX: this can also be used to split GET requests
sub query_multi {
    my %args = (type => undef, terms => [], splitno => $aur_splitno, callback => undef, @_);
    croak if defined $args{by}; # searches should be done with query()
    
    if (scalar @{$args{terms}} == 0) {
        die 'query_multi: no search terms supplied';
    }
    my @results;

    # n-ary queue processing (aurweb term limit)
    while (my @next = splice(@{$args{terms}}, 0, $args{splitno})) {
        my $data;
        map { $data .= '&arg[]=' . urlencode($_) } @next;

        # XXX: let callback handle both @results and $response (aur-search union/intersection)
        my $response = query_curl("$aur_rpc/v$aur_rpc_ver/$args{type}", '--data-raw', $data);

        defined $args{callback} ? push(@results, $args{callback}->($response))
                                : push(@results, $response);
    }
    return @results;
}

# vim: set et sw=4 sts=4 ft=perl:
