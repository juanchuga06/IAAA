# Todo programa que usted desarrolle debe cargar las siguientes librerías:
use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);
use sml;


# my $file_path = 'data/pima-indians-diabetes.csv';
# my $dataset = sml->load_csv($file_path);
# $dataset = mx->nd->array($dataset);

# print $dataset;
# print $dataset->slice(begin=>[0,0], end=>[2,4])->aspdl;
# my $z = $dataset->slice(begin=>[9,0], end=>[11,4])->aspdl;
# print $z->aspdl;



# my $x = [1,2];

# $x = mx->nd->array($x);
# $x = mx->nd->array([1,2]);
# printf "%s\n", $x->aspdl;

# $x = mx->nd->arange(start => 0,
#                         stop => 12,
#                         step => 1,
#                         ctx => mx->cpu(0));
# printf "%s\n", $x->aspdl;
# # my $y = $x->as_in_context(mx->cpu(1));
# # print $y;

# $x = mx->nd->zeros([3,4]);
# printf "%s\n", $x->aspdl;
# printf "%s\n", dump $x->shape;


# $x = mx->nd->full([2,3,4], 5);
# $x = mx->nd->full([2,3,4], 5)->reshape([6,4]);
# # $x = mx->nd->arange(stop=>12)->reshape([3,4]);
# # printf "x: %s", $x->aspdl;
# # printf "Shapes (x): %s\n", dump $x->shape;

# # my $y = mx->nd->arange(stop => 3)->reshape([3,1]);
# # printf "y: %s", $y->aspdl;
# # printf "Shapes (y): %s\n", dump $y->shape;

# # my $z = $x + $y;

# # printf "z: %s", $z->aspdl;
# # printf "Shapes (z): %s\n", dump $z->shape;


# # Ejercicio:

# $x = mx->nd->arange(stop=>3)->reshape([3,1]);
# printf "x: %s", $x->aspdl;
# printf "Shapes (x): %s\n", dump $x->shape;

# my $y = mx->nd->arange(stop => 2)->reshape([1,2]);
# printf "y: %s", $y->aspdl;
# printf "Shapes (y): %s\n", dump $y->shape;

# my $z = $x + $y;

# printf "z: %s", $z->aspdl;
# printf "Shapes (z): %s\n", dump $z->shape;


# Creación de tensores
my $x = mx->nd->array([[1, 2], [3, 4]]);
my $y = mx->nd->array([[5, 6], [7, 8]]);

# Operaciones
my $dot_result = mx->nd->dot($x, $y);              # Multiplicación
my $det_result = mx->nd->linalg->det($x);          # Determinante
my $inv_result = mx->nd->linalg->inverse($x);

print "Dot Product:\n" . $dot_result->aspdl . "\n";
print "Determinant: " . $det_result->aspdl . "\n";
print "Inverse Matrix:\n" . $inv_result->aspdl . "\n";