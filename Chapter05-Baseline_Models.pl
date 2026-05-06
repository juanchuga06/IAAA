use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(zip min max sum);
use AI::MXNet qw(mx);
use sml;

mx->nd->random->seed(1);

# Example of Making Random Predictions
# Defined in Section 5.2.1 Random Prediction Algorithm
# Example of Making Random Predictions
# Generate random predictions
sub random_algorithm {
    my ($self, $train, $test) = @_;
    my $train_labels = $train->slice_axis(axis => 1, begin => $train->shape->[1] - 1, end => $train->shape->[1]);
    my $max_value = int(mx->nd->max($train_labels)->asscalar()) + 1;
    my $predicted = mx->nd->random->randint(0, $max_value, shape => [$test->len]);
    return $predicted;
}
sml->add_to_class('random_algorithm', \&{'random_algorithm'});

my ($dataset, $header) = sml->load_csv('data/iris.csv');
sml->str_column_to_int($dataset, -1);
$dataset = mx->nd->array($dataset);
my $dataset_cols = $dataset->slice_axis(axis  => 1, begin => 0, end => $dataset->shape->[1]);

my ($train, $test) = sml->train_test_split($dataset_cols);
printf "train size:%s, test size:%s", dump($train->shape), dump($test->shape);

my $predictions = sml->random_algorithm($train, $test);
printf $predictions->aspdl;

# Example of Zero Rule Classification Predictions
# Defined in Section 5.2.2 Zero Rule Algorithm: Classification
# Function To Make Zero Rule Classification Predictions.
# zero rule algorithm for classification
sub zero_rule_algorithm_classification{
  my ($self, $train, $test) = @_ ;
  my $output_values = $train->slice_axis(axis=>1, begin=>-1, end=>$train->shape->[-1]);
  my $num_classes   = $output_values->max->asscalar + 1;
  my $count         = mx->nd->one_hot($output_values, $num_classes)->sum(axis=>0);
  my $prediction    = mx->nd->argmax($count);
  return mx->nd->full([$test->len], $prediction->asscalar);
}

sml->add_to_class('zero_rule_algorithm_classification', \&{'zero_rule_algorithm_classification'});

($dataset, $header) = sml->load_csv('data/golf.csv');
my @lookup = map{sml->str_column_to_int($dataset, $_)} (0 .. $#{$dataset->[0]});
$dataset = mx->nd->array($dataset);

$dataset_cols = $dataset->slice_axis(axis  => 1, begin => 0, end => $dataset->shape->[1]);
($train, $test) = sml->train_test_split($dataset_cols);
printf "train size:%s, test size:%s", dump($train->shape), dump($test->shape);

$predictions = sml->zero_rule_algorithm_classification($train, $test);

printf "predictions: %s\n", $predictions->aspdl;
printf "lookup: %s\n", dump @lookup;


# Function To Make Zero Rule Regression Predictions.
# zero rule algorithm for regression
sub zero_rule_algorithm_regression{
  my ($self, $train, $test) = @_ ;
  my $output_values = $train->slice_axis(axis=>1, begin=>-1, end=>$train->shape->[-1]);
  my $prediction = sprintf('%0.1f', mx->nd->mean($output_values)->asscalar);
  return mx->nd->full([$test->len], $prediction); # predictions
}
 
sml->add_to_class('zero_rule_algorithm_regression', \&{'zero_rule_algorithm_regression'});

srand(1);
$train = mx->nd->array([[10], [15.1], [12], [15], [18], [20]]);
$test = mx->nd->array([[undef], [undef], [undef], [undef]]);
$predictions = sml->zero_rule_algorithm_regression($train, $test);
print $predictions->aspdl;
