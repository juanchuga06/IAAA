package sml{
    use strict;
    use warnings;
    use Data::Dump qw(dump);
    use List::Util qw(zip min max sum uniq all any shuffle);
    use Tie::IxHash;  
    use AI::MXNet qw(mx);

    sub add_to_class{ #@save
        # Register functions as methods in created class.
        my($class, $method_name, $code_ref) = @_;   
        {
            # We need to use symbolic references.
            no strict 'refs';
            no warnings;
            # Shove the code reference into the class' symbol table.
            *{$class.'::'.$method_name} = $code_ref;
        }
    } 

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

    sub dataset_minmax{
        my ($self, $dataset) = @_;
        return mx->nd->stack($dataset->min(axis=>0), $dataset->max(axis=>0))->transpose;
    }



    sub normalize_dataset {
        my ($self, $dataset, $minmax) = @_;
        my ($min, $max) = @{$minmax->transpose};
        return ($dataset - $min) / ($max - $min);
    }



    sub column_means{
        my ($self, $dataset) = @_;
        return $dataset->mean(axis=>0);
    }



    sub column_stdevs{
        my ($self, $dataset, $means) = @_;
        return mx->nd->sqrt(($dataset - $means)->power(2)->sum(axis=>0) / ($dataset->len - 1));
    }


    sub standardize_dataset{
        my ($self, $dataset, $means, $stdevs) = @_;
        return ($dataset - $means) / $stdevs;
    }



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

    sub accuracy_metric {
        my ($self, $actual, $predicted) = @_;
        return sprintf '%0.2f', mx->nd->mean($actual == $predicted)->asscalar * 100.0;
    }

    sub confusion_matrix {
        my ($self, $actual, $predicted) = @_;
        my $num_labels = int(mx->nd->max($actual)->asscalar()) + 1;
        my $actual_oh = mx->nd->one_hot($actual, $num_labels);
        my $pred_oh   = mx->nd->one_hot($predicted, $num_labels);
        return mx->nd->dot($pred_oh->transpose, $actual_oh)->squeeze->transpose;
    }
    

    # Function to calculate the integral using the trapezoid rule
    sub trapz{
        my ($self, $x, $y) = @_;

        my $dx = $x->slice(begin=>1, end=>$x->shape->[-1])
            - $x->slice(begin=>0, end=>-1);

        my $avg_y = ($y->slice(begin=>1, end=>$y->shape->[-1])
                + $y->slice(begin=>0, end=>-1)) / 2;

        return sprintf '%0.2f', mx->nd->sum($dx * $avg_y)->asscalar;
    }

    sub mae_metric{
        my ($self, $actual, $predicted) = @_;

        return (mx->nd->abs($predicted - $actual)->sum(axis=>0) / $predicted->shape->[0])->asscalar();
    }
    sub rmse_metric{
        my ($self, $actual, $predicted) = @_;
        return mx->nd->sqrt(($predicted - $actual)->power(2)->sum(axis=>0) / ($predicted->shape->[0]))->asscalar();
    }

    # Function to calculate the ROC metrics by using one-hot encoding and dot product
    sub perf_metrics{
        my ($self, $actual, $predicted_prob, $threshold) = @_;

        my ($tp, $fp, $tn, $fn, $tpr, $fpr) = (0, 0, 0, 0);
        
        # Step 1: Threshold to create binary predictions
        my $predicted = $predicted_prob >= $threshold;

        # Step 2: Convert actual and predicted to one-hot encoded matrices
        my $num_classes       = $actual->max->asscalar + 1;
        my $actual_one_hot    = mx->nd->one_hot($actual, $num_classes);    # Shape [n, $num_classes]
        my $predicted_one_hot = mx->nd->one_hot($predicted, $num_classes); # Shape [n, $num_classes]

        # Step 3: Compute confusion matrix using dot product
        my $confusion_matrix  = mx->nd->dot($actual_one_hot->T, $predicted_one_hot);

        # Extract counts from the confusion matrix
        $tp = $confusion_matrix->at(0, 0)->asscalar; # True Positives
        $fn = $confusion_matrix->at(0, 1)->asscalar; # False Negatives
        $fp = $confusion_matrix->at(1, 0)->asscalar; # False Positives
        $tn = $confusion_matrix->at(1, 1)->asscalar; # True Negatives

        # Step 4: Compute TPR and FPR
        $tpr = $tp / ($tp + $fn); # True Positive Rate
        $fpr = $fp / ($fp + $tn); # False Positive Rate

        return sprintf('%0.2f', $fpr), sprintf('%0.2f', $tpr);
    }


    sub random_algorithm{
        my ($self, $train, $test) = @_;
        my $output_values = $train->slice_axis(axis=>1, begin=>-1, end=>$train->shape->[-1]);
        my $max_value = $output_values->max->asscalar + 1;
        return mx->nd->random->randint(0, $max_value, shape=> [$test->len]);
    }

    sub zero_rule_algorithm_classification{
        my ($self, $train, $test) = @_;
        my $output_values = $train->slice_axis(axis=>1, begin=>-1, end=>$train->shape->[-1]);
        my $num_classes   = $output_values->max->asscalar + 1;
        my $count         = mx->nd->one_hot($output_values, $num_classes)->sum(axis=>0);
        my $prediction    = mx->nd->argmax($count);
        return mx->nd->full([$test->len], $prediction->asscalar);
    }

    sub zero_rule_algorithm_regression{
        my ($self, $train, $test) = @_ ;
        my $output_values = $train->slice_axis(axis=>1, begin=>-1, end=>$train->shape->[-1]);
        my $prediction = sprintf('%0.1f', mx->nd->mean($output_values)->asscalar);
        return mx->nd->full([$test->len], $prediction);
    }


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
                my $is_integer = ($actual == $actual->round())->sum()->asscalar == $actual->size;
                $score = $is_integer ? sml->accuracy_metric($actual, $predicted) : sml->get_RMSE($actual, $predicted);
            }

            push @scores, $score;
            push @train_losses, $train_loss if defined $train_loss;
            push @test_losses, $test_loss if defined $test_loss;
            push @actuals, $actual;
            push @predictions, $predicted;
        }

        return wantarray ? (\@scores, \@train_losses, \@test_losses, \@actuals, \@predictions) : \@scores;
    }

    1;
}
