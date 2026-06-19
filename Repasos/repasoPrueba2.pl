use strict;
use warnings;
use Data::Dump qw(dump);
use List::Util qw(zip min max sum);
use AI::MXNet qw(mx);
use sml;

# my @costos_base = (12.50, 45.00, 8.75, 120.00, 3.50);
# my @costos_finales;

# for my $costo (@costos_base) {
#     my $con_impuesto = $costo * 1.15;
#     my $total = $con_impuesto + 5.00;
#     push @costos_finales, $total;
# }
# @costos_finales ahora tiene los valores calculados

my $costos_base = mx->nd->array([12.50, 45.00, 8.75, 120.00, 3.50]);
my $costos_finales = ($costos_base * 1.15) + 5.0;
print $costos_finales->aspdl;


# my @pesos_sacos = (42, 50, 48, 39, 45, 55, 41);
# my @pesos_filtrados;

# for my $peso (@pesos_sacos) {
#     if ($peso < 45) {
#         push @pesos_filtrados, 0;
#     } else {
#         push @pesos_filtrados, $peso;
#     }
# }

my $pesos_sacos = mx->nd->array([42, 50, 48, 39, 45, 55, 41]);
my $pesos_filtrados = mx->nd->where($pesos_sacos < 45, mx->nd->zeros($pesos_sacos->shape), $pesos_sacos);
print $pesos_filtrados->aspdl;

# my @latencias_nodos = (12, 15, 8, 142, 11, 14);

# my $max_latencia = -1;
# my $indice_critico = -1;

# for (my $i = 0; $i < scalar(@latencias_nodos); $i++) {
#     if ($latencias_nodos[$i] > $max_latencia) {
#         $max_latencia = $latencias_nodos[$i];
#         $indice_critico = $i;
#     }
# }

# print "Latencia max: $max_latencia en el nodo $indice_critico\n";

my $latencias_nodos = mx->nd->array([12, 15, 8, 142, 11, 14]);
my $max_latencia = $latencias_nodos->max(axis=>0);
my $min_latencia = $latencias_nodos->min(axis=>0);

printf "Latencia minima: %d Latencia maxima: %d", $max_latencia->asscalar, $min_latencia->asscalar;  

# my @id_repuesto = (105, 210, 304, 401);
# my @sede_id     = (0, 2, 1, 0); # Existen 3 sedes en total (0, 1, 2)
# my @matriz_final;

# for (my $i = 0; $i < scalar(@id_repuesto); $i++) {
#     my @one_hot = (0, 0, 0);
#     $one_hot[ $sede_id[$i] ] = 1;
#     # El resultado esperado es [ID, Sede0, Sede1, Sede2]
#     push @matriz_final, [ $id_repuesto[$i], @one_hot ];
# }

my $id_repuesto = mx->nd->array([105, 210, 304, 401]);
my $sede_id = mx->nd->array([0, 2, 1, 0]);
my $matriz_final = mx->nd->concat($id_repuesto->reshape([4,1]), mx->nd->one_hot($sede_id, 3)->squeeze, dim=>1);
print $matriz_final->aspdl;


# my @cargas = (120, 115, 130,   # Día 1
#               140, 135, 145,   # Día 2
#               110, 105, 115,   # Día 3
#               150, 160, 155,   # Día 4
#               125, 130, 120);  # Día 5

# my $total_semana = 0;
# my @promedio_diario;

# for (my $dia = 0; $dia < 5; $dia++) {
#     my $suma_dia = 0;
#     for (my $camion = 0; $camion < 3; $camion++) {
#         my $carga = $cargas[$dia * 3 + $camion];
#         $suma_dia += $carga;
#         $total_semana += $carga;
#     }
#     push @promedio_diario, $suma_dia / 3;
# }

my $cargas = mx->nd->array([120, 115, 130,
                            140, 135, 145,
                            110, 105, 115,
                            150, 160, 155,
                            125, 130, 120])->reshape([5,3]);
print $cargas->aspdl;
my $total_semana = $cargas->sum();
my $promedio_diario = $cargas->mean(axis=>1);
print $total_semana->aspdl, $promedio_diario->aspdl;

# my @peso_u = (0.5, 0.2, 0.0, 0.3);
# my @peso_v = (0.5, 0.5, 1.0, 0.3);
# my @peso_w = (0.0, 0.3, 0.0, 0.4);

# my @matriz_coordenadas;
# my @validacion;

# for (my $i = 0; $i < 4; $i++) {
#     # Agrupamos las coordenadas del pixel
#     push @matriz_coordenadas, [ $peso_u[$i], $peso_v[$i], $peso_w[$i] ];
    
#     # Validamos que sumen 1
#     my $suma = $peso_u[$i] + $peso_v[$i] + $peso_w[$i];
#     push @validacion, ($suma == 1.0) ? 1 : 0;
# }

my $peso_u = mx->nd->array([0.5, 0.2, 0.0, 0.3]);
my $peso_v = mx->nd->array([0.5, 0.5, 1.0, 0.3]);
my $peso_w = mx->nd->array([0.0, 0.3, 0.0, 0.4]);


my $matriz_coordenadas = mx->nd->concat($peso_u->expand_dims(axis=>1), $peso_v->expand_dims(axis=>1), $peso_w->expand_dims(axis=>1), dim=>1);
my $validacion = mx->nd->where($matriz_coordenadas->sum(axis=>1) == 1, mx->nd->ones([$matriz_coordenadas->len]), mx->nd->zeros([$matriz_coordenadas->len]));
print $matriz_coordenadas->aspdl;
print $validacion->aspdl;

# my @coords_x = (1.0, 5.0, 2.0);
# my @coords_y = (2.0, 3.0, 8.0);
# my @coords_z = (0.0, 0.0, 1.0);

# # Matriz de escala: multiplica X por 2, Y por 2, Z se queda igual
# my @matriz_escala = (
#     [2.0, 0.0, 0.0],
#     [0.0, 2.0, 0.0],
#     [0.0, 0.0, 1.0]
# );

# my @vertices_transformados;

# for (my $i = 0; $i < 3; $i++) {
#     my $x = $coords_x[$i];
#     my $y = $coords_y[$i];
#     my $z = $coords_z[$i];
    
#     # Multiplicación manual vector x matriz
#     my $nuevo_x = $x * $matriz_escala[0][0] + $y * $matriz_escala[1][0] + $z * $matriz_escala[2][0];
#     my $nuevo_y = $x * $matriz_escala[0][1] + $y * $matriz_escala[1][1] + $z * $matriz_escala[2][1];
#     my $nuevo_z = $x * $matriz_escala[0][2] + $y * $matriz_escala[1][2] + $z * $matriz_escala[2][2];
    
#     push @vertices_transformados, [$nuevo_x, $nuevo_y, $nuevo_z];
# }


my @coords_x = (1.0, 5.0, 2.0);
my @coords_y = (2.0, 3.0, 8.0);
my @coords_z = (0.0, 0.0, 1.0);

my $matriz_vertices = mx->nd->array([\@coords_x, \@coords_y, \@coords_z])->reshape([3,3])->transpose;
print $matriz_vertices->aspdl;
my $matriz_escala = mx->nd->array([
    [2.0, 0.0, 0.0],
    [0.0, 2.0, 0.0],
    [0.0, 0.0, 1.0]]);
print $matriz_escala->aspdl;
my $vertices_transformados = mx->nd->dot($matriz_vertices, $matriz_escala);
print $vertices_transformados->aspdl;

# # Índices: 0=Eléctrico, 1=Pantalla, 2=Placa
# my @lab_energia   = (0.8, 0.1, 0.2);
# my @lab_optica    = (0.3, 0.9, 0.1);
# my @lab_soldadura = (0.6, 0.2, 0.7);

# my @promedio_fallos;
# my $max_probabilidad = -1;
# my $indice_fallo_final = -1;

# for (my $i = 0; $i < 3; $i++) {
#     my $prom = ($lab_energia[$i] + $lab_optica[$i] + $lab_soldadura[$i]) / 3.0;
#     push @promedio_fallos, $prom;
    
#     if ($prom > $max_probabilidad) {
#         $max_probabilidad = $prom;
#         $indice_fallo_final = $i;
#     }
# }
# print "Fallo mas probable: $indice_fallo_final\n";

my $lab_energia   = mx->nd->array([0.8, 0.1, 0.2]);
my $lab_optica    = mx->nd->array([0.3, 0.9, 0.1]);
my $lab_soldadura = mx->nd->array([0.6, 0.2, 0.7]);

my $prom = mx->nd->stack($lab_energia, $lab_optica, $lab_soldadura, axis=>0)->mean(axis=>0);
my $indicefallomax = $prom->argmax(axis=>0);
print $prom->aspdl;
printf "Fallo mas probable: %d", $indicefallomax->asscalar;

# # [ID, Peso, Distancia]
# my @envios = (
#     [1001, 45.0, 250.0],
#     [1002, 50.0, 245.0],
#     [1003, 30.0, 260.0],
#     [1004, 60.0, 250.0]
# );

# my @desgaste_por_envio;

# for my $fila (@envios) {
#     my $peso = $fila->[1];
#     my $distancia = $fila->[2];
    
#     push @desgaste_por_envio, $peso * $distancia;
# }

my $envios = mx->nd->array([
    [1001, 45.0, 250.0],
    [1002, 50.0, 245.0],
    [1003, 30.0, 260.0],
    [1004, 60.0, 250.0]
]);
my $pesos = $envios->slice_axis(axis=>1, begin=>1, end=>2);
my $distancias = $envios->slice_axis(axis=>1, begin=>2, end=>3);
my $desgaste_por_envio = $pesos * $distancias;
print $pesos->aspdl;
print $distancias->aspdl;
print $desgaste_por_envio->aspdl;


# # Matrices de 2x2 pixeles
my $textura_a = mx->nd->array([[255, 128], [64, 200]]);
my $textura_b = mx->nd->array([[0, 50], [100, 25]]);
my $alpha     = mx->nd->array([[1.0, 0.5], [0.0, 0.8]]);

# my @textura_final;

# for (my $fila = 0; $fila < 2; $fila++) {
#     my @fila_resultado;
#     for (my $col = 0; $col < 2; $col++) {
#         my $a = $textura_a[$fila][$col];
#         my $b = $textura_b[$fila][$col];
#         my $alf = $alpha[$fila][$col];
        
#         my $pixel = ($a * $alf) + ($b * (1.0 - $alf));
#         push @fila_resultado, $pixel;
#     }
#     push @textura_final, \@fila_resultado;
# }

my $textura_final = ($textura_a * $alpha) + ($textura_b * (1.0 - $alpha));
print $textura_final->aspdl;

# my @stock_laboratorios = (15, 8, 20, 2, 10);
# my $stock_minimo = 10;
# my @pedidos_a_realizar;

# for my $stock (@stock_laboratorios) {
#     if ($stock < $stock_minimo) {
#         push @pedidos_a_realizar, $stock_minimo - $stock;
#     } else {
#         push @pedidos_a_realizar, 0;
#     }
# }
# # Resultado esperado: 0, 2, 0, 8, 0

my $stock_laboratorios = mx->nd->array([15, 8, 20, 2, 10]);
my $pedidos_a_realizar = mx->nd->where($stock_laboratorios < 10, 10 - $stock_laboratorios, mx->nd->zeros($stock_laboratorios->shape));
print $pedidos_a_realizar->aspdl;

# # [Chola, Leona]
# my @viajes_planos = (
#     50, 40,  # Viaje 1
#     30, 60,  # Viaje 2
#     45, 45,  # Viaje 3
#     60, 20   # Viaje 4
# );
# my @factor_desgaste = (1.5, 1.2);

# my $desgaste_total = 0;

# for (my $i = 0; $i < 4; $i++) {
#     my $chola = $viajes_planos[$i * 2];
#     my $leona = $viajes_planos[$i * 2 + 1];
    
#     my $desgaste_viaje = ($chola * $factor_desgaste[0]) + ($leona * $factor_desgaste[1]);
#     $desgaste_total += $desgaste_viaje;
# }

my $viajes_planos = mx->nd->array([
    50, 40,  # Viaje 1
    30, 60,  # Viaje 2
    45, 45,  # Viaje 3
    60, 20   # Viaje 4
])->reshape([4,2]);
my $factor_desgaste = mx->nd->array([1.5, 1.2])->reshape([2,1]);
my $desgaste_viaje = mx->nd->dot($viajes_planos, $factor_desgaste)->sum()->asscalar;
print $desgaste_viaje;
