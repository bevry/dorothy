#!/usr/bin/env perl

use strict;
use warnings;
use JSON;
use Getopt::Long;

sub help {
    my @args = @_;
    print STDERR "USAGE:\n";
    print STDERR "echo-json.pl <stringify|encode|decode|parse> <content>\n";
    print STDERR "echo <content> | echo-json.pl <stringify|encode|decode|parse>\n";
    if (@args) {
        print STDERR "\nERROR:\n";
        print STDERR join("\n", @args), "\n";
    }
    exit 22;
}

sub parse {
    my @args = @_;

    if (@args == 0) {
        die "No arguments provided.\n";
    }

    my $operation = shift @args;
    unless ($operation =~ /^(stringify|encode|decode|parse)$/) {
        die "<operation> was invalid, it was: $operation\n";
    }

    my $content;
    if (@args == 0) {
        $content = read_stdin();
    } else {
        $content = shift @args;
        if (@args != 0) {
            die "An unrecognised argument was provided: $args[0]\n";
        }
    }

    return { operation => $operation, content => $content };
}

sub write_stdout_plain {
    my ($output) = @_;
    print $output;
}

sub write_stdout_pretty {
    my ($output) = @_;
    my $json = JSON->new->pretty(1);
    print $json->encode($output);
}

sub read_stdin {
    my $content = '';
    while (<STDIN>) {
        $content .= $_;
    }
    return $content;
}

sub main {
    my $inputs = parse(@ARGV);
    my $operation = $inputs->{operation};
    my $content = $inputs->{content};

    # handle interpretation differences between stringify, encode, decode, and parse
    my $parsed;
    my $parse_error;

    if ($operation eq 'stringify') {
        $parsed = $content;
    } else {
        eval {
            $parsed = decode_json($content);
        };
        if ($@) {
            $parse_error = $@;
            $parsed = $content;
        }
    }

    if ($operation eq 'stringify' || $operation eq 'encode') {
        eval {
            my $output = encode_json($parsed);
            write_stdout_plain($output);
        };
        if ($@) {
            die "Failed to encode the content as a JSON string: $@";
        }
    } elsif ($operation eq 'decode') {
        eval {
            my $output;
            if (ref($parsed) eq 'HASH' || ref($parsed) eq 'ARRAY' || JSON::is_bool($parsed)) {
                $output = encode_json($parsed);
            } else {
                $output = $parsed;
            }
            write_stdout_plain($output);
        };
        if ($@) {
            die "Failed to encode the content as a JSON string: $@";
        }
    } elsif ($operation eq 'parse') {
        if (defined $parse_error) {
            die "Failed to parse the JSON content: $parse_error";
        }
        write_stdout_pretty($parsed);
    } else {
        die "Internal Error: Invalid operation: $operation";
    }
}

eval {
    main();
};
if ($@) {
    help($@);
}
