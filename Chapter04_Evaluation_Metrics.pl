use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(zip min max sum uniq);
use sml; # Statistical Machine Learning Library
use AI::MXNet qw(mx);
use sml;
use Chart::Plotly qw(show_plot);
use Chart::Plotly::Trace::Scatter;
use Chart::Plotly::Plot;


sub confusion_matrix {
    my ($actual, $predicted) = @_;
    my $num_labels = int(mx->nd->max($actual)->asscalar()) + 1;
    my $actual_oh = mx->nd->one_hot($actual, $num_labels);
    my $pred_oh   = mx->nd->one_hot($predicted, $num_labels);
    return mx->nd->dot($pred_oh->transpose, $actual_oh);
}

sml->add_to_class('confusion_matrix', \&{'confusion_matrix'});

# Example Output From Printing a Pretty Confusion Matrix.
# Test confusion matrix with integers
my $actual = mx->nd->array([0,0,0,0,0,1,1,1,1,1]);
my $predicted = mx->nd->array([0,1,1,0,0,1,0,1,1,1]);
my  $matrix = confusion_matrix($actual, $predicted);
printf $matrix->aspdl;


# Function To Calculate Mean Absolute Error.
# Calculate mean absolute error
sub mae_metric{
    my ($self, $actual, $predicted) = @_;

    return (mx->nd->abs($predicted - $actual)->sum(axis=>0) / $predicted->shape->[0])->asscalar();
}

sml->add_to_class('mae_metric', \&{'mae_metric'});

# Small Set of Contrived Regression Predictions and Actual Values.
$actual = mx->nd->array([0.1, 0.2, 0.3, 0.4, 0.5]);
$predicted = mx->nd->array([0.11, 0.19, 0.29, 0.41, 0.5]);
print $predicted->len;
print "actual\tpredicted\n";
printf $actual->aspdl . "\n" . $predicted->aspdl;

# Test MAE
my $mae = sml->mae_metric($actual, $predicted);
print $mae;


# Defined in Section 4.2.4 Root Mean Squared Error
# Function To Calculate Root Mean Squared Error.
# Calculate root mean squared error
sub rmse_metric{
    my ($self, $actual, $predicted) = @_;
    return mx->nd->sqrt(($predicted - $actual)->power(2)->sum(axis=>0) / ($predicted->shape->[0]))->asscalar();
}
sml->add_to_class('rmse_metric', \&{'rmse_metric'});

# Test RMSE
$actual = mx->nd->array([0.1, 0.2, 0.3, 0.4, 0.5]);
$predicted = mx->nd->array([0.11, 0.19, 0.29, 0.41, 0.5]);
my $rmse = sml->rmse_metric($actual, $predicted);
print $rmse;





# sub perf_metrics {
#     my ($self, $actual, $predicted_prob, $threshold) = @_;

#     my $pred_binary = $predicted_prob >= $threshold;

#     my $matrix_tensor = sml->confusion_matrix($actual, $pred_binary);

#     my $tn = $matrix_tensor->at(0)->at(0)->asscalar(); 
#     my $fn = $matrix_tensor->at(0)->at(1)->asscalar(); 
#     my $fp = $matrix_tensor->at(1)->at(0)->asscalar(); 
#     my $tp = $matrix_tensor->at(1)->at(1)->asscalar(); 

#     my $tpr = ($tp + $fn) > 0 ? $tp / ($tp + $fn) : 0;
#     my $fpr = ($fp + $tn) > 0 ? $fp / ($fp + $tn) : 0;

#     return (sprintf('%0.2f', $fpr), sprintf('%0.2f', $tpr));
# }


# sml->add_to_class('perf_metrics', \&{'perf_metrics'});

# # Function to calculate the integral using the trapezoid rule
# sub trapz{
#     my ($self, $x, $y) = @_;

#     my $dx = $x->slice(begin=>1, end=>$x->shape->[-1])
#            - $x->slice(begin=>0, end=>-1);

#     my $avg_y = ($y->slice(begin=>1, end=>$y->shape->[-1])
#               + $y->slice(begin=>0, end=>-1)) / 2;

#     return sprintf '%0.2f', mx->nd->sum($dx * $avg_y)->asscalar;
# }


# sml->add_to_class('trapz', \&{'trapz'});


# my ($dataset, $header) = sml->load_csv('data/model.csv');

# $dataset = mx->nd->array($dataset);

# my $class = $dataset->slice_axis(axis  => 1, begin => 1, end => 2)->squeeze;

# my $predicted_prob = $dataset->slice_axis(axis  => 1, begin => 2, end => 3)->squeeze;

# print "class:\n";
# print $class->slice_axis(axis => 0, begin => 0, end => 5)->aspdl;

# print "predicted_prob:\n";
# print $predicted_prob->slice_axis(axis => 0, begin => 0, end => 5)->aspdl;


# # Calculate TPR and FPR for a specific threshold
# my ($fpr, $tpr) = sml->perf_metrics($class, $predicted_prob, 0.5);
# # Print sensitivity and specificity
# printf "Sensibilidad: %.2f, Especificidad: %.2f\n", $tpr, 1 - $fpr;


# # Calculate TPR and FPR for various decision thresholds
# my $thresholds = mx->nd->arange(start => 0, stop => 21) / 20;
# print $thresholds->aspdl;


# my ($fprs, $tprs) = zip( map { [sml->perf_metrics($class, $predicted_prob, $_)] } @$thresholds );
# printf "fprs: %s\ntprs: %s\n", "@$fprs", "@$tprs";


# # Plot the ROC curve using Chart::Plotly
# my $trace1 = new Chart::Plotly::Trace::Scatter(
#     x => $fprs,
#     y => $tprs,
#     mode => 'lines',
#     name => 'ROC Curve'
# );

# my $trace2 = new Chart::Plotly::Trace::Scatter(
#     x => [0, 1],
#     y => [0, 1],
#     mode => 'lines',
#     name => 'ROC Curve'
# );

# my $chart = new Chart::Plotly::Plot(
#     traces => [$trace1, $trace2],
#     layout => {
#         title => 'ROC curve',
#         xaxis => { title => 'False Positive Rate (FPR)' },
#         yaxis => { title => 'True Positive Rate (TPR)' }
#     }
# );

# show_plot($chart);


# # Calculate the area under the ROC curve (AUC)
# # First, sort the points by ascending FPR
# my @sorted_indices = sort { $fprs->[$a] <=> $fprs->[$b] } 0 .. $#$fprs;
# my $sorted_fprs = mx->nd->array([@$fprs[@sorted_indices]]);
# my $sorted_tprs = mx->nd->array([@$tprs[@sorted_indices]]);

# # Then, calculate the AUC using the trapezoid rule
# my $auc = sml->trapz($sorted_fprs, $sorted_tprs);
# printf "Area under the ROC curve (AUC): %0.2f\n", $auc;

use Chart::Plotly qw(show_plot);
use Chart::Plotly::Plot;
use Chart::Plotly::Trace::Scatter;

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

sml->add_to_class('perf_metrics', \&{'perf_metrics'});

my ($dataset, $header) = sml->load_csv('data/model.csv');
$dataset = mx->nd->array($dataset);

my $predicted_prob;
(undef, $actual, $predicted_prob) = @{$dataset->T};

printf "class: %s\n",        $actual->slice(begin=>0, end=>5)->aspdl;
printf "predicted_prob: %s\n", $predicted_prob->slice(begin=>0, end=>5)->aspdl;

# Calculate TPR and FPR for a specific threshold
my ($fpr, $tpr) = sml->perf_metrics($actual, $predicted_prob, 0.5);

# Print sensitivity and specificity
printf "tpr: %s, 1 - fpr: %s\n", $tpr, 1 - $fpr;

# Calculate TPR and FPR for various decision thresholds
my $thresholds = mx->nd->arange(stop=>101) / 100;
printf "thresholds: %s\n", $thresholds->slice(begin=>0, end=>5)->aspdl;

my ($fprs, $tprs) = (zip map {[sml->perf_metrics($actual, $predicted_prob, $_)]} @$thresholds);

printf "fprs:%s\n", "@$fprs";
printf "tprs:%s\n", "@$tprs";

# Plot the ROC curve using Chart::Plotly
my $trace1 = new Chart::Plotly::Trace::Scatter(
  x => $fprs,
  y => $tprs,
  mode => 'lines',
  name => 'ROC Curve'
);

my $trace2 = new Chart::Plotly::Trace::Scatter(
  x => [0, 1],
  y => [0, 1],
  mode => 'lines',
  name => 'Reference Curve'
);

my $chart = new Chart::Plotly::Plot(
  traces => [$trace1, $trace2],
  layout => {
    title => 'ROC curve',
    xaxis => { title => 'False Positive Rate (FPR)' },
    yaxis => { title => 'True Positive Rate (TPR)' }
  }
);

# Show the graph directly in IPerl
show_plot($chart);


