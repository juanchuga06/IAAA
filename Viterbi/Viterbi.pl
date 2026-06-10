package Algorithm::Viterbi{

    use strict;
    use warnings;
    use Data::Dump qw(dump);
    use AI::MXNet qw(mx);

    sub new{
        my ($class, %args) = (shift, states => [], observables => [], @_); 
        my $self = {
                    states      => $args{states},
                    observables => $args{observables},
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


    sub viterbi{
        my ($self, $observations, %args) = (splice(@_, 0, 2), debug=>0, log=>0, @_);
        my $A  = $self->{transitions}->copy();
        my $B  = $self->{emissions}->copy();
        my $pi = $self->get_start_probs()->copy();

        if ($args{log}) {
            my $tiny = 1e-32;
            $A  = mx->nd->log($A  + $tiny);
            $B  = mx->nd->log($B  + $tiny);
            $pi = mx->nd->log($pi + $tiny);
        }
        
        my $I = $A->len;
        my $N = $observations->len;

        my $D = mx->nd->zeros([$I, $N]);
        my $E = mx->nd->zeros([$I, $N-1]);

        my $obs = $observations->slice(0)->asscalar;
        my $b0 =  $B->slice(':', $obs);
        $D->slice(':',0)->set(($args{log} ? $pi + $b0: $pi * $b0)->expand_dims(axis=>1));


        for my $n (1..$N-1){
            $obs = $observations->slice($n)->asscalar;
            my $prev = $D->slice(':', [$n-1, $n]);
            my $temp = $args{log} ? $prev + $A: $prev * $A;
            my $max_vals = $temp->max(axis=>0);
            my $argmaxes = $temp->argmax(axis=>0);
            my $emit = $B->slice(':',$obs);
            $D->slice(':', $n)->set(($args{log} ? $max_vals + $emit: $max_vals * $emit)->expand_dims(axis=>1));
            $E->slice(':', $n-1)->set(($argmaxes)->expand_dims(axis=>1));
        }

        my $S_opt = mx->nd->zeros([$N]);
        $S_opt->slice($N-1)->set($D->slice(':', $N-1)->argmax);
        for my $n (reverse 0 .. $N-2){
            my $next_state = $S_opt->slice($n+1)->asscalar;
            $S_opt->slice($n)->set( mx->nd->array([$E->slice($next_state, $n)->asscalar]));
        }
        
        $D = mx->nd->exp($D) if $args{log};

        return ($S_opt, $D, $E);
    }
    1;
}

    use strict;
    use warnings;
    use Data::Dump qw(dump);
    use AI::MXNet qw(mx);

sub print_result {
    my ($O, $S_opt, $D, $E) = @_;
    print "1. Secuencia de Observaciones (O):\n";
    print $O->aspdl;
    print "\n";

    print "2. Camino Óptimo de Estados Ocultos (S_opt):\n";
    print $S_opt->aspdl;
    print "\n";

    print "3. Matriz de Probabilidades (D):\n";
    print $D->aspdl;
    print "\n";

    print "4. Matriz de Punteros de Retroceso (E):\n";
    print $E->aspdl;
    print "\n";
}

# Código de prueba:

sub print_tensors{
  printf "type: %s shape:%s%s\n", ref($_), dump($_->shape), $_->aspdl for (@_);
}
my $vit = new Algorithm::Viterbi(states=>[0, 1], observables=>[10, 11, 12]); 

my $A = mx->nd->array([ 
    [0.7, 0.3], 
    [0.4, 0.6], 
]); 
my $B = mx->nd->array([ 
    [1.0, 0.0, 0.0], 
    [0.2, 0.3, 0.5], 
]); 
my $pi = mx->nd->array([4/7, 3/7]); 
my $O = mx->nd->array([0, 2, 0]); 
$vit->set_transitions($A); 
$vit->set_emissions($B); 
$vit->set_start($pi); 
my ($S_opt, $D, $E) = $vit->viterbi($O, log=>0, order=>1); 
print_tensors($O, $S_opt, $D, $E); 
