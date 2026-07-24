#Estudiante: Juan Chugá
#Paralelo: GR1SW
#Fecha: 01/06/2024

package Viterbi{
use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(reduce);
sub new{
my ($class, %args) = (shift, states => [], observables => [], @_);
my $self = {
states => $args{states},
observables => $args{observables},
};
return bless $self, $class;
}
# Initializes the start probabilities.
# The start probabilities are passed as a reference to a hash.
sub start{
my ($self, $start) = @_;
return $self->{start} = $start;
}
# Initializes the emission probabilities.
# The emissions are passed as a reference to a hash.
sub emissions{
my ($self, $emissions) = @_;
return $self->{emissions} = $emissions;
}
# Initializes the transition probabilities.
# The transitions are passed as a reference to a hash.
sub transitions{
my ($self, $transitions) = @_;
return $self->{transitions} = $transitions;
}
# Returns the emission probability for a given observation and state.
sub get_emission{
my ($self, $observation, $hidden) = @_;
my $e = 0;
if (defined($self->{emissions}{$observation})){
if (defined($self->{emissions}{$observation}{$hidden})){
$e = $self->{emissions}{$observation}{$hidden};
}
else {
# observation exists, but not for this hidden state
$e = 0;
}
}
else {
if (defined($self->{unknown_emission_prob})){
$e = $self->{unknown_emission_prob};
}
else {
$e = $self->{start}{$hidden};
}
}
return $e;
}
# Returns the transition probability between a state and the next state.
sub get_transition{
my ($self, $hidden, $next_hidden) = @_;

my $t = defined($self->{transitions}{$hidden}{$next_hidden})
? $self->{transitions}{$hidden}{$next_hidden}
: $self->{unknown_transition_prob};
return $t;
}

sub viterbi {
my ($self, $observations) = @_;
#Inicializacion
my $states = $self->{states};
my ($T1, $T2);

my $first_observation = $observations->[0];
for my $state (@$states) {
$T1->{$state}[0] = $self->{start}{$state} * $self->get_emission($first_observation, $state);
$T2->{$state}[0] = undef;
}
#Recursion
for my $t (1 .. $#$observations) {
my $observation = $observations->[$t];
for my $next_state (@$states) {
my $max_prob = 0;
my $argmax = undef;
my $emission_prob = $self->get_emission($observation, $next_state);

for my $state (@$states) {
my $previous_prob = $T1->{$state}[$t - 1];
my $transition_prob = $self->get_transition($state, $next_state);
my $candidate_prob = $previous_prob * $transition_prob * $emission_prob;

if ($candidate_prob > $max_prob) {
$max_prob = $candidate_prob;
$argmax = $state;
}
}

$T1->{$next_state}[$t] = $max_prob;
$T2->{$next_state}[$t] = $argmax;
}
}
#Finalizacion
my $last_t = $#$observations;
my $best_prob = 0;
my $best_state = undef;
for my $state (@$states) {
if (($T1->{$state}[$last_t]) > $best_prob) {
$best_prob = $T1->{$state}[$last_t];
$best_state = $state;
}
}
#Backtracking
my @path;
$path[$last_t] = $best_state;
for (my $t = $last_t; $t > 0; $t--) {
$path[$t - 1] = $T2->{$path[$t]}[$t];
}

return (\@path, $best_prob);
}
1;
}

#Codigo de test
use strict;
use warnings;
use Data::Dump qw(dump);
my $start = { 'Sunny'=> 4/7, 'Rainy'=> 3/7 };
my $transitions = {
'Sunny' => {'Sunny'=> 0.7, 'Rainy'=> 0.3},
'Rainy' => {'Sunny'=> 0.4, 'Rainy'=> 0.6},
};

my $emissions = {
'walk' => {
'Sunny' => 1,
'Rainy' => 0.2
},
'shop' => {
'Sunny' => 0,
'Rainy' => 0.3,
},
'clean' => {
'Sunny' => 0,
'Rainy' => 0.5
}
};
my $observations = [ 'clean', 'walk', 'shop' ];
my $v = new Viterbi(states=>['Sunny', 'Rainy'], observables=>['walk', 'shop', 'clean']);
$v->transitions($transitions);
$v->emissions($emissions);
$v->start($start);
my ($viterbi_path, $viterbi_prob) = $v->viterbi($observations);

printf "observations: %s\n", join(' → ', @$observations);
printf "viterbi_path: %s\n", join(' → ', @$viterbi_path);
printf "viterbi_prob: %s\n\n", substr($viterbi_prob, 0, 7);

#Codigo de la pagina 9
my $observations_set = [
['shop', 'shop', 'shop'],
['shop', 'shop', 'clean'],
['shop', 'shop', 'walk'],
['shop', 'clean', 'clean'],
['shop', 'clean', 'walk'],
['shop', 'walk', 'shop'],
['shop', 'walk', 'clean'],
['shop', 'walk', 'walk'],
['clean', 'clean', 'clean'],
['clean', 'clean', 'walk'],
['clean', 'walk', 'clean'],
['clean', 'walk', 'walk'],
['walk', 'shop', 'shop'],
['walk', 'shop', 'clean'],
['walk', 'shop', 'walk'],
['walk', 'clean', 'clean'],
['walk', 'clean', 'walk'],
['walk', 'walk', 'shop'],
['walk', 'walk', 'clean'],
['walk', 'walk', 'walk']
];

while (my ($i, $obs) = each @$observations_set){
my ($viterbi_path, $viterbi_prob) = $v->viterbi($obs);
printf "%d -> observations: %s\n", $i + 1, join(' → ', @$obs);
printf "viterbi_path: %s\n", join(' → ', @$viterbi_path);
printf "viterbi_prob: %s\n\n", substr($viterbi_prob, 0, 7);
}
