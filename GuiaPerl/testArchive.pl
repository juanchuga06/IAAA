# Todo código debe tener al menos esas 3 funciones
use strict; # Forza la declaración de las variables
use warnings; # Genera mensajes de error de sintaxis
use Data::Dump qw(dump); # Para la impresión de estructuras de datos

use List::Util qw(zip min max sum any all first none); # Reorganizar los arreglos con zi
use Tie::IxHash; # Preserva el orden de registro en arreglos asociativos
# use aliased 'jjap::numperl' => 'np';

print "Hola Mundo!!!\n";

#Enteros

my $z = 0.127; # reasl
my $x = 3.22e-14; # real
my $c = 1567; # entero
my $d = -122; # entero
printf "%e\n", $x;

$x = 0377; # Representación octal, equivale a 255 decimal
my $y = 0xff; # Representación hexadecimal, equivale a 255
printf "%d %d\n", $x, $y;

print sprintf("%o\n", $x);

print $y;

print sprintf("%X\n", $y);

print sprintf("%.3f\n", 3.14151692);

#Cadenas de Caracteres

my $cadena = "Brothers\t$x\n";
print $cadena;

$cadena = 'Brothers\t$x\n';
print $cadena;

$cadena = <<SALUDO;
hola,
buenos días,
adios,
SALUDO
print $cadena;

$x = 0;
if ($x){
 print "Verdadero";
}else{
 print "Falso";
}

$x = "";
if ($x){
 print "Verdadero";
}else{
 print "Falso";
}

my $p;
if ($p){
 print "Verdadero";
}else{
 print "Falso";
}

print dump $p;
printf "\n";

#print $p; # Muestra una advertencia, ya que $p vale undef

# Representaciones de datos

my @array = (); # Declaro arreglo e lo inicializo vacío
print dump @array;

print "@array";

@array = (10, 3, 7, "word");
print dump @array;
printf "\n";

push @array, "new"; # Agrega al final del array
print "@array";
printf "\n";

unshift @array, "beginning"; # Agrega al inicio del array
print dump @array;
printf "\n";

splice @array, 2, 0, "between"; # Agrega en una posición arbitraria
print dump @array;
printf "\n";

print $array[3];# Imprimir el 3
printf "\n";

print $#array;
print dump @array;
printf "\n";

my @array2 = @array[1 .. $#array]; # Imprimir 3, 7, "word", necesito un slice
print "@array2";

my $cant = scalar(@array2);
print $cant;

print dump @array[1, 3, 5]; # Slice de posiciones impares
printf "\n";

my $var1 = pop @array;# Retiro el elemento final del arreglo
print "var1:$var1\n";
print "array:", dump @array;

$var1 = shift @array;# Retiro el elemento inicio del arreglo
print "var1:$var1\n";
print "array:", dump @array;
printf "\n";

@array = (1 .. 5);
$var1 = splice @array, 2, 0, ( 6 .. 9 );# Retiro un elemento de una posición arbitraria
print "var1:$var1\n" if defined $var1;
print "array:", dump @array;
printf "\n";

@array2 = @array; # Copia simple
@array2 = ();
print dump @array;

my $array2 = \@array; # Referencia - afecta los cambios de $array2.
@$array2 = ();
print dump @array;
printf "\n";

@array = (1 .. 5);
push @array, @array; # Concatenar 2 listas
print "array:", dump @array;

my @list1 = (0, 1, 2);
my @list2 = (3, 4, 5);
# Producir una lista3 que contenga los valores alternados
# de las 2 listas dadas: (0, 3, 1, 4, 2, 5) en un solo comando.

my @lista3 = (@list1, @list2); # Concatenación de 2 listas simples
print "@lista3"; # Impresión de los miembros de la lista
print dump @lista3; # Impresión de la lista como tal

print \@lista3; # Impresión de la referencia de una lista: la dirección de memoria es la
# La referencia de una variable se obtiene a través de una barra invertida

print dump zip (\@list1, \@list2); # La función zip agrupa los elementos de cada lista d
# Las entradas son referencias a arreglos.
# Produce una lista simple como salida.

$x = [0, 2, 4]; # La variable x guarda la referencia a una lista.
print $x;
print "@$x"; # Desreferenciación de $x
$y = [1, 3, 5];
print dump zip ($x, $y); # Referencias a listas pueden ser variables.
my @list3 = map {$_->[0] + $_->[1]} zip ($x, $y); # La función map desarma las agrupacio
print dump @list3;

print dump none {$_ % 3 == 0} @list3;
printf "\n";


printf "lista1:%s\n", dump @list1;
my ($A, $B) = @list1;
my $suma = $A + $B;
print "Resultado:" . $suma . "\n";
$suma++;
print "Despues de incrementar: $suma \n";
print $suma += 3;


$A = 'Mundo';
$B = 'Hola';
($A, $B) = ($B, $A); # intercambio de variables
print "La famosa frase es $A $B!!! \n";

$cadena = "palabraA\n"; # Se almacena una cadena con \n
chop($cadena); #chomp elimina el \n de la cadena
print "$cadena ya no tiene salto de fila.";

print "\U$cadena\E convertida a mayúscula.";
print "\L$cadena\E convertida a minúscula.";

# Arreglos indexados

my @arreglo = (); # Creamos una lista vacía
print dump @arreglo;

push @arreglo, 3; # Le agregamos un valor al final de la lista mediante push.
print "@arreglo";

push @arreglo, 4; # Otro elemento más mediante push.
print "@arreglo";

# Use el caracter @ para refirirse a todos los miembros del arreglo indexado
print dump @arreglo;

# Use el caracter $ para refirirse a un miembro específico del arreglo indexado
print $arreglo[0];

$arreglo[0] = 5; # Cambiamos el valor de ese elemento
print $arreglo[0];

# Copiar un arreglo hacia otro

@arreglo = (1, 3, 5); # Inicializamos el arreglo
my @foo = @arreglo; # Copiamos el arreglo
@arreglo = (); # Limpiamos el arreglo
print "arreglo:", dump (@arreglo), "\n";
print "foo:", dump (@foo), "\n";

print dump @foo[0, 2]; # Slice del arreglo

#El operador .. genera un rango de valores enteros en una lista.
print dump (-1 .. 3), "\n";
print dump (-2 .. -2), "\n"; # Note que incluye el último elemento.

print dump (reverse -1 .. 3);

print dump (map { $_ / 10 } -1 .. 3);

print dump (grep { $_ > 0 } -1 .. 3);

printf "Indice del último elemento de foo: %d\n", $#foo; # $#foo es el índice del último
printf "Slice de foo: %s\n", dump @foo[0 .. $#foo]; # Slice del arreglo tomando todos lo

# Ejercicio clases Hash

my $db = [
    {nombre => "Ana", notas => [10,20]},
    {nombre => "Luis", notas => [15,25]}
];

printf "Notas de %s: %s\n", $db->[0]->{nombre}, dump $db->[0]->{notas};

for my $estudiante (@$db){
    printf "Promedio de %s: %s\n", $estudiante->{nombre}, sum(@{$estudiante->{notas}}) / @{$estudiante->{notas}};    
}

#printf "Promedio de Ana: %s\n", sum(@{$db->[0]->{notas}}) / @{$db->[0]->{notas}};
#printf "Promedio de Luis: %s\n", sum(@{$db->[1]->{notas}}) / @{$db->[1]->{notas}};

for my $estudiante (@$db){
    
    printf "%s\n", $estudiante->{nombre};
    
    for my $clave (keys %$estudiante){ 
        my $valor = $estudiante->{$clave};
        
        if (ref($valor) eq 'ARRAY') {
            for my $nota (@$valor){
                printf "$nota ";
            }
            printf "\n\n"; 
        }
    }
}

# coje los 2 hash y es independiente del numero de datos
foreach my $persona (@$db) {

    #Bucle con los keys para cuando se aniaden mas
    #Bucle para el asociativo
    
    # key es el String y es variable escalar
    for my $key (keys %$persona) {
        if (ref($persona -> {$key}) eq 'ARRAY'){
            my @notas = @{$persona -> {$key}};
            for my $nota(@notas){
                printf "$nota \t";
            }
            #printf "%s: %d\n", $key, $persona{$key};
            
        }else{
            #Aqui se imprimen escalares
            printf "%s: %s\n", $key , $persona -> {$key};
        }
        printf "\n"
        
    }

}


# Copiar un arreglo hacia otro

@arreglo = (1, 3, 5); # Inicializamos el arreglo
@foo = @arreglo; # Copiamos el arreglo
@arreglo = (); # Limpiamos el arreglo
print "arreglo:", dump (@arreglo), "\n";
print "foo:", dump (@foo), "\n";

print dump @foo[0, 2]; # Slice del arreglo

#El operador .. genera un rango de valores enteros en una lista.
print dump (-1 .. 3), "\n";
print dump (-2 .. -2), "\n"; # Note que incluye el último elemento.

print dump (reverse -1 .. 3);

print dump (map { $_ / 10 } -1 .. 3);

print dump (grep { $_ > 0 } -1 .. 3);

printf "Indice del último elemento de foo: %d\n", $#foo; # $#foo es el índice del último
printf "Slice de foo: %s\n", dump @foo[0 .. $#foo]; # Slice del arreglo tomando todos lo

print $foo[-1], "\n"; # Devuelve el último elemento.
print $foo[-2], "\n"; # Devuelve el penúltimo elemento.

my @A = (95, 7, 'fff' ); # se instancia el arreglo a con 3 elementos
printf "%s\n", $A[-1]; # imprime el último elemento: fff
print "@A"; # imprime los elementos de la lista

my @arreglo1 = (10, 20, 30);
my @arreglo2 = (100, 200);
my @arreglo3 = (@arreglo1, @arreglo2, 8, "es una cadena");
# Nota: Se a inicializado arreglo 3 con dos arreglos y dos
# variables escalares, por lo cual arreglo 3 pasó
# a tener 7 elementos.
my $len_arreglo3 = scalar(@arreglo3);
print "Longitud del arreglo3: ", $len_arreglo3, "\n";
print "Posición del último elemento de arreglo3: ", $#arreglo3, "\n";;
print "Longitud del arreglo3: ", scalar (@arreglo3), "\n";

# imprimir el arreglo
for (my $i = 0; $i < @arreglo3; $i++) {
printf "%d\t%s\n", $i, $arreglo3[$i];
}

print "$_\n" for @arreglo3;

for (@arreglo3){
printf "%s\n", $_;
}

for my $elem (@arreglo3){
printf "%s\n", $elem;
}

while (my ($i, $elem) = each @arreglo3){
printf "%d\t%s\n", $i, $elem;
}

# my @A = (2 .. 7); # $a se instancia con (2,3,4,5,6,7);
my @B = ('a' .. 'e'); # $b instancia con ('a','b','c','d','e')
# print "$_ " for @A;
# print "\n";
# print "$_ " for @B;

# print 'Suma de @A: ', sum(@A);

@A = ('a' .. 'e');
$A = join ":", @A;
print $A; # se obtiene la cadena "a:b:c:d:e"


my @lista = split /[A-Z]+/, "ESsta1es2877una3frase";
print dump @lista;


my $str = "Esta1es2877una3fraseEscuelaPolitecnicaNacional";
my $regex = '[A-Z][a-z]*';
for my $word ($str =~ m/$regex/g){
printf "%s ", $word;
}

@A = ('a' .. 'e'); # Genero un array
@B = splice(@A, 1, 2); # Retiro los a partir de la posicion 1 dos elementos y los guardo
printf "\@A: %s\n", "@A";
printf "\@B: %s\n", "@B";

# Es posible insertar sin eliminar elemento alguno
@A = ( 'a' .. 'e');
@B = ( 1 .. 3);
splice( @A, 2, 0, @B);
print '@a: ', dump (@A), "\n";
# Se imprime ("a", "b", 1, 2, 3, "c", "d", "e");

# Referencia a Arreglos Multidimensionales

my $arreglo = [ [1, 2, 3], [4, -5, 6], [7, 8, 9], [10, 11, 12] ];
print dump $arreglo;
print $arreglo; # Es una referencia

print dump $arreglo->[3]; # Uso la FLECHA para obtener una fila, puesto que la referencia
print $arreglo->[3][1]; # Uso la flecha para obtener un elemento de la referencia $arreg

print dump @{$arreglo->[3]}[0, 2]; # Obtengo un slice de la desreferenciación de la cuart

my $longitud = @$arreglo;
print "# filas: ", $longitud, "\n"; # Longitud del arreglo: número de filas
my $columnas = @{$arreglo->[0]}; # Desreferenciación de la fila 0
print "# columnas: ", $columnas, "\n";

for (my $i = 0; $i < @$arreglo; $i++){ # Barrido de filas.
print dump ($arreglo->[$i]), "\n";
}

for (@$arreglo){ # Barrido de filas.
print dump ($_), "\n";
}

print dump ($_), "\n" for @$arreglo; # Barrido de filas en una linea de código

for (my $i = 0; $i < @$arreglo; $i++){ # Barrido de filas.
for (my $j = 0; $j < @{$arreglo->[$i]}; $j++){ # Barrido de columnas.
print $arreglo->[$i][$j], "\t";
}
print "\n";
}

for my $fila (@$arreglo){ # Barrido de filas.
for my $cell (@$fila){ # Barrido de columnas.
print $cell, "\t";
}
print "\n";
}

# También es posible crear una lista simple conformada por referencias a arreglos.
@arreglo = ( [1, 2, 3], [4, -5, 6], [7, 8, 9], [10, 11, 12] );

for (my $i = 0; $i < @arreglo; $i++){ # Barrido de filas.
print dump ($arreglo[$i]), "\n";
}

for (my $i = 0; $i < @arreglo; $i++){ # Barrido de filas.
for (my $j = 0; $j < @{$arreglo[$i]}; $j++){ # Barrido de columnas.
print $arreglo[$i][$j], "\t";
}
print "\n";
}

my @m1 = ( 1 , "maria" );
my @m2 = ( "pablo", "guillermo", "silvina" );
my @m3 = ( "rosa", "agustin" , 3 );
my @m = ( @m1, @m2, @m3 ); # Concatena las listas: se desarman las agrupaciones
print dump @m;

@m = ( \@m1, \@m2, \@m3 ); # Concatena las referencias: preserva las agrupaciones
print dump @m;


print $#arreglo, "\n"; # Brinda el índice del último elemento
print $#{$arreglo[1]}, "\n"; # Índice del último elemento de la fila 1

@arreglo = ( [1], [2, 3], [4 .. 6], [7, 8], [9]);
for(my $i = 0; $i <= $#arreglo; $i++) {
for(my $j = 0; $j <= $#{$arreglo[$i]}; $j++) {
print $arreglo[$i][$j], "\t"
};
print "\n";
}

@lista = ( [[1, 2, 3], [4, 5, 6], [7, 8, 9] ],
[["a", "b", "c"], ["d", "e", "f"], ["g", "h", "i"] ],
[[-1, -2, -3], [-4, -5, -6], [-7, -8, -9]] );
print $lista[0][1][2], "\n"; # Imprime 6
print $lista[2][2][1], "\n"; # Imprime -8


my $array = [ [[1, 2, 3], [4, 5, 6], [7, 8, 9] ],
[["a", "b", "c"], ["d", "e", "f"], ["g", "h", "i"] ],
[[-1, -2, -3], [-4, -5, -6], [-7, -8, -9]] ];
# Requiere la flecha porque se trata de una referencia a un array, y no de una lista sim
print $array->[0][1][2], "\n";
print $array->[2][2][1], "\n";

#Pilas y Colas con arreglos

#my $var = shift @arreglo;
#print dump $var;

#my $var1 = shift @$var;
#print dump $var1;

@A = ('a' .. 'e');
$B = shift @A; # $b se instancia con 'a'
for (my $n = 0; $n < @A; $n++) {
print $A[$n], " ";
}

@A = ('a' .. 'e');
$B = pop @A; # $b se instancia con 'e'
for (my $n = 0; $n < @A; $n++) {
print $A[$n], " ";
}

printf "\n";

# Se imprimen los valores a, b, c y d
unshift @A, 1; # agrega 1 al principio del arreglo
push @A, 9; # agrega 9 al final del arreglo
for (my $n = 0; $n < @A; $n++) {
print $A[$n], " ";
}

my @pila = (); # se crea la pila
my @datos = (2, 4, 6);
while (@datos) {
unshift @pila, shift @datos; # se agrega un elemento a la pila
}
print "\@datos: ", dump(@datos);
print "\n\@pila: ", dump(@pila);

@pila = (); # se crea la pila
@datos = (2, 4, 6, -1);
while (my $numero = shift @datos) {
unshift @pila, $numero; # se agrega un elemento a la pila
}
print "\@datos: ", dump(@datos);
print "\n\@pila: ", dump(@pila);

@pila = (); # se crea la pila
@datos = (2, 4, 6, -1);
while (@datos) {
unshift @pila, shift @datos; # se agrega un elemento a la pila
}
print "\@datos: ", dump(@datos);
print "\n\@pila: ", dump(@pila);

my $l = @pila;
for(my $i = 0; $i < $l; $i++) {
print shift(@pila), " "; # se extrae elemento de la pila
}

my @enumerate = ('a' .. 'e');
while (my ($i, $valor) = each @enumerate){
printf "i: %d value: %s\n", $i, $valor;
}

#Arreglos Asociativos

my %months = (Jan => 1, Feb => 2, Mar => 3,
              Apr => 4, May => 5, Jun => 6,
              Jul => 7, Aug => 8, Sep => 9,
              Oct => 10, Nov => 11, Dec => 12);
print dump keys %months;

# Por defecto, un arreglo asociativo no preserva el orden de ingreso
print dump values %months;

foreach my $key (keys %months) { # Barrido a través de los keys
print "$key = $months{$key}\n";
}

# Para preservar el orden de ingreso de un arreglo asociativo, declararlo vinculando con
tie my %months2, "Tie::IxHash";
%months2 = (Jan => 1, Feb => 2, Mar => 3,
Apr => 4, May => 5, Jun => 6,
Jul => 7, Aug => 8, Sep => 9,
Oct => 10, Nov => 11, Dec => 12);
print dump keys %months2;
print dump values %months2;

my %stock = (); # Creamos arreglo asociativo vacío
print dump %stock;

%stock = (limones => 6, peras => 3, uvas => 2); # Creamos arreglo asociativo con datos
# Use el caracter % para refirirse a todos los miembros del arreglo asociativo
print dump %stock;

# Use el caracter $ para refirirse a un miembro específico del arreglo asociativo
print $stock{peras};

$stock{peras} = 5; # Cambiamos el valor de ese elemento
print $stock{peras};

$stock{bananas} = 9; # Registro de bananas por primera vez
print dump %stock;

$stock{bananas}--; # Decrementamos el valor de bananas
print dump %stock;

$stock{bananas} -= 3; # Cambiar el valor de bananas
print dump %stock;

if (exists $stock{bananas}){
print "Bananas exist.\n";
}elsif(!exists $stock{bananas}){ # Equivalente a else
print "Bananas do not exist.\n";
}
if (exists $stock{aguacates}){
print "Aguacates exist.\n";
}else{
    print "Aguacates do not exist.\n";
}

# Para eliminar un elemento.
if (exists $stock{bananas}){
delete $stock{bananas};
}
print dump %stock;
# Agregar aguacates:
$stock{aguacates} = 5;
print "\n", dump %stock;

print dump [split ",", "peras, 2"];
sub alimenta_hash{
my %stock = (); # Limpieza del arreglo asociativo
open FILE, "frutas.txt" or die("Error $!");
while (<FILE>){
chomp($_);
map {$stock{$_->[0]} = $_->[1]} [split ",", $_];
}
close FILE or die("Error $!");
return \%stock;
}

my $stock = alimenta_hash();
print dump $stock;

print dump keys %$stock;
print dump (values %$stock);

foreach my $clave (keys %$stock) {
print "$clave = $stock->{$clave}\n";
}

while (my ($key, $value) = each(%$stock)){
print $key, "\t", $value, "\n";
}

undef %$stock;
print dump $stock;
%$stock = ();
print dump $stock;

$stock = alimenta_hash();
foreach my $clave (keys %$stock) {
printf "fruta: %s: %d\n", $clave, $stock->{$clave};
}

print map "$_ = $stock->{$_}\n", keys %$stock;

while (my ($key, $valor) = each %$stock){
print "$key = $valor\n";
}

my %A = ( x => 5, y => 3, z => 'abc' );
@B = keys %A; # @b se instancia con ( 'x', 'y', 'z');
my @v = values %A;
print "keys: @B\n";
print "values: @v\n";

my %dict = ();
map {$dict{$_->[0]} = $_->[1]} zip (\@B, \@v);
print dump %dict;

%A = ( x => 5, y => 3, z => 'abc' );
@v = values %A; # @v se instancia con con ( 5, 3, 'abc' );
print "@v";

%A = ( x => 5, y => 3, z => 'abc' );
$B = exists $A{z}; # $b se instancia con 1, es verdadero
$c = exists $A{w}; # $c queda con "", es falso
print dump ($B, $c);

my %hash = (Apples => 1, apples => 4,
artichokes => 3, Beets=> 9);
foreach my $key (sort keys %hash) {
print "$key = $hash{$key}\n";
}

# Referencias a Hashes

%months = (Jan => 1, Feb => 2, Mar => 3,
Apr => 4, May => 5, Jun => 6,
Jul => 7, Aug => 8, Sep => 9,
Oct => 10, Nov => 11, Dec => 12);

my $monthsref = \%months;
foreach my $key (keys %$monthsref){
#print "$key = $monthsref->{$key}\n";
printf "$key = $monthsref->{$key}\n";
}

# También puedo crear una referencia mediante el uso de las llaves
my $meses = {Jan => 1, Feb => 2, Mar => 3,
Apr => 4, May => 5, Jun => 6,
Jul => 7, Aug => 8, Sep => 9,
Oct => 10, Nov => 11, Dec => 12};

print $meses->{'Jan'};

my %rev_meses = reverse %$meses; # Intercambiamos key con values.
print $rev_meses{1}, "\n";
print dump %rev_meses;

%hash = (Apples => [4, "Delicious red", "medium"],
"Canadian Bacon" => [1, "package", "1/2 pound"]
);

print $hash{"Canadian Bacon"}->[1];

# Agregar nueva entrada en el hash.
$hash{"Garlic"} = [4, "cloves", "medium"];
print $hash{"Garlic"}->[1]; # Imprime cloves

foreach my $key (keys %hash){
print "$key: \n";
foreach my $val (@{$hash{$key}}){
print "\t$val\n";
}
print "\n";
}

#Aprender bien esto
map {print "$_: \n"; map {print "\t$_\n"} @{$hash{$_}}} keys %hash;


my %student = ();
$student{'maria@epn.edu.ec'}{name} = 'Maria';
$student{'maria@epn.edu.ec'}{cedula} = 17889588534;
$student{'maria@epn.edu.ec'}{edad} = 34;
$student{'jose@epn.edu.ec'}{name} = 'Jose';
$student{'jose@epn.edu.ec'}{cedula} = 17897928798;
$student{'jose@epn.edu.ec'}{edad} = 25;
print dump %student;

#Hash de hashes

foreach my $id (keys %student){
printf "correo: %s\n", $id;
printf "name: %s\n", $student{$id}{name};
printf "cedula: %s\n", $student{$id}{cedula};
printf "edad: %d\n\n", $student{$id}{edad};
}

# Definimos una referencia con la misma estructura de datos
my $student = {};
$student->{'maria@epn.edu.ec'}{name} = 'Maria';
$student->{'maria@epn.edu.ec'}{cedula} = 17889588534;
$student->{'maria@epn.edu.ec'}{edad} = 34;
$student->{'jose@epn.edu.ec'}{name} = 'Jose';
$student->{'jose@epn.edu.ec'}{cedula} = 17897928798;
$student->{'jose@epn.edu.ec'}{edad} = 25;
print dump $student;

# Operación Not in set:
my %ignore = map {$_ => 1} ('c', 'ignore');
print dump (keys %ignore);

print dump grep {!exists $ignore{$_}} ('a', 'b', 'c', 'ignore');

#Operadores

$A = 0;
$B = 1;
print "A y B resulta verdadero\n" if $A and $B;
print "A o B resulta verdadero\n" if $A or $B;
print "A xor B resulta verdadero\n" if $A xor $B;
print "A nand B resulta verdadero\n" if not ($A and $B);

#Comparación de números
$x = undef;
$x = $A <=> $B;
# $x queda con -1 si $A < $B
# $x queda con 0 si $A == $B
# $x queda con 1 si $A > $B
print $x;

#Comparación de strings

$x = 'aba' cmp 'abc';
# $x queda con -1 si $A lt $B
# $x queda con 0 si $A eq $B
# $x queda con 1 si $A gt $B
print $x;

my $costo;
$costo = 100 unless $costo; # Si costo no esta definido, inicializarlo con 100
# unless es lo mismo que 'if not'
print $costo;

$A = 5;
$B = undef;
print "variable \$B definida con el valor $A.\n" if defined $A;
print "variable \$B no está definida.\n" if !defined $B;
$costo = 100 unless defined ($costo); # Acuerdese que lo que está a la izquierda
# de unless se ejecuta si
print $costo;

%hash = ();
if (%hash){
print "Variable \%hash definida.\n";
}

@array = ();
if (@array){
print "Variable \@array definida.\n";
}

#Operador de cadenas

$c = $A . " " . "cadena";
print  $c;
print dump (1 .. 5);
print '-' x 5;
@array = ('word') x 5;
print dump @array;

print $A, "\n";
$A++;
print $A, "\n";
print $A++, "\n";
print $A, "\n";

#Estructuras de control

#Ejemplos if

my $objeto = "tiza";
my $requerido = "tiza";
my $cantidad = 22;
if ($objeto eq "tiza") {
print "la variable objeto esta instanciada con tiza\n";
} else {
print "la variable objeto NO esta instanciada con tiza\n";
}
if ($cantidad <= 25) {
print "Hay que reponer " . ((25 - $cantidad) + 3) . " elementos\n";
}

#Ejemplo if-elseif-else

my ($dividendo, $divisor, $resultado) = (4, 2);
if ($divisor == 0) {
print STDERR "Error: no puedo dividir por cero!\n";
}
elsif ($dividendo == 0){
$resultado = $dividendo;
}
elsif ($divisor == 1){
$resultado = $dividendo;
}
else {
$resultado = $dividendo / $divisor;
}
print "El resultado es ", $resultado, "\n" if $divisor != 0;

#Ejemplo unless

my $text = "Ingrese el nombre de un sistema operativo: ";
print $text;
my $nombre = "LINUX";
#if(lc($nombre) eq "linux"){
if($nombre =~ m/linux/i){
print "Ese sí es un buen producto.\n";
}
else{
print "Le pedi que ingresara un nombre de sistema operativo.\n";
}

print "Escriba un número mayor a 10.\n";
my $numero = 10;
unless ($numero > 10) { # If not
print "Error: $numero no es mayor a 10.\n";
}else{
print "Número $numero es mayor a 10.\n";
}

#Ejemplos while

while ($text =~ m/\b([a-z]+)\b/g){
printf "%s\n", $1;
}

my $i = 0;
$suma = 0;
while ($i < 10) {
$suma = $suma + $i++;
}
print "El resultado de la suma es: $suma";

#Ejemplo do while

($i, $suma) = (0, 0);
do{
$suma = $suma + $i++;
}while($i < 10);
print "El resultado de la suma es: $suma";

#Ejemplo until

($i, $suma) = (0, 0);
until($i == 10) { # mientras sea falso = hasta que sea verdad
$suma = $suma + $i++;
}
print "El resultado de la suma es: $suma.\n";
print "El valor de i es: $i.\n";

($i, $suma) = (0, 0);
until($i >= 10) { # Hasta que sea verdadero
$suma = $suma + $i;
$i++;
}
print "El resultado de la suma es: $suma.\n";
print "El valor de i es: $i.\n";

#Ejemplo do until
($i, $suma) = (0, 0);
do{
$suma = $suma + $i++;
}until($i == 10);

print "El resultado de la suma es: $suma.\n";
print "El valor de i es: $i.\n";

#Ejemplo for

$suma = 0;
for(my $i = 0; $i < 10; $i++) {
$suma = $suma + $i;
}
print "El resultado de la suma es $suma \n";

for(my ($i, $j) = (0, 0); $i < 10; $i++, $j+=2) {
printf "i:%d j:%d\n", $i, $j;
}

#Ejemplo foreach

@lista = (7, 11, 22, 5, 6, 7, 45);
foreach my $elemento (@lista) {
printf "%d ", $elemento;
}

$text = "cadena";
print join '- ', ($text =~ m/([^aeiou]+[aeiou]+)/g);

$text = "cadena";
foreach my $syl ($text =~ m/([^aeiou]+[aeiou])/g){
printf "%s\n", $syl;
}

foreach my $elemento (5 .. 9) {
print $elemento . " ";
}

print $_ . " " for @lista;

#Ejemplo last y next

foreach my $elemento (1 .. 10) {
print $elemento . " ";
last if $elemento == 5; # Abandona el bucle
}

foreach my $elemento (1 .. 10) {
next if $elemento == 5; # Saltar la ejecucion 1 vez
print $elemento . " ";
}

# Todo código debe tener al menos esas 3 funciones
use strict; # Forza la declaración de las variables
use warnings; # Genera mensajes de error de sintaxis
use Data::Dump qw(dump); # Para la impresión de estructuras de datos

use List::Util qw(zip min max sum any all first none); # Reorganizar los arreglos con zi
use Tie::IxHash; # Preserva el orden de registro en arreglos asociativos
# use aliased 'jjap::numperl' => 'np';

#Funciones y subrutinas

sub misubrutina{
print "Soy una misubrutina.\n";
}
misubrutina();

#sub maximo {
#my ($var1, $var2) = @_; # @_ contiene los parámetros
#return $var1 > $var2 ? $var1 : $var2;
#}

sub maximo{
return (sort {$b <=> $a} @_)[0]; # @_ contiene los parámetros
}
print maximo(22, 55, 34, 75);

sub saludar{
print "¡Hola $_[0]!\n";
}
saludar("Cesar");
saludar("Sandra");

sub function{
my %args = @_;
foreach my $key (keys %args){
print $key, " ", $args{$key}, "\n";
}
}

function('var1' => 5, 'var2' => 2);

sub function2{
my %args = @_;
print "Nombre: ", $args{nombre}, "\n";
print "Edad: ", $args{edad}, "\n";
}

function2('nombre' => 'Maria', 'edad' => 20);

sub function3{
my %args = (enfermo => 0, @_); # valor por defecto
# enfermo es opcional
if (!defined $args{nombre}){
print STDERR "Argument Nombre faltante.\n";
return;
}
if (!defined $args{edad}){
print STDERR "Argument Edad faltante.\n";
return;
}
print "Nombre: ", $args{nombre}, "\n";
print "Edad: ", $args{edad}, "\n";
print "Enfermo: ", $args{enfermo}, "\n";
}

function3('nombre' => 'Maria', 'edad' => 20);

#function3('nombre' => 'Mario');

function3('nombre' => 'Maria', 'edad' => 20, enfermo => 1);


my @personas = (['nombre' => 'Maria', 'edad' => 20],
['nombre' => 'Jose', 'edad' => 30]);
foreach my $person (@personas){ # foreach
function2(@$person);
}

sub obtiene_frutas{
my @stock = (); # Limpieza del arreglo indexado
open FILE, "frutas.txt" or die("Error $!");
while (<FILE>){
chomp($_);
push @stock, map {['fruta' => $_->[0], 'cantidad' => $_->[1]]} [split ",", $_];
}
close FILE or die("Error $!");
return @stock;
}

sub function4{
my %args = @_;
print "Fruta: ", $args{fruta}, " ";
print "Cantidad: ", $args{cantidad}, "\n";
}

my @stock = obtiene_frutas();
foreach my $fruta (@stock){ # foreach
function4(@$fruta);
}

print dump @stock;

#Variables locales

sub suma{
my($A, $B) = @_; # @_ es la lista de los parámetros recibidos
$A + $B; # se podría haber devuelto el resultado
} # con la función return
print suma(2, 3), "\n";
print suma(3, 35, 22, 5), "\n";

sub suma2{
my $s = 0;
foreach my $x (@_) {
if ($x !~ m/^-?\d+(?:\.\d+)?$/){
print STDERR "Valor '$x' no es un número válido.\n";
return;
}
$s += $x;
}
return $s;
}

print suma2( 1 .. 8, "xa" ), "\n";

#Orientado a objetos

# Una clase tiene atributos (propiedades) y métodos (funciones).
# Se define una clase con la palabra package

# Una clase que tenga un constructor (new) permite crear un objeto.
# Una clase sin constructor se llama clase estática.

package Empleado{
use strict;
use warnings;
sub new{
my ($class, $nombre, $email) = (shift, @_);
my $self = {nombre => $nombre,
email => $email,
};
return bless ($self, $class);
}
sub nombre{
my ($self, $nombre) = @_;
$self->{nombre} = $nombre if $nombre;
return $self->{nombre};
}
sub email{
my ($self, $email) = @_;
$self->{email} = $email if $email;
return $self->{email};
}
1;
}

my $empleado = new Empleado('Maria', 'maria@epn.edu.ec');
print dump $empleado;
print $empleado->nombre();
print $empleado->email();
my $empleado2 = new Empleado();
print dump $empleado2;
$empleado2->nombre('Jose');
$empleado2->email('jose@epn.edu.ec');

print dump $empleado2;

# Herencia

package Sueldo{
use strict;
use warnings;
use base qw(Empleado);
sub new{
my ($class, $dias_trabajados, $sueldo_diario) = (shift, @_);
my $self = {
dias_trabajados => $dias_trabajados // 0,
sueldo_diario => $sueldo_diario // 0,
};
return bless ($self, $class);
}
sub sueldo{
my $self = shift @_;
 print "Father class: ", $self->SUPER::nombre(), "\n";
return $self->{dias_trabajados} * $self->{sueldo_diario};
}
}

my $sueldo = new Sueldo();

print "\n";
print dump $sueldo;

$sueldo->nombre('Brian');
$sueldo->email('brian@epn.edu.ec');

$sueldo->{dias_trabajados} = 22;
$sueldo->{sueldo_diario} = 20;

print dump $sueldo;

print $sueldo->sueldo();


my $sueldo2 = new Sueldo(18, 90);

$sueldo2->nombre('Juan');
$sueldo2->email('juan@epn.edu.ec');

print $sueldo2->sueldo();
print dump $sueldo2;