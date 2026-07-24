#Estudiante: Juan Chugá
#Paralelo: GR1SW
#Fecha: 10/06/2026

package Viterbi{

use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);

sub new{
my ($class, %args) = (shift, states => [], observables => [], @_);
my $self ={
states => $args{states},
observables => $args{observables}
};
return bless $self, $class;
}

sub get_start_probs{
my ($self, $training_data, $start_probs) = @_;
return $self->{start} if defined $self->{start};
}

sub set_start{
my ($self, $start) = @_;
return $self->{start} = $start;
}

sub set_emissions{
my ($self, $emissions) = @_;
return $self->{emissions} = $emissions;
}

sub set_transitions{
my ($self, $transitions) = @_;
return $self->{transitions} = $transitions;
}

sub forward_tensors{
my($self, $O, %args) = (splice(@_, 0, 2), debug=>0, log=>0, @_);
#Inicializacion
my $A = $self->{transitions}->copy();
my $B = $self->{emissions}->copy();
my $pi = $self->get_start_probs()->copy();

my $I = $A->len;
my $N = $O->len;

my $F = mx->nd->zeros([$I, $N]);

my $obs = $O->slice(0)->asscalar;
my $b0 = $B->slice(':', $obs);
$F->slice(':',0)->set(($pi * $b0)->expand_dims(axis=>1));

#Recursión
for my $n(1..$N-1){
my $obs = $O->slice($n)->asscalar;
my $prev = $F->slice(':', [$n-1,$n]);

my $temp = $prev * $A;
my $sums = $temp->sum(axis=>0);

my $emit = $B->slice(':', $obs);
$F->slice(':', $n)->set(($sums * $emit)->expand_dims(axis=>1));
}

#Terminación
my $P = $F->slice(':', $N-1)->sum;
return ($P, $F);
}

1;

}

#Codigo de prueba
use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);

sub print_tensors{
printf "type: %s shape:%s\n%s\n", ref($_), dump($_->shape), $_->aspdl for (@_);
}

my $HMM = Viterbi->new(
states => ['Sunny', 'Rainy'],
observables => ['walk', 'shop', 'clean']
);

my $A = mx->nd->array([[0.7, 0.3], [0.4, 0.6]]);
my $B = mx->nd->array([[1.0, 0.0, 0.0], [0.2, 0.3, 0.5]]);

my $pi = mx->nd->array([4/7, 3/7]);
my $O = mx->nd->array([2, 0, 1]);

$HMM->set_transitions($A);
$HMM->set_emissions($B);
$HMM->set_start($pi);

my ($P, $F) = $HMM->forward_tensors($O, log=>0, order=>1);
print_tensors($P, $F);

#Codigo de quiz
my $observations_set= [
[1,1,1],
[1,1,2],
[1,1,0],
[1,2,2],
[1,2,0],
[1,0,1],
[1,0,2],
[1,0,0],
[2,2,2],
[2,2,0],
[2,0,2],
[0,1,0],
[0,2,0],
[0,0,2],
[0,0,0]
];

while (my ($i, $obs) = each @$observations_set){
my ($P, $F) = $HMM->forward_tensors(mx->nd->array($obs), debug=>0);
printf "%d -> observations: %s\n", $i + 1, join('->', @$obs);
printf "P(O|h): %s\n\n", substr($P->asscalar, 0, 7);
}
