use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(zip min max sum);
use sml; # Statistical Machine Learning Library

# Function To Calculate the Min and Max Values For a Dataset.
# Find the min and max values for each column
sub dataset_minmax{
    my ($self, $dataset) = @_;
    my @minmax;
    for my $i (0 .. $#{$dataset->[0]}){ # Be careful not to include the Y labels
        my $col_values = [map {$_->[$i]} @$dataset];
        my $value_min = min(@$col_values);
        my $value_max = max(@$col_values);
        push @minmax, [$value_min, $value_max];
    }
    return \@minmax;
}
sml->add_to_class('dataset_minmax', \&{'dataset_minmax'});

# Contrive small dataset
my $dataset = [[50, 30], [20, 90]];
printf "Dataset: %s\n", dump $dataset;
# Calculate min and max for each column
my $minmax = sml->dataset_minmax($dataset);
printf "Minimax: %s\n", dump $minmax;
# Output of Example Calculating the Min and Max Values.
# [[50, 30], [20, 90]]
# [[20, 50], [30, 90]]

# Function To Normalize a Dataset.
# Rescale dataset columns to the range 0-1
sub normalize_dataset {
    my ($self, $dataset, $minmax) = @_;
    for my $row (@$dataset) {
        for my $pos (0 .. $#{$row}) {
            # La fórmula es: (valor - min) / (max - min)
            $row->[$pos] = ($row->[$pos] - $minmax->[$pos][0]) / ($minmax->[$pos][1] - $minmax->[$pos][0]);
        }
    }
}
sml->add_to_class('normalize_dataset', \&{'normalize_dataset'});

# Contrive small dataset
$dataset = [[50, 30], [20, 90]];
printf "Dataset: %s\n", dump $dataset;
# Calculate min and max for each column
$minmax = sml->dataset_minmax($dataset);
printf "Minimax: %s\n", dump $minmax;
# Normalize columns
sml->normalize_dataset($dataset, $minmax);
printf "Normalized: %s\n", dump $dataset;
# Example Output of Normalizing the Contrived Dataset.
# [[50, 30], [20, 90]]
# [[20, 50], [30, 90]]
# [[1, 0], [0, 1]]


# Load pima-indians-diabetes dataset
my $filename = 'data/pima-indians-diabetes.csv';
$dataset = sml->load_csv($filename);
printf "Loaded data file %s with %d rows and %d columns.\n\n", $filename, scalar @$dataset, scalar (@{$dataset->[0]});
printf "Dataset[0]: %s\n\n", dump $dataset->[0];
# convert string columns to float
for my $i (0 .. $#{$dataset->[0]}){
sml->str_column_to_float($dataset, $i);
}
printf "Dataset[0]: %s\n\n", dump $dataset->[0];
# Calculate min and max for each column
$minmax = sml->dataset_minmax($dataset);
sml->normalize_dataset($dataset, $minmax);
printf "Normalized: %s\n", dump map {sprintf "%0.2f", $_} @{$dataset->[0]};
# Example Output of Normalizing the Diabetes Dataset.
# Loaded data file pima-indians-diabetes.csv with 768 rows and 9 columns
# Dataset[0]: [6.0, 148.0, 72.0, 35.0, 0.0, 33.6, 0.627, 50.0, 1.0]
# Normalized: Normalized: (0.35, 0.74, 0.59, 0.35, "0.00", "0.50", 0.22, 0.48, "1.00")

# Function To Calculate Means For Each Column in a Dataset.
# Calculate column means
sub column_means{
    my ($self, $dataset) = @_;
    my $means = [0, map {$_} 0 .. $#{$dataset->[0]} -1];
    for my $i (0 .. $#{$dataset->[0]}){
        my $col_values = [map {$_->[$i]} @$dataset];
        $means->[$i] = sum(@$col_values) / scalar(@$dataset);
    }
    return $means;
}
sml->add_to_class('column_means', \&{'column_means'});

# Function To Calculate Standard Deviations For Each Column in a Dataset.
# Calculate column standard deviations
sub column_stdevs{
    my ($self, $dataset, $means) = @_;
    my $stdevs = [0, map {$_} 0 .. $#{$dataset->[0]} -1];
    for my $i (0 .. $#{$dataset->[0]}){
        my $variance = [map {($_->[$i] - $means->[$i]) ** 2} @$dataset];
        $stdevs->[$i] = sum(@$variance);
    }
    $stdevs = [map {sqrt($_ / (scalar(@$dataset) -1))} @$stdevs];
    return $stdevs;
}
sml->add_to_class('column_stdevs', \&{'column_stdevs'});

# Standardize dataset
$dataset = [[50, 30], [20, 90], [30, 50]];
printf "%s\n", dump $dataset;
# Estimate mean and standard deviation
my $means = sml->column_means($dataset);
my $stdevs = sml->column_stdevs($dataset, $means);
printf "Means: %s\n", dump map {sprintf "%0.2f", $_} @$means;
printf "Stdevs: %s\n", dump map {sprintf "%0.2f", $_} @$stdevs;
# Example Output From Calculating Statistics from the Contrived Dataset.
# [[50, 30], [20, 90], [30, 50]]
# Means: (33.33, 56.67)
# Stdevs: (15.28, 30.55)

# Function To Standardize a Dataset.
# Standardize dataset
sub standardize_dataset{
    my ($self, $dataset, $means, $stdevs) = @_;
    for my $row (@$dataset){
        for my $i (0 .. $#$row){
            $row->[$i] = ($row->[$i] - $means->[$i]) / $stdevs->[$i];
        }
    }
}

sml->add_to_class('standardize_dataset', \&{'standardize_dataset'});

$dataset = [[50, 30], [20, 90], [30, 50]];
printf "Means: %s\n", dump map {sprintf "%0.2f", $_} @$means;
printf "Stdevs: %s\n", dump map {sprintf "%0.2f", $_} @$stdevs;
# Standardize dataset
sml->standardize_dataset($dataset, $means, $stdevs);
printf "Normalized: %s\n", dump map { dump map {sprintf "%0.2f", $_} @$_} @$dataset;
# Example Output From Standardizing the Contrived Dataset.
# Means: (33.33, 56.67)
# Stdevs: (15.28, 30.55)
# Standardized: ("(1.09, -0.87)", "(-0.87, 1.09)", "(-0.22, -0.22)")


#Load pima-indians-diabetes dataset
$filename = 'data/pima-indians-diabetes.csv';
$dataset = sml->load_csv($filename);
printf "Loaded data file %s with %d rows and %d columns.\n\n", $filename, scalar @$dataset, scalar (@{$dataset->[0]});
# convert string columns to float
for my $i (0 .. $#{$dataset->[0]}){
sml->str_column_to_float($dataset, $i);
}
printf "Dataset[0]: %s\n\n", dump $dataset->[0];
# Calculate min and max for each column
$minmax = sml->dataset_minmax($dataset);
sml->normalize_dataset($dataset, $minmax);
# Estimate mean and standard deviation
$means = sml->column_means($dataset);
$stdevs = sml->column_stdevs($dataset, $means);
# standardize dataset
sml->standardize_dataset($dataset, $means, $stdevs);
printf "Dataset[0]: %s\n\n", dump map {sprintf "%0.2f", $_} @{$dataset->[0]};
# Example Output From Standardizing the Diabetes Dataset.
# Loaded data file ../data/pima-indians-diabetes.csv with 768 rows and 9 columns.
# Dataset[0]: ["6.0", "148.0", "72.0", "35.0", "0.0", 33.6, 0.6, "50.0", "1.0"]
# Dataset[0]: (0.64, 0.85, 0.15, 0.91, -0.69, "0.20", 0.38, 1.43, 1.37)

