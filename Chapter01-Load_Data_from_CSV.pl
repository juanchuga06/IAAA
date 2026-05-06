# Load libraries
use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(uniq);
use Tie::IxHash;
use FindBin;
use lib $FindBin::Bin;
use sml;
use AI::MXNet qw(mx);

# Defined in Section 1.2.1 Load CSV File
# Function for loading a CSV

# Load a CSV file
sub load_csv{
    my ($self, $file_path, %args) = (splice(@_, 0, 2), delimiter => '[,;\t]', @_);

    open (FILE, "<", $file_path) or die "Cannot open file $file_path: $!";
    my $header = <FILE>;
    chomp($header);
    my @dataset = ();
    while (<FILE>){
        my $row = $_;
        $row =~ s/[\r\n]+$//g; # Regular expression that deletes characters such as \r \n
        next if (!defined $row || $row =~ /^\s*$/);
        push @dataset, [split /$args{delimiter}/, $row];
    }
    close FILE;

    return wantarray ? (\@dataset, $header) : \@dataset;
}

sml->add_to_class('load_csv', \&{'load_csv'});

# Load pima-indians-diabetes dataset
my $filename = 'data/pima-indians-diabetes.csv';
my ($dataset, $header) = sml->load_csv($filename);
# printf "Loaded data file %s with %d rows and %d columns.\n", 
        # $filename, scalar (@$dataset), scalar (@{$dataset->[0]});

# printf "%s\n%s\n", $header, dump @$dataset[0 .. 4];
# # Alternative way to print a data sample:
# # print "@$_\n" for @$dataset[0 .. 4];

# # We can also get the just the data without its header, thanks to 'wantarray()' command
# # which differentiates between scalar and array contexts.
# my $new_dataset = sml->load_csv($filename); #Referencia al array del dataset
# printf "%s\n", dump @$new_dataset[0 .. 4];

#Convert String to Floats
# printf "row[0]: %s\n", dump $dataset->[0];


# Defined in Section 1.2.2 Convert String to Floats
# Function For Converting String Data To Floats.
# Convert string columns to float
sub str_column_to_float{
    my ($self, $dataset, $column, %args) = (splice (@_, 0, 3), precision=>1, @_);   
    return if ($dataset->[0][$column] !~ /^\d+/);   
    $args{precision} = '%.' . $args{precision} . 'f';
    for my $row (@$dataset){
        $row->[$column] = sprintf ($args{precision}, $row->[$column]);
    }
}
sml->add_to_class('str_column_to_float', \&{'str_column_to_float'});



# ($dataset, $header) = sml->load_csv($filename);
# printf "Loaded data file %s with %d rows and %d columns.\n",
#         $filename, scalar (@$dataset), scalar (@{$dataset->[0]});
# printf "Header: %s\n", $header;
# printf "Strings: %s\n", dump $dataset->[0];
# # convert string columns to float
# for my $i (0 .. $#{$dataset->[0]} -1){
#     sml->str_column_to_float($dataset, $i);
# }
# printf "Floats: %s", dump $dataset->[0];


# Defined in Section 1.2.3 Convert String to Integers
# Function To Integer Encode String Class Values.
# Convert string column to integer
sub str_column_to_int{
    my ($self, $dataset, $column) = @_; 
    my $class_values = [map {$_->[$column]} @$dataset];
    my @unique = uniq @$class_values;
    my %lookup = ();
    while (my ($i, $value) = each @unique) {
        $lookup{$value} = $i;
    }
    for my $row (@$dataset){
        $row->[$column] = $lookup{$row->[$column]};
    }

    return \%lookup;
}
sml->add_to_class('str_column_to_int', \&{'str_column_to_int'});

# Load iris dataset
$filename = 'data/iris.csv';
($dataset, $header) = sml->load_csv($filename);
print sprintf "Loaded data file %s with %d rows and %d columns.\n\n",
 $filename, scalar(@$dataset), scalar(@{$dataset->[0]});

printf "Before label conversion into integers:\n\n%s\n%s\n\n", $header, dump @$dataset[0...4];
# convert string columns to float
for my $i (0 .. $#{$dataset->[0]} -1){
    sml->str_column_to_float($dataset, $i);
}
# convert class column to int
my $lookup = sml->str_column_to_int($dataset, -1);
printf "After label conversion into integers:\n\n%s\n%s\n\n", $header, dump @$dataset[0...4];
printf "Conversion dictionary: %s\n", dump $lookup;


my $tensor = mx->nd->array($dataset);
printf "Tensor: %s\n", $tensor;
printf "Tensor: %s\n", $tensor->slice_axis(axis=>0, begin=>0, end=>5)->aspdl;