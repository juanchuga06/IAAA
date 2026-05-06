# Todo programa que usted desarrolle debe cargar las siguientes librerías:
use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);

use strict;
use warnings;
use Data::Dump qw(dump);
use AI::MXNet qw(mx);

# 1) Crear tensor base
my $x = mx->nd->arange(stop => 12)->reshape([3, 4]);
print "x:\n", $x->aspdl, "\n\n";

# 2) Inspección
print "shape: ", dump($x->shape), "\n";
print "len: ", $x->len, "\n";
print "ndim: ", $x->ndim, "\n";
print "size: ", $x->size, "\n\n";

# 3) Transformaciones
print "transpose:\n", $x->transpose()->aspdl, "\n\n";
print "reshape [-1,2]:\n", $x->reshape([-1,2])->aspdl, "\n\n";

# 4) Broadcasting
my $b = mx->nd->array([2]);
print "x + 2 (broadcast):\n", ($x + $b)->aspdl, "\n\n";

# 5) Suma por filas
print "sum axis=1:\n", $x->sum(axis => 1)->aspdl, "\n\n";

# 6) Slice de columnas 1..3
print "slice_axis columnas:\n", mx->nd->slice_axis($x, axis => 1, begin => 1, end => 4)->aspdl, "\n\n";

# 7) Concatenación
my $y = mx->nd->ones([3, 4]);
print "concat por filas:\n", mx->nd->concat($x, $y, dim => 0)->aspdl, "\n";
