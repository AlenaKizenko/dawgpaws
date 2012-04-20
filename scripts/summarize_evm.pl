#!/usr/bin/perl -w
#-----------------------------------------------------------+
#                                                           |
# summarize_evm.pl - Summarize contributions to evm models  |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
#  AUTHOR: James C. Estill                                  |
# CONTACT: JamesEstill_@_gmail.com                          |
# STARTED: 04/20/2012                                       |
# UPDATED: 04/20/2012                                       |
#                                                           |
# DESCRIPTION:                                              |
#  Short Program Description                                |
#                                                           |
# USAGE:                                                    |
#  Summarize contributions of evm evidences to the final    |
#  models.
#                                                           |
# VERSION: $Rev$                                            |
#                                                           |
# LICENSE:                                                  |
#  GNU General Public License, Version 3                    |
#  http://www.gnu.org/licenses/gpl.html                     |  
#                                                           |
#-----------------------------------------------------------+

package DAWGPAWS;

#-----------------------------+
# INCLUDES                    |
#-----------------------------+
use strict;
use Getopt::Long;
# The following needed for printing help
use Pod::Select;               # Print subsections of POD documentation
use Pod::Text;                 # Print POD doc as formatted text file
use IO::Scalar;                # For print_help subfunction
use IO::Pipe;                  # Pipe for STDIN, STDOUT for POD docs
use File::Spec;                # Convert a relative path to an abosolute path

#-----------------------------+
# PROGRAM VARIABLES           |
#-----------------------------+
my ($VERSION) = q$Rev$ =~ /(\d+)/;

#-----------------------------+
# VARIABLE SCOPE              |
#-----------------------------+
my $infile;
my $outfile;

# BOOLEANS
my $quiet = 0;
my $verbose = 0;
my $show_help = 0;
my $show_usage = 0;
my $show_man = 0;
my $show_version = 0;
my $do_test = 0;                  # Run the program in test mode

#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions(# REQUIRED OPTIONS
		    "i|infile=s"  => \$infile,
                    "o|outfile=s" => \$outfile,
		    # ADDITIONAL OPTIONS
		    "q|quiet"     => \$quiet,
		    "verbose"     => \$verbose,
		    # ADDITIONAL INFORMATION
		    "usage"       => \$show_usage,
		    "test"        => \$do_test,
		    "version"     => \$show_version,
		    "man"         => \$show_man,
		    "h|help"      => \$show_help,);

#-----------------------------+
# PRINT REQUESTED HELP        |
#-----------------------------+
if ( ($show_usage) ) {
#    print_help ("usage", File::Spec->rel2abs($0) );
    print_help ("usage", $0 );
}

if ( ($show_help) || (!$ok) ) {
#    print_help ("help",  File::Spec->rel2abs($0) );
    print_help ("help",  $0 );
}

if ($show_man) {
    # User perldoc to generate the man documentation.
    system ("perldoc $0");
    exit($ok ? 0 : 2);
}

if ($show_version) {
    print "\nbatch_mask.pl:\n".
	"Version: $VERSION\n\n";
    exit;
}

#-----------------------------+
# MAIN PROGRAM BODY           |
#-----------------------------+

# INPUT - Evm File
if ($infile) {
    open (INFILE, "<$infile") ||
	die "Can not open input file $infile";
}
else {
    open (INFILE, "<&STDIN") ||
	die "Can not open input from STDIN. Specify input file with -i";
}

# OUTPUT - Summary table
if ($outfile) {
    open (OUTFILE, ">$outfile") ||
	die "Can not open output file $outfile";
} 
else {
    open (OUTFILE, ">&STDOUT") ||
	die "Can not acces STDOUT for output. Specify an output file path with -o ";
}


my $evm_summary = ();
while (<INFILE>) {

    chomp;
    next if m/^\#/; 
    
    my @evm_parts = split( /\t/, $_);

    my $feature = $evm_parts[2];

    if ($feature) {
	my @evidences = split(/\,/ , $evm_parts[5]);



	if ($verbose) {
	    print STDERR $feature.":".
	#	$evm_parts[5].
		"\n";
	}
	
	foreach my $evidence (@evidences) {
	    if ($evidence =~ m/\;(.*)\}/) {
		my $source = $1;
		print STDERR "\t".$1."\n" if $verbose;

		# Increment hash of hashes
		if ( $evm_summary->{ $feature  }->{ $source } ) { 
		    $evm_summary->{ $feature  }->{ $source } = 
			$evm_summary->{ $feature  }->{ $source } + 1;
		}
		else {
		    $evm_summary->{ $feature  }->{ $source } = 1;
		}
	    } 
#	    print STDERR "\t".$evidence."\n" if $verbose;
	}
	
	
    }
    else {
	# THESE APPEAR TO BE EMPTY LINES
#	print STDERR "No feature in:\n";
#	print STDERR $_."\n"
    }
}


# Overview count
print OUTFILE "OVERVIEW\n";

my $all_srcs = ();

for my $k1 ( sort keys %$evm_summary ) {
    print OUTFILE "$k1\n";
    for my $k2 ( sort keys %{$evm_summary->{ $k1 }} ) {
	
	# Load names to all srcs hash to generate unique list
	if ( $all_srcs->{ $k2} ) {
	    $all_srcs->{ $k2  } = $all_srcs->{ $k2 } + 1;
	}
	else {
	    $all_srcs->{ $k2 } = 1;
	}

	print OUTFILE "\t$k2\ : ";
	print OUTFILE $evm_summary->{ $k1 }->{ $k2 }."\n";
    }

}

# Wiki table

# PRINT TABLE HEADER
print OUTFILE "|| FEATURE || ";
for my $col ( sort keys %$all_srcs  ) {
    print OUTFILE $col." || ";
}
print OUTFILE "\n";

# PRINT TABLE DATA
for my $row ( sort keys %$evm_summary ) {
    print OUTFILE "||".$row." || ";
    for my $col ( sort keys %$all_srcs  ) {
	if ($evm_summary->{ $row }->{ $col }) {
	    # If value, print value
	    print OUTFILE $evm_summary->{ $row }->{ $col }." || ";
	}
	else {
	    # If no value print zero
	    print OUTFILE " 0 ||";
	}
    }
    print OUTFILE "\n";
}

close (INFILE);
close (OUTFILE);

exit 0;

#-----------------------------------------------------------+ 
# SUBFUNCTIONS                                              |
#-----------------------------------------------------------+

sub print_help {
    my ($help_msg, $podfile) =  @_;
    # help_msg is the type of help msg to use (ie. help vs. usage)
    
    print "\n";
    
    #-----------------------------+
    # PIPE WITHIN PERL            |
    #-----------------------------+
    # This code made possible by:
    # http://www.perlmonks.org/index.pl?node_id=76409
    # Tie info developed on:
    # http://www.perlmonks.org/index.pl?node=perltie 
    #
    #my $podfile = $0;
    my $scalar = '';
    tie *STDOUT, 'IO::Scalar', \$scalar;
    
    if ($help_msg =~ "usage") {
	podselect({-sections => ["SYNOPSIS|MORE"]}, $0);
    }
    else {
	podselect({-sections => ["SYNOPSIS|ARGUMENTS|OPTIONS|MORE"]}, $0);
    }

    untie *STDOUT;
    # now $scalar contains the pod from $podfile you can see this below
    #print $scalar;

    my $pipe = IO::Pipe->new()
	or die "failed to create pipe: $!";
    
    my ($pid,$fd);

    if ( $pid = fork() ) { #parent
	open(TMPSTDIN, "<&STDIN")
	    or die "failed to dup stdin to tmp: $!";
	$pipe->reader();
	$fd = $pipe->fileno;
	open(STDIN, "<&=$fd")
	    or die "failed to dup \$fd to STDIN: $!";
	my $pod_txt = Pod::Text->new (sentence => 0, width => 78);
	$pod_txt->parse_from_filehandle;
	# END AT WORK HERE
	open(STDIN, "<&TMPSTDIN")
	    or die "failed to restore dup'ed stdin: $!";
    }
    else { #child
	$pipe->writer();
	$pipe->print($scalar);
	$pipe->close();	
	exit 0;
    }
    
    $pipe->close();
    close TMPSTDIN;

    print "\n";

    exit 0;
   
}

1;
__END__

=head1 NAME

Name.pl - Short program description. 

=head1 VERSION

This documentation refers to program version 0.1

=head1 SYNOPSIS

=head2 Usage

    Name.pl -i InFile -o OutFile

=head2 Required Arguments

    --infile        # Path to the input file
    --outfie        # Path to the output file

=head1 DESCRIPTION

This is what the program does

=head1 REQUIRED ARGUMENTS

=over 2

=item -i,--infile

Path of the input file.

=item -o,--outfile

Path of the output file.

=back

=head1 OPTIONS

=over 2

=item --usage

Short overview of how to use program from command line.

=item --help

Show program usage with summary of options.

=item --version

Show program version.

=item --man

Show the full program manual. This uses the perldoc command to print the 
POD documentation for the program.

=item -q,--quiet

Run the program with minimal output.

=back

=head1 EXAMPLES

The following are examples of how to use this script

=head2 Typical Use

This is a typcial use case.

=head1 DIAGNOSTICS

=over 2

=item * Expecting input from STDIN

If you see this message, it may indicate that you did not properly specify
the input sequence with -i or --infile flag. 

=back

=head1 CONFIGURATION AND ENVIRONMENT

Names and locations of config files
environmental variables
or properties that can be set.

=head1 DEPENDENCIES

Other modules or software that the program is dependent on.

=head1 BUGS AND LIMITATIONS

Any known bugs and limitations will be listed here.

=head1 REFERENCE

A manuscript is being submitted describing the DAWGPAWS program. 
Until this manuscript is published, please refer to the DAWGPAWS 
SourceForge website when describing your use of this program:

JC Estill and JL Bennetzen. 2009. 
The DAWGPAWS Pipeline for the Annotation of Genes and Transposable 
Elements in Plant Genomes.
http://dawgpaws.sourceforge.net/

=head1 LICENSE

GNU General Public License, Version 3

L<http://www.gnu.org/licenses/gpl.html>

=head1 AUTHOR

James C. Estill E<lt>JamesEstill at gmail.comE<gt>

=head1 HISTORY

STARTED:

UPDATED:

VERSION: $Rev$

=cut

#-----------------------------------------------------------+
# HISTORY                                                   |
#-----------------------------------------------------------+
#
