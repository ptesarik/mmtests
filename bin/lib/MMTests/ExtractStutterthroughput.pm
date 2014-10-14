# ExtractStutterthroughput.pm
package MMTests::ExtractStutterthroughput;
use MMTests::SummariseMultiops;
use VMR::Stat;
our @ISA = qw(MMTests::SummariseMultiops);

use strict;
my @_threads;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "ExtractStutter",
		_DataType    => MMTests::Extract::DATA_MBYTES_PER_SECOND,
		_ResultData  => [],
	};
	bless $self, $class;
	return $self;
}

sub extractReport($$$) {
	my ($self, $reportDir, $reportName) = @_;
	my ($user, $system, $elapsed, $cpu);
	$reportDir =~ s/stutterthroughput/stutter/;

	# Extract calibration write test throughput
	my $file = "$reportDir/noprofile/calibrate.time";
	open(INPUT, $file) || die("Failed to open $file\n");
	my @elements = split(/ /, <INPUT>);
	@elements = split(/:/, $elements[2]);
	close(INPUT);
	push @{$self->{_ResultData}}, [ "PotentialWriteSpeed", 1, (1024) / ($elements[0] * 60 + $elements[1]) ];

	# Extract filesize of write
	my $file = "$reportDir/noprofile/dd.filesize";
	open(INPUT, $file) || die("Failed to open $file\n");
	my $filesize = <INPUT>;
	close(INPUT);

	# Extract calibration write test throughput
	my @files = <$reportDir/noprofile/time.*>;
	my $nr_samples = 0;
	foreach my $file (@files) {
		open(INPUT, $file) || die("Failed to open $file\n");
		my @elements = split(/ /, <INPUT>);
		@elements = split(/:/, $elements[2]);
		push @{$self->{_ResultData}}, [ "tput", ++$nr_samples, $filesize / 1048576 / ($elements[0] * 60 + $elements[1]) ];
		close(INPUT);
	}

	$self->{_Operations} = [ "tput" ];
}
1;
