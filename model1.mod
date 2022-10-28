/*Declaración de sets*/
set Paradas; #Set donde se indica el nombre de las paradas

/*Declaración de parámetros*/

#Vector que almacena la cantidad de gente de cada parada
param gente{i in Paradas};

#Matriz que incluye las distancias entre paradas
param distancia{i in Paradas, j in Paradas};

#Escalar que almacena el coste por autobús
param precio_por_autobus; 

#Escalar que almacena el coste por kilometro
param precio_por_km; 

#Escalar que almacena el número de autobuses disponibles
param n_autobuses; 

#Escalar que almacena la capacidad máxima del autobús
param capacidad_autobus; 

/*Variables de decisión*/

#Variable binaria que vale 1 en cada arco donde pase la una ruta
var x{i in Paradas, j in Paradas} >= 0 binary;

#Variable entera que indica el flujo que entra y sale de cada parada.
var f{i in Paradas, j in Paradas} >= 0 integer; 

/*Función objetivo*/

minimize coste: precio_por_autobus*(sum{j in Paradas} x["o",j]) + precio_por_km*(sum {i in Paradas, j in Paradas} distancia[i,j]*x[i,j]); 

/*Restricciones */

#A la paradas llega como máximo un ruta
s.t. rutas_a{j in Paradas: j != "o" && j != "d"}  : sum{i in Paradas} x[i, j] <= 1; 

#De la paradas sale como máximo una ruta
s.t. rutas_de{i in Paradas: i != "o" && i != "d"}: sum{j in Paradas} x[i, j] <= 1; 

#Al origen no llegan rutas
s.t. a_o_no_llegan : sum{i in Paradas} x[i, "o"] = 0;

#Del destino no salen rutas
s.t. de_d_no_salen : sum{j in Paradas} x["d", j] = 0;

#Los buses que salen del origen están restringidos al número total de autobuses
s.t. max_rutas_o : sum{j in Paradas} x["o", j] <= n_autobuses;  

#El número de buses que sale del origen es el mismo que llega al destino
s.t. rutas_o_d : sum{j in Paradas} x["o", j] = sum{i in Paradas} x[i, "d"]; 

#Si a una parada llega una ruta también sale de ella una ruta
s.t. rutas_entran_y_salen{p in Paradas: p != "o" && p != "d"} : sum{j in Paradas} x[p, j] = sum{i in Paradas} x[i, p]; 

#El flujo que sale de cada parada es el flujo que entra en ella más la gente esperando.
s.t. flujo_entra_sale{p in Paradas: p != "o" && p != "d"}: sum{j in Paradas} f[p, j] = gente[p] + sum{i in Paradas} f[i, p]; 

#El flujo que llega al destino es la suma de la gente esperando
s.t. flujo_final : sum{i in Paradas} f[i, "d"] = sum{i in Paradas} gente[i];  

#El flujo en los arcos en los que no hay ruta vale 0
s.t. flujo_si_no_ruta{i in Paradas, j in Paradas} : f[i, j] - 99*x[i, j] <= 0;

#El flujo no puede superar la capacidad del autobús
s.t. max_flujo{i in Paradas, j in Paradas} : f[i, j] <= capacidad_autobus;  

end;

