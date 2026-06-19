use strict;
use warnings; 
use Data::Dump qw(dump);
use AI::MXNet qw(mx);
use sml;
use Chart::Plotly qw(show_plot);

my ($dataset, $header) = sml->load_csv('data/iris.csv');
my ($lookup, $rlookup) = sml->str_column_to_int($dataset, -1);
$dataset = mx->nd->array($dataset);

printf "%d-%s ", $_, $header->[$_] for (0 .. $#$header);
printf "%s\n", dump $lookup, $rlookup;

print $dataset->slice([0, 5])->asstr;

my $X = mx->nd->array($dataset->slice(':', [undef, -1])->aspdl);
printf "%d-%s ", $_, $header->[$_] for (0 .. $#$header - 1);
print $X->slice([undef, 5])->asstr;

my $y = $dataset->slice(':', -1);
printf "y: %s", $y->asstr;

printf "Mean: %s\n", mx->nd->mean($X, axis => 0)->asstr;
printf "Deviaton: %s\n", mx->nd->std($X, axis => 0)->asstr;

my $X0 = $X->slice(':', 0)->copy();
my $X1 = $X->slice(':', 1)->copy();
my $X2 = $X->slice(':', 2)->copy();
my $X3 = $X->slice(':', 3)->copy();

printf "Pearson Correlation %s x %s: %s\n", @$header[0, 1], mx->nd->corrcoef($X0, y => $X1)->asstr;

my $color_scale = [
    [0, 'green'],
    [0.5, 'purple'],
    [1, 'orange']
];

my $trace = new Chart::Plotly::Trace::Scatter(
    x => $X0->aspdl,
    y => $X1->aspdl,
    mode => 'markers',
    marker => {
        color => $y->aspdl,
        colorscale => $color_scale,
        cmin => $y->min,
        cmax => $y->max,
        size => 10
    }
);

my $layout = {
    title => { text => sprintf('Scatter Plot %s vs %s', @$header[0, 1]) },
    xaxis => { title => $header->[0] }, 
    yaxis => { title => $header->[1] },
    width => 900, 
    height => 400,
    margin => { l => 50, r => 0, t => 50, b => 50 }
};

my $plot = new Chart::Plotly::Plot(traces => [$trace], layout => $layout);
#show_plot($plot);

printf "Pearson Correlation %s x %s: %s\n", @$header[0, 2], mx->nd->corrcoef($X0, y => $X2)->asstr;

$trace = new Chart::Plotly::Trace::Scatter(
    x => $X0->aspdl,
    y => $X2->aspdl,
    mode => 'markers',
    marker => {
        color => $y->aspdl,
        colorscale => $color_scale,
        cmin => $y->min,
        cmax => $y->max,
        size => 10
    }
);

$layout = {
    title => { text => sprintf('Scatter Plot %s vs %s', @$header[0, 2]) },
    xaxis => { title => $header->[0] }, 
    yaxis => { title => $header->[2] },
    width => 900, 
    height => 400,
    margin => { l => 50, r => 0, t => 50, b => 50 }
};

$plot = new Chart::Plotly::Plot(traces => [$trace], layout => $layout);
#show_plot($plot);

printf "Pearson Correlation %s x %s: %s\n", @$header[0, 3], mx->nd->corrcoef($X0, y => $X3)->asstr;

$trace = new Chart::Plotly::Trace::Scatter(
    x => $X0->aspdl,
    y => $X3->aspdl,
    mode => 'markers',
    marker => {
        color => $y->aspdl,
        colorscale => $color_scale,
        cmin => $y->min,
        cmax => $y->max,
        size => 10
    }
);

$layout = {
    title => { text => sprintf('Scatter Plot %s vs %s', @$header[0, 3]) },
    xaxis => { title => $header->[0] }, 
    yaxis => { title => $header->[3] },
    width => 900, 
    height => 400,
    margin => { l => 50, r => 0, t => 50, b => 50 }
};

$plot = new Chart::Plotly::Plot(traces => [$trace], layout => $layout);
#show_plot($plot);

printf "Pearson Correlation %s x %s: %s\n", @$header[1, 2], mx->nd->corrcoef($X1, y => $X2)->asstr;

$trace = new Chart::Plotly::Trace::Scatter(
    x => $X1->aspdl,
    y => $X2->aspdl,
    mode => 'markers',
    marker => {
        color => $y->aspdl,
        colorscale => $color_scale,
        cmin => $y->min,
        cmax => $y->max,
        size => 10
    }
);

$layout = {
    title => { text => sprintf('Scatter Plot %s vs %s', @$header[1, 2]) },
    xaxis => { title => $header->[1] }, 
    yaxis => { title => $header->[2] },
    width => 900, 
    height => 400,
    margin => { l => 50, r => 0, t => 50, b => 50 }
};

$plot = new Chart::Plotly::Plot(traces => [$trace], layout => $layout);
#show_plot($plot);

printf "Pearson Correlation %s x %s: %s\n", @$header[1, 3], mx->nd->corrcoef($X1, y => $X3)->asstr;

$trace = new Chart::Plotly::Trace::Scatter(
    x => $X1->aspdl,
    y => $X3->aspdl,
    mode => 'markers',
    marker => {
        color => $y->aspdl,
        colorscale => $color_scale,
        cmin => $y->min,
        cmax => $y->max,
        size => 10
    }
);

$layout = {
    title => { text => sprintf('Scatter Plot %s vs %s', @$header[1, 3]) },
    xaxis => { title => $header->[1] }, 
    yaxis => { title => $header->[3] },
    width => 900, 
    height => 400,
    margin => { l => 50, r => 0, t => 50, b => 50 }
};

$plot = new Chart::Plotly::Plot(traces => [$trace], layout => $layout);
#show_plot($plot);

printf "Pearson Correlation %s x %s: %s\n", @$header[2, 3], mx->nd->corrcoef($X2, y => $X3)->asstr;

$trace = new Chart::Plotly::Trace::Scatter(
    x => $X2->aspdl,
    y => $X3->aspdl,
    mode => 'markers',
    marker => {
        color => $y->aspdl,
        colorscale => $color_scale,
        cmin => $y->min,
        cmax => $y->max,
        size => 10
    }
);

$layout = {
    title => { text => sprintf('Scatter Plot %s vs %s', @$header[2, 3]) },
    xaxis => { title => $header->[2] }, 
    yaxis => { title => $header->[3] },
    width => 900, 
    height => 400,
    margin => { l => 50, r => 0, t => 50, b => 50 }
};

$plot = new Chart::Plotly::Plot(traces => [$trace], layout => $layout);
#show_plot($plot);


my $X_normalized = $dataset->slice(':', [0, -1])->copy();
$y = $dataset->slice(':', -1);

my $minmax = sml->dataset_minmax($X_normalized);
sml->normalize_dataset($X_normalized, $minmax);

my $normalized = mx->nd->concat($X_normalized, $y->expand_dims(axis => 1));
printf "Normalized:%s", $normalized->slice([0, 5])->asstr;

my $corrcoef_normalized = mx->nd->corrcoef($normalized->transpose());
printf "Pearson Correlation coefficients of the dataset: %s\n", $corrcoef_normalized->asstr;

printf "Pearson Correlation coefficients of X: %s\n", mx->nd->corrcoef($dataset->transpose())->asstr;

my $labels = [map { $header->[$_] } (0 .. $#$header)];

$trace = new Chart::Plotly::Trace::Heatmap(
    x => $labels,
    y => $labels,
    z => $corrcoef_normalized->aspdl,
    colorscale => 'Jet'
);

$layout = {
    title => { text => 'Heatmap for Pearson Correlation coefficients of Iris dataset' },
    yaxis => { autorange => "reversed" },
    width => 900, 
    height => 400,
    margin => { l => 50, r => 0, t => 50, b => 50 }
};

$plot = new Chart::Plotly::Plot(traces => [$trace], layout => $layout);
#show_plot($plot);

my $filename = 'data/pima-indians-diabetes.csv';
($dataset, $header) = sml->load_csv($filename, asndarray=>1);
$X_normalized = $dataset->slice(':', [0, -1])->copy();
$y = $dataset->slice(':', -1);
# normalize
$minmax = sml->dataset_minmax($X_normalized);
sml->normalize_dataset($X_normalized, $minmax);
$normalized = mx->nd->concat($X_normalized, $y->expand_dims(axis=>1));
printf "Normalized:%s", $normalized->asstr;

$corrcoef_normalized = mx->nd->corrcoef($normalized->transpose());
printf "Pearson Correlation coefficients of the Diabetes dataset: %s\n",
$corrcoef_normalized->asstr;

#standardize
my $X_standardized = $dataset->slice(':', [0, -1])->copy();
my $means = sml->column_means($X_standardized);
my $stdevs = sml->column_stdevs($X_standardized, $means);
sml->standardize_dataset($X_standardized, $means, $stdevs);
my $standardized = mx->nd->concat($X_standardized, $y->expand_dims(axis=>1));
print $standardized->asstr;

my $corrcoef_standardized = mx->nd->corrcoef($standardized->transpose());
printf "Pearson Correlation coefficients of the Diabetes dataset: %s\n",
$corrcoef_standardized->asstr;

printf "%d-%s ", $_, $header->[$_] for (0 .. $#$header);


# # Show a heatmap out of the Pearson Correlation coefficients of X
# $trace = new Chart::Plotly::Trace::Heatmap(
#     x => $labels,
#     y => $labels,
#     z => $corrcoef_normalized->aspdl,
#     colorscale => 'Jet'
# );

# $layout = {
#     title => { text => 'Heatmap for Pearson Correlation coefficients of Iris dataset' },
#     yaxis => { autorange => "reversed" },
#     width => 900, 
#     height => 400,
#     margin => { l => 50, r => 0, t => 50, b => 50 }
# };

# $plot = new Chart::Plotly::Plot(traces => [$trace], layout => $layout);
# show_plot($plot);