# Todo código debe tener al menos esas 3 funciones
use strict; # Forza la declaración de las variables
use warnings; # Genera mensajes de error de sintaxis
use Data::Dump qw(dump); # Para la impresión de estructuras de datos

use List::Util qw(zip min max sum any all first none); # Reorganizar los arreglos con zi
use Tie::IxHash; # Preserva el orden de registro en arreglos asociativos
# use aliased 'jjap::numperl' => 'np';

# Ejercicio 1

sub promedio {
    my @arreglo = @_;
    for my $num (@arreglo){
        if ($num !~ m/^\d+(?:\.\d+)?$/){
            print STDERR "No es numero\n";
            return;
        }
    }
    return sum(@arreglo) / @arreglo; 

}

my @numeros = (10, 20, 30, 40, 50);
print promedio(@numeros);

# Ejercicio 2

sub crear_estudiante{
    my ($apellidos, $email, %args) = (splice(@_, 0, 2), ciudad => "", @_);
    if(!defined $apellidos){
        print STDERR "Falta apellidos\n";
        return;
    }
    if(!defined $email){
        print STDERR "Falta email\n";
        return;
    }

    printf "Apellidos: %s\n", $apellidos;
    printf "Email: %s\n", $email;
    printf "Ciudad: %s\n", $args{ciudad};
}

crear_estudiante('Chuga Rosero', 'juan.chuga@epn.edu.ec', ciudad => 'Quito');
crear_estudiante('Ayala  Perez', 'ayala.perez@epn.edu.ec');

# Ejercicio 3

package Estudiante{
    sub new {
        my ($class, $nombre, $nota) = (shift, @_);
        if(!defined $nombre){
            print STDERR "Falta apellidos\n";
            return;
        }
        if(!defined $nota || $nota !~ m/^\d+(?:\.\d+)?$/){
            print STDERR "Falta email\n";
            return;
        }
        my $self = {
            nombre => $nombre,
            nota => $nota
        };
        return bless($self, $class);
    }

    sub nombre{
        my ($self, $nombre) = @_;
        $self->{nombre} = $nombre if defined $nombre;
        return $self->{nombre};
    }
    sub nota{
        my ($self, $nota) = @_;
        $self->{nota} = $nota if defined $nota;
        return $self->{nota};
    }
    
    sub aprueba{
        my $self = shift;
        return $self->{nota} >= 7;
    }
}

my $estudiante = new Estudiante('Juan Chuga', '6');
if ( $estudiante->aprueba() ) {
    print "El estudiante Aprobó.\n";
} else {
    print "El estudiante Reprobó.\n";
}


#Ejercicio 4

package EstudianteBecado{
    use base qw(Estudiante);

    sub new{
        my ($class, $monto_beca) = (shift, @_);

        my $self = {
            monto_beca => $monto_beca
        };
        return bless($self, $class);

    }
    sub monto_beca{
        my ($self, $monto_beca) = @_;
        $self->{monto_beca} = $monto_beca if defined $monto_beca;
        return $self->{monto_beca};
    }

}

my $estudianteBecado = new EstudianteBecado(200);
$estudianteBecado->nombre('Luis');

print $estudianteBecado->nombre() . " " . $estudianteBecado->monto_beca();