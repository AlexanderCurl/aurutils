package AUR::Options;
use strict;
use warnings;
use v5.20;
use Carp;

use Exporter qw(import);
our @EXPORT_OK = qw(add_from_stdin);
our $VERSION = 'unstable';

=head1 NAME

AUR::Options - Option parsing for AUR scripts

=head1 SYNOPSIS

  use AUR::Options;
  add_from_stdin(\@ARGV, ['-', '/dev/stdin']);

=head1 DESCRIPTION

This module contains methods to assist with option parsing, specifically
when taking arguments from standard input.

=head1 AUTHORS

Alad Wenter <https://github.com/AladW>

=cut

sub delete_elements {
    my ($array_ref, @indices) = @_;

    # Remove indices from end of array first
    for (sort { $b <=> $a } @indices) {
	splice @{$array_ref}, $_, 1;
    }
}

=head2 add_from_stdin()

=cut

sub add_from_stdin {
    my ($array_ref, $tokens) = @_;
    my @indices;

    for my $idx (0..@{$array_ref}-1) {
	my $match = grep { $array_ref->[$idx] eq $_ } @{$tokens};
	push(@indices, $idx) if $match > 0;
    }

    if (scalar @indices > 0) {
	delete_elements($array_ref, @indices);        

	push(@{$array_ref}, <STDIN>);  # add arguments from stdin
        chomp(@{$array_ref});          # remove newlines
    }
}

# vim: set et sw=4 sts=4 ft=perl:
