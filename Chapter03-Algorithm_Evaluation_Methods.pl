use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(shuffle);
use AI::MXNet qw(mx);
use sml;


my $file_path = 'data/pima-indians-diabetes.csv';
my $dataset = sml->load_csv($file_path);
$dataset = mx->nd->array($dataset);

my $dataset_cols = $dataset->slice_axis(axis=>1, begin=>0, end=>-1);

sub train_test_split {
    my ($self, $dataset, %args) = (splice (@_, 0, 2), split => 0.6, @_);
    
    my $train_size = int($args{split} * $dataset->len);
    my $idx = mx->nd->arange(stop=>$dataset->len)->shuffle;


    my $train_idx = $idx->slice(begin=>0,end=>$train_size);
    my $test_idx = $idx->slice(begin=>$train_size,end=>$dataset->len);

    my $train = mx->nd->take($dataset, $train_idx);
    my $test = mx->nd->take($dataset, $test_idx);

    return $train, $test;
}

sml->add_to_class('train_test_split', \&{'train_test_split'});

my ($train, $test) = sml->train_test_split($dataset_cols);

printf "Train: %s", dump $train->shape;
printf "Train: %s", $train->slice(begin=>[0,0], end=>[4,8])->aspdl;
printf "Test: %s", dump $test->shape;
printf "Test: %s", $test->slice(begin=>[0,0], end=>[4,8])->aspdl;

sub cross_validation_split {
    my ($self, $dataset, %args) = (splice(@_, 0, 2), n_folds => 10, @_);

    my @dataset_split;
    my $fold_size = int($dataset->len / $args{n_folds});
    
    my $idx = mx->nd->arange(start => 0, stop => $dataset->len)->shuffle;
    
    for my $i (0 .. $args{n_folds} - 1) {
        my $begin = $i * $fold_size;
        my $end   = ($i + 1) * $fold_size;
        my $fold_idx = $idx->slice_axis(axis => 0, begin => $begin, end => $end);
        my $fold_tensor = mx->nd->take($dataset, $fold_idx);
        push @dataset_split, $fold_tensor;
    }
 
    return mx->nd->stack(@dataset_split, axis => 0);
}
sml->add_to_class('cross_validation_split', \&{'cross_validation_split'});

my $dataset_folds = sml->cross_validation_split($dataset_cols);

for my $i (0 .. $dataset_folds->shape->[0] - 1) {
    print "Sección del Fold $i\n";
    my $seccion = $dataset_folds->slice(
        begin => [$i, 0, 0], 
        end   => [$i+1, 4, 8]
    );
    print $seccion->squeeze(axis => 0)->aspdl . "\n";
}

my $header;
# Siguiendo la seccion
($dataset, $header) = sml->load_csv('data/iris.csv');
printf "rows: %d\n", scalar @$dataset;
printf "cols: %d\n", scalar @{$dataset->[0]};
print dump @$dataset[0 .. 4];


my $lookup = sml->str_column_to_int($dataset, -1);
my $rev_lookup = {reverse %$lookup};
$dataset = mx->nd->array($dataset);
$dataset_cols = $dataset->slice_axis(
    axis  => 1, 
    begin => 0, 
    end   => $dataset->shape->[1]
);
printf $dataset->slice(begin=>[0,0], end=>[4,4])->aspdl;

sub count_labels {
    my ($self, $dataset) = @_;
    
    my $num_cols = $dataset->shape->[1];
    
    my $Y_tensor = $dataset->slice_axis(
        axis  => 1, 
        begin => $num_cols - 1, 
        end   => $num_cols
    )->squeeze;
    
    my $num_rows = $Y_tensor->shape->[0];
    my %counts = ();

    for my $i (0 .. $num_rows - 1) {
        my $label_int = int($Y_tensor->at($i)->asscalar());
        $counts{$label_int}++;
    }
    
    return \%counts;
}
sml->add_to_class('count_labels', \&{'count_labels'});

my $counts = sml->count_labels($dataset_cols);
print dump $counts;

for my $key (keys %$counts){
 printf "%s => %d ", $rev_lookup->{$key}, $counts->{$key};
}

srand(1);
($train, $test) = sml->train_test_split($dataset_cols, split=>0.8);
printf "train size:%s, test size:%s", dump($train->shape), dump($test->shape);

print dump (sml->count_labels($train));
# { "Iris-setosa" => 40, "Iris-versicolor" => 42, "Iris-virginica" => 38 }

print $train->slice(begin=>[0,0], end=>[9,5])->aspdl;
print $test->slice(begin=>[0,0], end=>[9,5])->aspdl;


srand(1);
my $folds = sml->cross_validation_split($dataset_cols, n_folds=>10);
for my $i (0 .. $dataset_folds->shape->[0] - 1) {
    print "Sección del Fold $i\n";
    my $seccion = $dataset_folds->slice(
        begin => [$i, 0, 0], 
        end   => [$i+1, 4, 8]
    );
    print $seccion->squeeze(axis => 0)->aspdl . "\n";
}

printf "rows per fold:%s\n", $folds->shape->[1];

my $num_folds = $folds->shape->[0];
for my $i (0 .. $num_folds - 1) {
    my $current_fold = $folds->slice_axis(
        axis  => 0, 
        begin => $i, 
        end   => $i + 1
    )->squeeze(axis => 0);
    my $medicion = sml->count_labels($current_fold);
    printf "Fold %d: %s\n", $i, dump($medicion);
}