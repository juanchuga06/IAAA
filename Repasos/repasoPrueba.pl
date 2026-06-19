use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(zip min max sum);
use AI::MXNet qw(mx);
use sml;

printf "Punto 0:\n";
my ($dataset, $header)= sml->load_csv('data/datos_hmm_clima.csv');

my $lookup_columna_0 = sml->str_column_to_int($dataset, 0); 
my $lookup_columna_1 = sml->str_column_to_int($dataset, 1);
print dump $lookup_columna_0;
print dump $lookup_columna_1;

$dataset = mx->nd->array($dataset);
print $dataset->aspdl;

printf "Punto 1:\n";
#Primer punto: obtener pares de estados ocultos
my (@pair_array, $count);
$count = 0;
for(my $i = 0; $i < ($dataset->len)-1; $i++){
    push @pair_array, [$dataset->at($i, 1)->asscalar, $dataset->at($i+1, 1)->asscalar];
    $count++;
}
my $dataset_pairs = mx->nd->array(\@pair_array);
print $dataset_pairs->aspdl;
print $count;

printf "Punto 2:\n";
my $count_matrix = mx->nd->zeros([1,4]);
my $estado_actual = mx->nd->slice_axis($dataset_pairs, axis => 1, begin => 0, end => 1);
my $estado_siguiente = mx->nd->slice_axis($dataset_pairs, axis => 1, begin => 1, end => 2);
my $encoded_tensor = ($estado_actual * 10) + $estado_siguiente;


my $c00 = mx->nd->sum($encoded_tensor == 0)->asscalar;
my $c01 = mx->nd->sum($encoded_tensor == 1)->asscalar;
my $c10 = mx->nd->sum($encoded_tensor == 10)->asscalar;
my $c11 = mx->nd->sum($encoded_tensor == 11)->asscalar;

$count_matrix = mx->nd->array([[ $c00, $c01, $c10, $c11 ]]);
print $count_matrix->aspdl;

printf "Punto 3:\n";
my $count_emission_matrix;
$estado_actual = mx->nd->slice_axis($dataset, axis => 1, begin => 0, end => 1);
$estado_siguiente = mx->nd->slice_axis($dataset, axis => 1, begin => 1, end => 2);
$encoded_tensor = ($estado_actual * 10) + $estado_siguiente;

$c00 = mx->nd->sum($encoded_tensor == 0)->asscalar;
$c01 = mx->nd->sum($encoded_tensor == 1)->asscalar;
$c10 = mx->nd->sum($encoded_tensor == 10)->asscalar;
$c11 = mx->nd->sum($encoded_tensor == 11)->asscalar;
my $c20 = mx->nd->sum($encoded_tensor == 20)->asscalar;
my $c21 = mx->nd->sum($encoded_tensor == 21)->asscalar;
$count_emission_matrix = mx->nd->array([[ $c00, $c01], [ $c10, $c11], [$c20, $c21]]);
print $count_emission_matrix->aspdl;

printf "Punto 4:\n";

$c00 = $count_matrix->at(0,0)->asscalar / ($count_matrix->at(0,0)->asscalar + $count_matrix->at(0,1)->asscalar);
$c01 = $count_matrix->at(0,1)->asscalar / ($count_matrix->at(0,0)->asscalar + $count_matrix->at(0,1)->asscalar);
$c10 = $count_matrix->at(0,2)->asscalar / ($count_matrix->at(0,2)->asscalar + $count_matrix->at(0,3)->asscalar);
$c11 = $count_matrix->at(0,3)->asscalar / ($count_matrix->at(0,2)->asscalar + $count_matrix->at(0,3)->asscalar);
my $transition_matrix = mx->nd->array([[ $c00, $c01], [ $c10, $c11]]);
print $transition_matrix->aspdl;

printf "Punto 5:\n";
my $total_sunny = $count_emission_matrix->sum(axis=>0)->at(0)->asscalar;
my $total_rainy = $count_emission_matrix->sum(axis=>0)->at(1)->asscalar;
print $total_sunny, $total_rainy;

my $e00 = $count_emission_matrix->at(0,0)->asscalar / $total_sunny;
my $e01 = $count_emission_matrix->at(0,1)->asscalar / $total_rainy;
my $e10 = $count_emission_matrix->at(1,0)->asscalar / $total_sunny;
my $e11 = $count_emission_matrix->at(1,1)->asscalar / $total_rainy;
my $e20 = $count_emission_matrix->at(2,0)->asscalar / $total_sunny;
my $e21 = $count_emission_matrix->at(2,1)->asscalar / $total_rainy;
my $emission_matrix = mx->nd->array([[ $e00, $e01], [ $e10, $e11], [$e20, $e21]])->T;
printf $emission_matrix->aspdl;


printf "Punto 6:\n";
my $pi = mx->nd->array([[0.5, 0.5]]);
for(0..20){
    $pi = mx->nd->dot($pi, $transition_matrix);
}
printf $pi->aspdl;


sub viterbi {
    my ($obs_seq, $pi_tensor, $trans_matrix, $emiss_matrix) = @_;
    
    my $V = $pi_tensor->reshape([-1]); 
    
    my @backpointers; 
    
    my $o_first = $obs_seq->[0];
   
    my $B_col = mx->nd->slice_axis($emiss_matrix, axis=>1, begin=>$o_first, end=>$o_first+1)->reshape([-1]);
    $V = $V * $B_col; 
    
    for my $t (1 .. scalar(@$obs_seq) - 1) {
        my $o_curr = $obs_seq->[$t];
            
        my $V_expanded = mx->nd->expand_dims($V, axis=>1);
        my $weighted_transitions = $V_expanded * $trans_matrix;
           
        my $max_V = mx->nd->max($weighted_transitions, axis=>0);
        my $ptr   = mx->nd->argmax($weighted_transitions, axis=>0);   
        
        push @backpointers, [ $ptr->at(0)->asscalar, $ptr->at(1)->asscalar ];
           
        $B_col = mx->nd->slice_axis($emiss_matrix, axis=>1, begin=>$o_curr, end=>$o_curr+1)->reshape([-1]);
        $V = $max_V * $B_col;
    }
    
    my $best_final_state = mx->nd->argmax($V, axis=>0)->asscalar;
    my $best_prob = mx->nd->max($V, axis=>0)->asscalar;
    
    my @best_path = ($best_final_state);
    my $current_state = $best_final_state;
    
    for (my $t = scalar(@backpointers) - 1; $t >= 0; $t--) {
        $current_state = $backpointers[$t]->[$current_state];
        unshift @best_path, $current_state; # unshift inserta al inicio del arreglo
    }
    
    return (\@best_path, $best_prob);
}

printf "\nPunto 7 (Viterbi):\n";

my @secuencia_observaciones = (0, 2, 0); 

my ($camino_optimo, $probabilidad) = viterbi(
    \@secuencia_observaciones, 
    $pi,               
    $transition_matrix,
    $emission_matrix   
);

my %states_lookup = (0 => 'Sunny', 1 => 'Rainy');
my @camino_texto = map { $states_lookup{$_} } @$camino_optimo;

print "Secuencia observada: walk -> clean -> walk\n";
print "Camino de estados ocultos mas probable: " . join(" -> ", @camino_texto) . "\n";
print "Probabilidad del camino: $probabilidad\n";