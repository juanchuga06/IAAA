use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(zip min max sum);
use AI::MXNet qw(mx);
use sml;

# Defined in Section 6.2.1 Train-Test Algorithm Test Harness
# Function To Evaluate An Algorithm Using a Train/Test Split.
# Evaluate an algorithm using a train/test split
sub evaluate_algorithm_train_test_split{
    my ($self, $dataset, $algorithm, %args) = ((splice @_, 0, 3), split=>0.6, metric=>undef, @_);

    my ($train, $test) = sml->train_test_split($dataset, split=>$args{split});
    my ($actual, $predicted, $score);
    $predicted = $algorithm->('sml', $train, $test, @_);
    $actual = $test->slice_axis(axis=>1, begin=>-1, end=>$test->shape->[-1]);

    # Regression : Classification
    if (defined $args{metric}){
    if ($args{metric} =~ /accuracy/i) {
    $score = sml->accuracy_metric($actual, $predicted);
    }elsif($args{metric} =~ /rmse/i){
    $score = sml->rmse_metric($actual, $predicted);
    }
    }else{
        $score = ($actual->dtype =~ /float/) ? sml->rmse_metric($actual, $predicted) : sml->accuracy_metric($actual, $predicted);
    }
    return wantarray ? ($score, $train, $test, $actual, $predicted) : $score;
}
sml->add_to_class('evaluate_algorithm_train_test_split', \&{'evaluate_algorithm_train_test_split'});

# Example of Train/Test Algorithm Test Harness on the Diabetes Dataset.
# Test the train/test harness
srand(1);
# load and prepare data
my $filename = 'data/pima-indians-diabetes.csv';
my $dataset = sml->load_csv($filename);
for my $i (0 .. $#{$dataset->[0]}){
    sml->str_column_to_float($dataset, $i);
}
# evaluate algorithm
$dataset = mx->nd->array($dataset);
my $dataset_cols = $dataset->slice_axis(axis=>1, begin=>0, end=>$dataset->shape->[1]); #Todas las columnas incluyendo a la ultima
my $split = 0.6;
my ($accuracy, $train, $test, $actual, $predicted) = sml->evaluate_algorithm_train_test_split(
                                                    $dataset_cols,
                                                    \&{'sml::zero_rule_algorithm_classification'},
                                                    split => $split,
                                                    metric => 'accuracy');
printf 'Accuracy: %0.2f%%', $accuracy;


my $matrix = sml->confusion_matrix($actual, $predicted);
printf "Matriz de confusion: %s\n", $matrix->aspdl; 



sub evaluate_algorithm_cross_validation_split{
    my ($self, $dataset, $algorithm) = splice @_, 0, 3;
    my %args = (n_folds => 10, metric => undef, @_);
    
    my @folds = @{sml->cross_validation_split($dataset, n_folds=>$args{n_folds})}; #SE REDUCEN 1 DIMENSION,LA MAS EXTERNA
    my (@scores, @train_losses, @test_losses, @actuals, @predictions);
    
    my $num_features = $dataset->shape->[1];

    for my $i (0 .. $args{n_folds} - 1) {
        
        my @train_set = @folds;
        my $test_set = splice @train_set, $i, 1;
        my $train_set = mx->nd->concat(@train_set, dim=>0);
        
        my ($predicted, $train_loss, $test_loss) = $algorithm->('sml', $train_set, $test_set, %args);

        my $last_col_idx = $num_features - 1;
        my $actual = $test_set->slice_axis(axis => 1, begin => $last_col_idx, end => $last_col_idx + 1)->squeeze();

        my $score;
        if (defined $args{metric}) {
            if ($args{metric} =~ /accuracy/i) {
                $score = sml->accuracy_metric($actual, $predicted);
            } elsif ($args{metric} =~ /rmse/i) {
                $score = sml->get_RMSE($actual, $predicted);
            }
        } else {
            $score = ($actual->dtype =~ /float/) ? sml->rmse_metric($actual, $predicted) : sml->accuracy_metric($actual, $predicted);
        }

        push @scores, $score;
        push @train_losses, $train_loss if defined $train_loss;
        push @test_losses, $test_loss if defined $test_loss;
        push @actuals, $actual;
        push @predictions, $predicted;
    }

    return wantarray ? (\@scores, \@train_losses, \@test_losses, \@actuals, \@predictions) : \@scores;
}

sml->add_to_class('evaluate_algorithm_cross_validation_split', \&{'evaluate_algorithm_cross_validation_split'});
srand(1);
# evaluate algorithm
my $n_folds = 5;
my ($scores, $train_losses, $test_losses, $actuals, $predictions) = sml->evaluate_algorithm_cross_validation_split($dataset_cols,
                                                                                                                    \&{'sml::zero_rule_algorithm_classification'},
                                                                                                                    n_folds => $n_folds,
                                                                                                                    metric => 'accuracy');
printf "Scores: %s\n", dump @$scores;
printf "Mean Accuracy: %0.2f%%", sum(@$scores) / @$scores;
