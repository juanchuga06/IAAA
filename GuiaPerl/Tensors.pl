use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(zip min max sum);
use AI::MXNet qw(mx);
use sml;

my $file_path = 'data/pima-indians-diabetes.csv';
my $dataset = sml->load_csv($file_path);
$dataset = mx->nd->array($dataset);

my $dataset_cols = $dataset->slice_axis(axis=>1, begin=>0, end=>-1);


# # print $dataset->slice(begin => [0,0], end => [4,9])->aspdl;
# # print $dataset_cols->slice_axis(axis=>0, begin=>0, end=>4)->aspdl;
# printf "min: %s", $dataset_cols->min(axis=>0)->aspdl;
# printf "min: %s", $dataset_cols->max(axis=>0)->aspdl;

# #Stack()

# printf "MinMax: %s", mx->nd->stack($dataset_cols->min(axis=>0), $dataset_cols->max(axis=>0))->transpose->aspdl; 

sub dataset_minmax{
        my ($self, $dataset) = @_;
        return mx->nd->stack($dataset->min(axis=>0), $dataset->max(axis=>0))->transpose;
    }
sml->add_to_class('dataset_minmax', \&{'dataset_minmax'});

my $minmax = sml->dataset_minmax($dataset_cols);
print $minmax->aspdl;

# my ($min, $max) = @{$minmax->transpose};
# printf $min->aspdl;
# printf $max->aspdl;
# my $scaled_value = ($dataset_cols - $min) / ($max - $min);
# printf "Seccion Norm: %s", $scaled_value->slice(begin=>[0,0], end=>[4,8])->aspdl;

sub normalize_dataset {
    my ($self, $dataset, $minmax) = @_;
    my ($min, $max) = @{$minmax->transpose};
    return ($dataset - $min) / ($max - $min);
}
sml->add_to_class('normalize_dataset', \&{'normalize_dataset'});

my $normalized_dataset = sml->normalize_dataset($dataset_cols, $minmax);
print $normalized_dataset->slice(begin => [0,0], end => [4,8])->aspdl;

# printf "means: %s", $dataset_cols->mean(axis=>0)->aspdl;

sub column_means{
        my ($self, $dataset) = @_;
        return $dataset->mean(axis=>0);
    }
sml->add_to_class('column_means', \&{'column_means'});

my $means = sml->column_means($dataset_cols);
printf "means: %s", $means->aspdl;


# my $stdev = (($dataset_cols - $means)->power(2)->sum(axis=>0) / ($dataset_cols->len - 1))->sqrt;

# printf $stdev->aspdl;

 sub column_stdevs{
        my ($self, $dataset, $means) = @_;
        return mx->nd->sqrt(($dataset - $means)->power(2)->sum(axis=>0) / ($dataset->len - 1));
    }

sml->add_to_class('column_stdevs', \&{'column_stdevs'});

my $stdev_dataset = sml->column_stdevs($dataset_cols, $means);
printf $stdev_dataset->aspdl;


sub standardize_dataset{
        my ($self, $dataset, $means, $stdevs) = @_;
        return ($dataset - $means) / $stdevs;
    }

sml->add_to_class('standardize_dataset', \&{'standardize_dataset'});

my $stand_dataset = sml->standardize_dataset($dataset_cols, $means, $stdev_dataset);
printf $stand_dataset->slice(begin => [0,0], end => [4,8])->aspdl;

