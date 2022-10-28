/*Declaración de sets*/


#Set donde se indica el conjunto de las paradas
set Paradas; 

#Set donde se indica el conjunto de los alumnos
set Alumnos; 


/*Declaración de parámetros*/


#Matriz que contiene información acerca de los alumnos que son hermanos
param hermanos{i in Alumnos, j in Alumnos}; 


#Matriz que indica a qué paradas se puede asignar a los alumnos sin asignar
param parada_asignable{i in Alumnos, j in Paradas}; 

#Escalar que almacena la cantidad de gente total esperando
param gente_total; 

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

#Variable binaria que vale 1 en cada arco que relaciona a un alumno con una parada
var g{i in Alumnos, j in Paradas} >= 0 binary; 


/*Función objetivo*/


minimize coste: precio_por_autobus*(sum{j in Paradas} x["o",j]) + precio_por_km*(sum {i in Paradas, j in Paradas} distancia[i,j]*x[i,j]);


/*Restricciones */

#A la paradas llega como máximo ruta
s.t. rutas_a{p in Paradas: p != "o" && p != "d"}  : sum{i in Paradas} x[i, p] <= 1; 

#De la paradas sale como máximo una ruta
s.t. rutas_de{p in Paradas: p != "o" && p != "d"}: sum{j in Paradas} x[p, j] <= 1; 

#Al origen no llegan rutas
s.t. a_o_no_llegan : sum{i in Paradas} x[i, "o"] = 0;

#Del destino no salen rutas
s.t. de_d_no_salen : sum{j in Paradas} x["d", j] = 0;

#Los buses que salen del origen están restringidos al número total de autobuses
s.t. max_rutas_o : sum{j in Paradas} x["o", j] <= n_autobuses; 

#Los buses que llegan al destino están restringidos al número total de autobuses
s.t. max_rutas_d : sum{i in Paradas} x[i, "d"] <= n_autobuses; 

#El número de buses que sale del origen es el mismo que llega al destino
s.t. rutas_o_d : sum{j in Paradas} x["o", j] = sum{i in Paradas} x[i, "d"];

#Si a una parada llega una ruta también sale de ella una ruta
s.t. ruta_entra_sale{p in Paradas: p != "o" && p != "d"} : sum{j in Paradas} x[p, j] = sum{i in Paradas} x[i, p]; 

#El flujo que sale de una parada es el flujo que entra en esa parada más la gente esperando 
s.t. flujo_entra_sale{p in Paradas: p != "o" && p != "d"} : (sum{j in Paradas} f[p, j]) - ((sum{i in Paradas} f[i, p]) + sum{i in Alumnos}g[i, p]) = 0; 

#El flujo que llega al destino es la suma de la gente esperando
s.t. flujo_final : sum{i in Paradas} f[i, "d"] = gente_total;

#El flujo en los arcos en los que no haya ruta vale 0
s.t. flujo_si_no_ruta{i in Paradas, j in Paradas} : f[i, j] - 99*x[i, j] <= 0; 

#El flujo no puede superar la capacidad del autobús
s.t. max_flujo{i in Paradas, j in Paradas} : f[i, j] <= capacidad_autobus; 

#Los alumnos solo pueden ser asignados a aquellas paradas que tengan asignables
s.t. disponibles_para_no_asignados{i in Alumnos, j in Paradas} : parada_asignable[i, j] - g[i, j] >= 0; 

#Cada alumno está asignado a una parada
s.t. cada_alumno_asignado{i in Alumnos} : sum{j in Paradas} g[i,j] = 1;

#Aquellos alumnos que sean hermanos deben ser asignados a la misma parada
s.t. hermanos_juntos{i in Alumnos, j in Alumnos, p in Paradas} : hermanos[i, j]*(g[i, p] - g[j, p]) = 0;


end;


