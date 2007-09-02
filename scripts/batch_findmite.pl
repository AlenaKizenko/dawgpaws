#!/usr/bin/perl -w
#-----------------------------------------------------------+
#                                                           |
# batch_findmite.pl - Batch run the findmite program        |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
#  AUTHOR: James C. Estill                                  |
# CONTACT: JamesEstill_@_gmail.com                          |
# STARTED: 08/30/2007                                       |
# UPDATED: 08/30/2007                                       |
#                                                           |
# DESCRIPTION:                                              |
#  Short Program Description                                |
#                                                           |
# USAGE:                                                    |
#  ShortFasta Infile.fasta Outfile.fasta                    |
#-----------------------------------------------------------+

=head1 NAME

batch_findmite.pl - Run the findmite program in batch mode.

=head1 VERSION

This documentation refers to $Rev$

=head1 SYNOPSIS

  USAGE:
    batch_findminte.pl -i InDir -o OutDir

=head1 DESCRIPTION



=head1 COMMAND LINE ARGUMENTS

=head2 Required Argumens

=over 2

=item -i,--indir

Path of the input directory. This is a directory that contains the fasta
files to process.

=item -o,--outdir

Path of the base output directory.

=back

=head2 Additional Options

=over 2

=item -q,--quiet

Run the program with minimal output. Does not require user interaction.

=item --verbose

Run the program with maximal output.

=back

=head2 Additional Information

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

=back

=head1 DIAGNOSTICS

The list of error messages that can be generated,
explanation of the problem
one or more causes
suggested remedies
list exit status associated with each error

=head1 CONFIGURATION AND ENVIRONMENT

Names and locations of config files
environmental variables
or properties that can be set.

=head1 DEPENDENCIES

Other modules or software that the program is dependent on.

=head1 BUGS AND LIMITATIONS

Any known bugs and limitations will be listed here.

=head1 LICENSE

GNU LESSER GENERAL PUBLIC LICENSE

http://www.gnu.org/licenses/lgpl.html

=head1 AUTHOR

James C. Estill E<lt>JamesEstill at gmail.comE<gt>

=cut

package DAWGPAWS;

#-----------------------------+
# INCLUDES                    |
#-----------------------------+
use strict;
use Getopt::Long;

# Array to hold the findmite parameters
my @fm_params = ();

#-----------------------------+
# PROGRAM VARIABLES           |
#-----------------------------+
my ($VERSION) = q$Rev$ =~ /(\d+)/;

#-----------------------------+
# VARIABLE SCOPE              |
#-----------------------------+
my $indir;                     # Input directory
my $outdir;                    # Output directory
my $parfile;                   # Parameters file
my $name_root;                 # Root name of the input file
my $gff_dir;                    # Dir to hold the gff output file

# Counters/Index Vals
my $i = 0;                     # Array index val
my $file_num = 0;              # File number
my $proc_num = 0;              # Process number

# Booleans
my $verbose = 0;
my $help = 0;
my $quiet = 0;
my $show_help = 0;
my $show_usage = 0;
my $show_man = 0;
my $show_version = 0;
my $do_gff_convert = 0;

#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions(# Required Arguments
		    "i|indir=s"       => \$indir,
                    "o|outdir=s"      => \$outdir,
		    "p|params=s"      => \$parfile,
		    # Additional options
		    "q|quiet"         => \$quiet,
		    "verbose"         => \$verbose,
		    "gff"             => \$do_gff_convert,
		    # Additional information
		    "usage"           => \$show_usage,
		    "version"         => \$show_version,
		    "man"             => \$show_man,
		    "h|help"          => \$show_help,);

#-----------------------------+
# SHOW REQUESTED HELP         |
#-----------------------------+
if ($show_usage) {
    print_help("");
}

if ($show_help || (!$ok) ) {
    print_help("full");
}

if ($show_version) {
    print "\n$0:\nVersion: $VERSION\n\n";
    exit;
}

if ($show_man) {
    # User perldoc to generate the man documentation.
    system("perldoc $0");
    exit($ok ? 0 : 2);
}

#-----------------------------------------------------------+
# MAIN PROGRAM BODY                                         |
#-----------------------------------------------------------+

#-----------------------------+
# CHECK FOR SLASH IN DIR      |
# VARIABLES                   |
#-----------------------------+
# If the indir does not end in a slash then append one
# TO DO: Allow for backslash
unless ($indir =~ /\/$/ ) {
    $indir = $indir."/";
}

unless ($outdir =~ /\/$/ ) {
    $outdir = $outdir."/";
}

#-----------------------------+
# CREATE THE OUT DIR          |
# IF IT DOES NOT EXIST        |
#-----------------------------+
unless (-e $outdir) {
    print "Creating output dir ...\n" if $verbose;
    mkdir $outdir ||
	die "Could not create the output directory:\n$outdir";
}

#-----------------------------+
# LOAD FINDMITE PARAMATERS    |
#-----------------------------+
open (PARFILE, "<$parfile")
    || die "Can not open the paramter file:\n$parfile\n";

while (<PARFILE>) {
    chomp;

#    # Use the following if an error crops up later
#    print "IN: $_\n";
    
    # Ignores comment lines starting with #
    unless (m/^\#/) {
	#my @in_line = split(/\t/, $_);
	my @in_line = split;           # Implicit split of $_ by whitespace
	my $num_in_line = @in_line; 
	$fm_params[$i][0] = $in_line[0] || "NULL"; 
	$fm_params[$i][1] = $in_line[1] || "NULL";
	$fm_params[$i][2] = $in_line[2] || "NULL";
	$fm_params[$i][3] = $in_line[3] || "NULL";
	$fm_params[$i][4] = $in_line[4] || "NULL";
	$fm_params[$i][5] = $in_line[5] || "NULL";
	$fm_params[$i][6] = $in_line[6] || "NULL";
	$fm_params[$i][7] = $in_line[7] || "NULL";
	$fm_params[$i][8] = $in_line[8] || "NULL";
	$fm_params[$i][9] = $in_line[9] || "NULL";
	
#        # Use the following if a error crops up later
#	if ($verbose) {
#	    print STDERR "\tProcessed as:\n";
#	    print STDERR "\t".$fm_params[$i][0]."\n";
#	    print STDERR "\t".$fm_params[$i][1]."\n";
#	    print STDERR "\t".$fm_params[$i][2]."\n";
#	    print STDERR "\t".$fm_params[$i][3]."\n";
#	    print STDERR "\t".$fm_params[$i][4]."\n";
#	    print STDERR "\t".$fm_params[$i][5]."\n";
#	    print STDERR "\t".$fm_params[$i][6]."\n";
#	    print STDERR "\t".$fm_params[$i][7]."\n";
#	    print STDERR "\t".$fm_params[$i][8]."\n";
#	    print STDERR "\t".$fm_params[$i][9]."\n";
#	}
	
	$i++;
    }

} # End of while INFILE

my $num_par_sets = $i;
my $max_i = $i-1;

close PARFILE;


# TO DO: CHECK PARAM FILE VALIDITY


#-----------------------------+
# Get the FASTA files from the|
# directory provided by the   |
# var $indir                  |
#-----------------------------+
opendir( DIR, $indir ) || 
    die "Can't open directory:\n$indir"; 
my @fasta_files = grep /\.fasta$|\.fa$/, readdir DIR ;
closedir( DIR );
my $num_files = @fasta_files;

my $num_proc_total = $num_files * $num_par_sets;

print STDERR "$num_proc_total findmite runs to process\n";

for my $ind_file (@fasta_files) {

    $file_num++;
    
    # Get root file name
    if ($ind_file =~ m/(.*)\.fasta$/ ) {	    
	$name_root = "$1";
    }  
    elsif ($ind_file =~ m/(.*)\.fa$/ ) {	    
	$name_root = "$1";
    } 
    else {
	$name_root = "UNDEFINED";
    }

    #-----------------------------+
    # CREATE ROOT NAME DIR        |
    #-----------------------------+
    my $name_root_dir = $outdir.$name_root."/";
    unless (-e $name_root_dir) {
	mkdir $name_root_dir ||
	    die "Could not create dir:\n$name_root_dir\n"
    }

    #-----------------------------+
    # CREATE FINDMITE OUTDIR      |
    #-----------------------------+
    # Dir to hold gene prediction output from local software
    my $findmite_dir = $name_root_dir."findmite/";
    unless (-e $findmite_dir) {
	mkdir $findmite_dir ||
	    die "Could not create genscan out dir:\n$findmite_dir\n";
    }

    #-----------------------------+
    # CREATE GFF OUTDIR           |
    #-----------------------------+
    if ($do_gff_convert) {
	$gff_dir = $name_root_dir."gff/";
	unless (-e $gff_dir) {
	    mkdir $gff_dir ||
		die "Could not create genscan out dir:\n$gff_dir\n";
	}
    }

    #-----------------------------------------------------------+
    # RUN FINDMITE FOR EACH SET OF PARAM VALUES                 |
    #-----------------------------------------------------------+
    for ($i=0; $i<$num_par_sets; $i++) {
	$proc_num++;
	
	# Load array vals to usefull short names
	my $mite_name    = $fm_params[$i][0];
	my $rep          = $fm_params[$i][1];
	my $tir_len      = $fm_params[$i][2];
	my $num_mismatch = $fm_params[$i][3];
	my $filt_at      = $fm_params[$i][4];
	my $filt_cg      = $fm_params[$i][5];
	my $filt_atta    = $fm_params[$i][6];
	my $filt_2_base  = $fm_params[$i][7];
	my $min_dist     = $fm_params[$i][8];
	my $max_dist     = $fm_params[$i][9];

	if ($verbose) {
	    print STDERR "\n\n========================================\n";
	    print STDERR " FindMITE Process $proc_num of $num_proc_total\n";
	    print STDERR " ".$name_root."_".$mite_name."\n";
	    print STDERR "========================================\n";
	}

	#-----------------------------+
	# RUN THE FINDMITE PROGRAM    |
	#-----------------------------+
	# Then should be made a subfunction that can return true
	my $fm_in = $indir.$ind_file;
	my $fm_out = $findmite_dir.$name_root."_".$mite_name.".mite.txt";
	my $fm_cmd = "FINDMITE1New.bin $fm_in $fm_out";
	print "CMD: $fm_cmd\n" if $verbose;


	# It seems like FINDMTE is closing
	# Some j
	open(FINDMITE,"|$fm_cmd") ||
	    die "Could not open findmite\n";
	#sleep 1;
	print FINDMITE "150000\n" ||
	    die "Could not set length";
	print FINDMITE "$rep\n";
	#sleep 1;
	print FINDMITE "$tir_len\n";
	#sleep 1;
	print FINDMITE "$num_mismatch\n";
	#sleep 1;
	print FINDMITE "$filt_at\n";
	#sleep 1;
	print FINDMITE "$filt_cg\n";
	#sleep 1;
	print FINDMITE "$filt_atta\n";
	#sleep 1;
	print FINDMITE "$filt_2_base\n";
	#sleep 1;
	print FINDMITE "$min_dist\n";
	#sleep 1;
	print FINDMITE "$max_dist\n";
	#sleep 10;
	close FINDMITE;


	#-----------------------------+
	# CONVERT OUTPUT TO GFF       |
	#-----------------------------+
	if ($do_gff_convert) {
	    my $findmite_gff = $findmite_dir.$name_root.
		"_".$mite_name."mite.gff";
	    
	    if (-e $fm_out) {
		findmite2gff ($fm_out, $findmite_gff, 0, $name_root, 0, 0);
		
		# Copy the file
	    }
	    else {
		print STDERR "ERROR: Could not find the findmite out file\n".
		    "$fm_out\nto convert to gff\n";
	    }
	}

	# print return to clean up the command line
	print "\n";

    } # End of run find mite for each set of param vals
    
    

} # End of for each $ind_file


exit;

#-----------------------------------------------------------+ 
# SUBFUNCTIONS                                              |
#-----------------------------------------------------------+

sub findmite2gff {
    
    #-----------------------------+
    # SUBFUNCTION VARS            |
    #-----------------------------+
    my ($findmite_in, $gff_out, $append_gff, $seqname, 
	$fasta_out, $append_fasta) = @_;
    

    # GFF OUT VARS
    my $gff_seq_id;                 # Seq id for use in gff
    my $gff_start;                  # Start of the feature
    my $gff_end;                    # End of the feature
    my $gff_source;                 # Source ie findmite_at_11
    my $gff_name;                   # Name of the feature 

    # FINDMITE HEADER VARS
    my $fm_dir_repeats;             # Direct repeats
    my $fm_tir_len;                 # Lenght of the TIR
    my $fm_mismatch_max;            # Max number of mistmatches
    my $fm_filter_at;               # Were A/T strings filtered 
    my $fm_filter_cg;               # Were C/G strings filtered
    my $fm_filter_atta;             # Were AT/TA strings filtered
    my $fm_filter_2_base;           # Percent (0 to 100)
    my $fm_min_dist;                # Minimum distance used
    my $fm_max_dist;                # Maximum distance used
    my $fm_file_an;                 # Name of the file analyzed

    # FINDMATE INDIVIDUAL MITE VARS
    my $fm_pattern;                 # Pattern
    my $fm_seq_id;                  # Id of the query sequence
    my $fm_num_mismatch;            # Num of mismatches
    my $fm_seq = "";                # Sequence string as parsed from findmite
    my $mite_seq_string;            # Sequence string of the putatitve mite
    my $mite_context_5;             # 5' Context of the mite (40bp)
    my $mite_context_3;             # 3' Context of the mite (40bp)
    my $mite_start;                 # Start of the mite as parsed from FM
    my $mite_end;                   # End of the mite as parsed from FM

    # Counter
    my $mite_num = 0;               # Incremented ID number for the mite

    # BOOLEANS
    my $in_seq = 0;                 # Boolean, in seq data (past header info)

    #-----------------------------+
    # OPEN FILES                  |
    #-----------------------------+

    open (INFILE, "<$findmite_in") ||
	die "Can not open input file:\n$findmite_in\n";

    
    if ($append_gff) {
	open (GFFOUT, ">>$gff_out") ||
	    die "Can not open output file:\n$gff_out\n";	
    }
    else {
	open (GFFOUT, ">$gff_out") ||
	    die "Can not open gff output file:\n$gff_out\n";
    }

    if ($fasta_out) {
	if ($append_fasta) {
	    open (FASTAOUT, ">>$fasta_out") ||
		die "Can not FASTA output file:\n$fasta_out\n";
	} 
	else {
	    open (FASTAOUT, ">$fasta_out") ||
	    die "Can not FASTA output file:\n$fasta_out\n";
	}
    } # End of if $fasta_out

    #-----------------------------+
    # PROCESS FINDMITE FILE       |
    #-----------------------------+
    while (<INFILE>) {
	chomp;
 	#print $_."\n";

	if(m/^Pattern  : (.*)/) {

	    # If we have previously loaded seq data then
	    # futher parse the sequence string and and
	    # print the results to the gff output
	    if ($in_seq) {
		                   
		if ($fm_seq =~ m/(.*)\((.*)\)\-{5}(.*)\-{5}\((.*)\)(.*)/) {
		    $mite_context_5 = $1;
		    $mite_start = $2;
		    $mite_seq_string = $3;
		    $mite_end = $4;
		    $mite_context_3 = $5;

		    if ($verbose) {
			print STDERR "\t5CON: $mite_context_5\n";
			print STDERR "\tSTAR: $mite_start\n";
			print STDERR "\tMITE: $mite_seq_string\n";
			print STDERR "\tEND : $mite_end\n";
			print STDERR "\t3CON: $mite_context_3\n";
			print STDERR "\n\n";
		    }

		    #-----------------------------+
		    # PRINT TO GFF FILE           |
		    #-----------------------------+
		    # Parse seq id for shorter name
		    if ($fm_seq_id =~ m/^>(\S*)\s./) {
			$gff_seq_id = $1;
		    }
		    elsif ($fm_seq_id =~ m/^>(.*)/) {
			$gff_seq_id = $1;
		    }
		    else {
			$gff_seq_id = $fm_seq_id;
		    }

		    $gff_source = "findmite:".
			$fm_dir_repeats."_".$fm_tir_len;
		    $gff_name = $gff_seq_id."_".$fm_dir_repeats.
			"_".$fm_tir_len."_".$mite_num;
		    $gff_start = $mite_start;
		    $gff_end = $mite_end;

		    print GFFOUT 
			"$gff_seq_id\t".            # Seq name
			"$gff_source\t".            # Source
			"mite\t".                   # Feature type
			"$gff_start\t".             # Start
			"$gff_end\t".               # End
			".\t".                      # Score
			".\t".                      # Strand
			".\t".                      # Frame
			"$gff_name\n";              # Feature name

		    #-----------------------------+
		    # PRINT MITE TO FASTA FILE    |
		    #-----------------------------+
		    if ($fasta_out) {
			print FASTAOUT ">$gff_name\n";
			print FASTAOUT "$mite_seq_string\n";
		    }

		}

		# Reset vals to null
		$fm_seq = "";
	    }

	    $in_seq = 1;
	    $mite_num++;
	    $fm_pattern = $1;
	    print STDERR "$fm_pattern\n" if $verbose;
	}
	elsif(m/^Sequence : (.*)/) {
	    $fm_seq_id = $1;
	    print STDERR "\t$fm_seq_id\n" if $verbose;
	}
	elsif(m/^Mismatch : (.*)/){
	    $fm_num_mismatch = $1;
	    print STDERR "\t$fm_num_mismatch\n" if $verbose;
	}
	elsif($in_seq) {
	    $fm_seq = $fm_seq.$_;
	}
	#-----------------------------+
	# HEADER INFORMATION          | 
	#-----------------------------+
	elsif(m/Direct repeats.{17}(.*)/) {
	    $fm_dir_repeats = $1;
	}
	elsif(m/Length of TIR.{18}(.*)/) {
	    $fm_tir_len = $1;
	}
	elsif(m/Number of mis.{18}(.*)/) {
	    $fm_num_mismatch = $1;
	}
	elsif(m/Filtering A\/T.{18}(.*)/) {
	    $fm_filter_at = $1;
	}
	elsif(m/Filtering C\/G.{18}(.*)/) {
	    $fm_filter_cg = $1;
	}
	elsif(m/Filtering AT\/.{18}(.*)/) {
	    $fm_filter_atta = $1;
	}
	elsif(m/Filtering 2.{20}(.*)/) {
	    $fm_filter_2_base = $1;
	}
	elsif(m/Minimum dist.{19}(.*)/) {
	    $fm_min_dist = $1;
	}
	elsif(m/Maximum dist.{19}(.*)/) {
	    $fm_max_dist = $1;
	}
	elsif(m/The results from the input.{17}(.*)/) {
	    $fm_file_an = $1;
	}

    }

    
    #-----------------------------+
    # PRINT OUT OF DATA IN VARS   |
    #-----------------------------+
    if ($fm_seq =~ m/(.*)\((.*)\)\-{5}(.*)\-{5}\((.*)\)(.*)/) {
    #if ($fm_seq =~ m/(.*)\((.*)\)\-\-\-\-\-(.*)\-\-\-\-\-\((.*)\)(.*)/) {
	$mite_context_5 = $1;
	$mite_start = $2;
	$mite_seq_string = $3;
	$mite_end = $4;
	$mite_context_3 = $5;
	

	if ($verbose) {
	    print STDERR "\t5CON: $mite_context_5\n";
	    print STDERR "\tSTAR: $mite_start\n";
	    print STDERR "\tMITE: $mite_seq_string\n";
	    print STDERR "\tEND : $mite_end\n";
	    print STDERR "\t3CON: $mite_context_3\n";
	    print STDERR "\n\n";
	}	

    }

    #-----------------------------+
    # PRINT TO GFF FILE           |
    #-----------------------------+
    # Parse seq id for shorter name
    if ($fm_seq_id =~ m/^>(\S*)\s./) {
	$gff_seq_id = $1;
    }
    elsif ($fm_seq_id =~ m/^>(.*)/) {
	$gff_seq_id = $1;
    }
    else {
	$gff_seq_id = $fm_seq_id;
    }
    
    $gff_source = "findmite:".
	$fm_dir_repeats."_".$fm_tir_len;
    $gff_name = $gff_seq_id."_".$fm_dir_repeats.
	"_".$fm_tir_len."_".$mite_num;
    $gff_start = $mite_start;
    $gff_end = $mite_end;
    
    print GFFOUT 
	"$gff_seq_id\t".            # Seq name
	"$gff_source\t".            # Source
	"mite\t".                   # Feature type
	"$gff_start\t".             # Start
	"$gff_end\t".               # End
	".\t".                      # Score
	".\t".                      # Strand
	".\t".                      # Frame
	"$gff_name\n";              # Feature name
    
    #-----------------------------+
    # PRINT MITE TO FASTA FILE    |
    #-----------------------------+
    if ($fasta_out) {
	print FASTAOUT ">$gff_name\n";
	print FASTAOUT "$mite_seq_string\n";
    }

    # Print while debu
    if ($verbose) {
	print STDERR "FILE  : $fm_file_an\n";
	print STDERR "DIRREP: $fm_dir_repeats\n";
	print STDERR "TIRLEN: $fm_tir_len\n";
	print STDERR "NUMMIS: $fm_num_mismatch\n";
	print STDERR "F_AT  : $fm_filter_at\n";
	print STDERR "F_CG  : $fm_filter_cg\n";
	print STDERR "F_ATTA: $fm_filter_atta\n";
	print STDERR "F_2BAS: $fm_filter_2_base\n";
	print STDERR "MIN   : $fm_min_dist\n";
	print STDERR "MAX   : $fm_max_dist\n";
    }

    close INFILE;
    close GFFOUT;

}


sub run_findmite {
    # Copied from sub_run in the bioperl 

}

sub print_help {

    # Print requested help or exit.
    # Options are to just print the full 
    my ($opt) = @_;

    my $usage = "USAGE:\n". 
	"batch_findmite.pl -i InDir -o OutDir";
    my $args = "REQUIRED ARGUMENTS:\n".
	"  --indir        # Directory of fasta files to process\n".
	"  --outdir       # Path to the output direcotry\n".
	"  --params       # Path to the params file\n".
	"\n".
	"OPTIONS:\n".
	"  --version      # Show the program version\n".     
	"  --usage        # Show program usage\n".
	"  --help         # Show this help message\n".
	"  --man          # Open full program manual\n".
	"  --quiet        # Run program with minimal output\n";
	
    if ($opt =~ "full") {
	print "\n$usage\n\n";
	print "$args\n\n";
    }
    else {
	print "\n$usage\n\n";
    }
    
    exit;
}


=head1 HISTORY

STARTED: 08/30/2007

UPDATED: 08/31/2007

VERSION: $Id: batch_findmite.pl 95 2007-08-30 15:32:36Z JamesEstill $

=cut

#-----------------------------------------------------------+
# HISTORY                                                   |
#-----------------------------------------------------------+
#
# 08/30/2007
# - Program started
# 08/31/2007
# - Added the gff conversion subfunction from cnv_findmite2gff.pl
