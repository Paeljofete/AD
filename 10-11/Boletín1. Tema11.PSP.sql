/*1.-Crear un procedimiento que reciba como parámetro un código de empleado y nos muestre por
pantalla el apellido, salario y nombre del departamento donde trabaja, si existe un empleado con
dicho código. En caso contrario, un mensaje de error que indique que el empleado con ese código
no existe.Haz uso de la Excepcion 'NO_DATA_FOUND'.*/
create or replace procedure datosEmpleado(
	v_codDep number)
as 
	v_apell varchar2(20);
	v_salar number(9);
	v_nombDep varchar2(20);
begin
	select apellido, salario, dnombre into v_apell, v_salar, v_nombDep from emple, depart
		where emple.dept_no = depart.dept_no 
		and emp_no = v_codDep;
	dbms_output.put_line(v_apell || '. ' || v_salar || '. ' || v_nombDep || '.');
exception 
	when no_data_found then 
	dbms_output.put_line('No encontrado empleado con el código introducido.');
end datosEmpleado;
/*Procedimiento creado.*/

execute datosEmpleado(7698);
/*NEGRO. 370500. VENTAS.
Procedimiento PL/SQL terminado correctamente.*/

execute datosEmpleado(5200);
/*No encontrado empleado con el código introducido.
Procedimiento PL/SQL terminado correctamente.*/


/*2.- Modifica los ejercicios complementarios 10 y 11 para que den un mensaje de error en caso de
que el empleado (ejercicio 10) ó el departamento (ejercicio 11) no existan. Haz uso de la Excepcion
'NO_DATA_FOUND'.*/
create or replace procedure borrar(
	num_emple emple.emp_no%TYPE)
as
	v_nemp number;
begin
	select emp_no into v_nemp from emple
		where num_emple = emp_no;
	delete from emple where emp_no = num_emple;
	dbms_output.put_line('Empleado borrado.');
exception 
	when no_data_found then 
	dbms_output.put_line('El número de empleado ' || num_emple || ' no existe.');
end borrar;
/*Procedimiento creado.*/

execute borrar(10);
/*El número de empleado 10 no existe.*/

execute borrar(7934);
/*Borrado empleado*7934*MUÑOZ
Empleado borrado.*/


create or replace procedure modificar_localidad(
	num_depart number,
	localidad varchar2)
as
	v_depart number;
begin
	select dept_no into v_depart from depart
		where dept_no = num_depart;
	update depart set loc = localidad
		where dept_no = num_depart;
exception 
	when no_data_found then 
	dbms_output.put_line('Departamento ' || num_depart || ' no reconocido.');
end modificar_localidad;
/*Procedimiento creado.*/

execute modificar_localidad(10, 'MURCIA');
/*Procedimiento PL/SQL terminado correctamente.

   DEPT_NO DNOMBRE        LOC
---------- -------------- --------------
        10 CONTABILIDAD   MURCIA
        30 VENTAS         BARCELONA
        40 PRODUCCION     BILBAO
        99 PROVISIONAL
*/

execute modificar_localidad(50, 'GRANADA');
/*Departamento 50 no reconocido.*/


/*3.- Modifica los ejercicios complementarios 10 y 11 para que den un mensaje de error en caso de
que el empleado (ejercicio 10) ó el departamento (ejercicio 11) no existan. Haz uso del atributo
'SQL%ROWCOUNT'.*/
create or replace procedure borrar(
	num_emple emple.emp_no%TYPE)
as
	v_nemp number;
	cuenta number;
begin
	delete from emple where emp_no = num_emple;
	dbms_output.put_line('Empleado borrado.');
	cuenta := sql%rowcount;
	dbms_output.put_line(cuenta);
end borrar;
/*Procedimiento creado.*/

execute borrar(10);
/*Empleado borrado.
0*/

execute borrar(7934);
/*Borrado empleado*7934*MUÑOZ
Empleado borrado.
1*/


create or replace procedure modificar_localidad(
	num_depart number,
	localidad varchar2)
as
	v_depart number;
	cuenta number;
begin
	update depart set loc = localidad
		where dept_no = num_depart;
	cuenta := sql%rowcount;
	dbms_output.put_line(cuenta);
end modificar_localidad;
/*Procedimiento creado.*/

execute modificar_localidad(10, 'MURCIA');
/*1*/

execute modificar_localidad(50, 'GRANADA');
/*0*/

/*4.-Modifica el ejercicio propuesto 3 del tema para que muestre mensajes de error diferentes en caso
de que el empleado o el departamento no existan. Haz uso de bloques anidados y de la Excepción
'NO_DATA_FOUND'.*/
create or replace procedure asignar_departamento(
	num_empleado number, 
	v_nuevo_depart number)
as 
	v_anterior_depart emple.dept_no%type;
begin 
	select dept_no into v_anterior_depart from emple
		where emp_no = num_empleado;
		
	declare 
		v_comprodepart emple.dept_no%type;
	begin 	
		select dept_no into v_comprodepart from depart
			where dept_no = v_nuevo_depart;
			
		update emple set dept_no = v_nuevo_depart
			where emp_no = num_empleado;
			
		dbms_output.put_line(num_empleado || '*Departamento anterior: ' || v_anterior_depart || '. * Departamento nuevo: ' || v_nuevo_depart);
	exception 
		when no_data_found then 
		dbms_output.put_line('Departamento ' || v_comprodepart || ' no reconocido.');
	end;
exception 
	when no_data_found then 
	dbms_output.put_line('Empleado ' || num_empleado || ' no reconocido.');
end asignar_departamento;
/*Procedimiento creado.*/

execute asignar_departamento(7521, 99);
/*7521*Departamento anterior: 30. * Departamento nuevo: 99*/

execute asignar_departamento(10, 99);
/*Empleado 10 no reconocido.*/

execute asignar_departamento(7521, 50);
/*Departamento  no reconocido.*/


/*5.- Realiza un procedimiento que consiga la misma salida que el ejercicio anterior haciendo uso de
un solo bloque y de una variable bandera.*/
create or replace procedure asignar_departamento(
	num_empleado number,
	v_nuevo_depart number)
as 
	v_anterior_depart emple.dept_no%type;
	v_comprodepart emple.dept_no%type;
	bandera number:= 0;
begin 
	select dept_no into v_anterior_depart from emple
		where emp_no = num_empleado;
		
	bandera := 1;

	select dept_no into v_comprodepart from depart
		where dept_no = v_nuevo_depart;
			
	update emple set dept_no = v_nuevo_depart
		where emp_no = num_empleado;
		
	dbms_output.put_line(num_empleado || '*Departamento anterior: ' || v_anterior_depart || '. * Departamento nuevo: ' || v_nuevo_depart);
exception 
		when no_data_found then 
			if bandera = 1 then 
				dbms_output.put_line('Departamento ' || v_comprodepart || ' no reconocido.');
			else 
				dbms_output.put_line('Empleado ' || num_empleado || ' no reconocido.');
			end if;
end asignar_departamento;
/*Procedimiento creado.*/
	
execute asignar_departamento(7521, 99);
/*7521*Departamento anterior: 30. * Departamento nuevo: 99*/

execute asignar_departamento(10, 99);
/*Empleado 10 no reconocido.*/

execute asignar_departamento(7521, 50);
/*Departamento  no reconocido.*/


/*6.- Realiza un procedimiento que consiga la misma salida que el ejercicio 4 haciendo uso de dos
funciones: busca_empleado y busca_departamento que devolverán -1 en caso de que no exista el
dato.*/
create or replace function busca_empleado (codigo number)
return number
as
	v_codEmple number(4);
begin
	select emp_no into v_codEmple from emple 
		where emp_no = codigo;
	
	dbms_output.put_line('Empleado: ' || v_codEmple);
	return v_codEmple;
exception 
	when no_data_found then		
		dbms_output.put_line('Empleado no reconocido.');
		return -1;	
end busca_empleado;
/*Función creada.*/

begin dbms_output.put_line(busca_empleado(10)); 
end;
/*Empleado no reconocido.
-1*/

begin dbms_output.put_line(busca_empleado(7934)); 
end;
/*Empleado: 7934
7934*/

create or replace function buscar_departamento(departamento number)
return number
as
	v_codDepart number(4);
begin
	select dept_no into v_codDepart from depart 
		where dept_no = departamento;
		
		dbms_output.put_line('Departamento: ' || v_codDepart);
		return v_codDepart;
exception 
	when no_data_found then 
		dbms_output.put_line('Departamento no reconocido.');
		return -1;
end buscar_departamento;
/*Función creada.*/

begin dbms_output.put_line (buscar_departamento (50));
end;
/*Departamento no reconocido.
-1*/

begin dbms_output.put_line (buscar_departamento (30));
end;
/*Departamento: 30
30*/

create or replace procedure asignar_departamento(
	num_empleado number,
	v_nuevo_depart number)
as 
	v_codEmple number;
	v_codDepart number;
begin 
	v_codEmple := busca_empleado(num_empleado);
	v_codDepart := buscar_departamento(v_nuevo_depart);
	
	update emple set dept_no = v_nuevo_depart
	where emp_no = num_empleado;
end asignar_departamento;
	
execute asignar_departamento(7934, 30);
/*Empleado: 7934
Departamento: 30*/

execute asignar_departamento(10, 30);
/*Empleado no reconocido.
Departamento: 30*/

execute asignar_departamento(7934, 50);
/*Empleado: 7934
Departamento no reconocido.*/

execute asignar_departamento(10, 50);
/*Empleado no reconocido.
Departamento no reconocido.*/




















