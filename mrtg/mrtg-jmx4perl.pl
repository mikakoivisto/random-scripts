#!/usr/bin/perl

# Copyright (c) 2013 Mika Koivisto <mika@javaguru.fi>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use Getopt::Long;
use JMX::Jmx4Perl;
use JMX::Jmx4Perl::Request; 

my $VERSION = "0.1";

my $OPTIONS = <<"_OPTIONS";

$0 Ver $VERSION Copyright (C) 2013 Mika Koivisto
This program comes with ABSOLUTELY NO WARRANTY; 
This is free software, and you are welcome to
redistribute it under certain conditions;
See the GNU General Public License for more details.

Usage: $0 

  --help                    display this help-screen and exit
  --server=#                jmx4perl server running jolokia
  --mbean=#                 Target MBean
  --attribute=#             Space separated list of attributes to read
  --path=#                  Space separated path for value

  --debug                   debug logging
_OPTIONS

sub usage {
   die @_, $OPTIONS;
}

my %opt = ();
my ($server, $mbean, $attributes, $paths, $debug);

Getopt::Long::Configure(qw(no_ignore_case));
GetOptions( \%opt,
        "help",
        "server=s" => \$server,
        "mbean=s" => \$mbean,
        "attribute=s",
        "path=s",
        "debug" => \$debug,
) or usage ();

usage("") if ($opt{help});

usage("") unless ($server);
usage("") unless ($mbean);
usage("") unless ($opt{attribute});

if ($debug) {
        print "Server: ", $server, "\n";
        print "MBean: ", $mbean, "\n";
        print "Attributes: ", $opt{attribute}, "\n";
        print "Paths: ", $opt{path}, "\n";
}

my $jmx = new JMX::Jmx4Perl(server => "$server",
                            "config_file" => "/etc/jmx4perl/jmx4perl.cfg",
                            product => "tomcat");
my @attributes = split(" ", $opt{attribute});
my @values;

foreach (@attributes) {
   my $attr = $_;

   if ($opt{path}) {
       my @paths = split(" ", $opt{path});

       foreach (@paths) {
           my $path = $_;

           my $request = new JMX::Jmx4Perl::Request({type => READ,
                                             mbean => "$mbean",
                                             attribute => "$attr", path => $path});
           my $response = $jmx->request($request); 
           my $val = $response->value();
           push @values, $val;
       }
   }
   else {
       my $request = new JMX::Jmx4Perl::Request({type => READ,
                                             mbean => "$mbean",
                                             attribute => "$attr"});
       my $response = $jmx->request($request); 
       my $val = $response->value();
 
      if (ref($val) eq "HASH") {
          foreach (keys %$val) {
              push @values, $val->{$_}->{$attr};
           }
        } else {
           push @values, $val;
        }
   }
}

foreach (@values) {
   print $_, "\n";
}
my $num = @values;
$num++;
foreach ($num..3) {
   print "0\n";
}
print "\n";

