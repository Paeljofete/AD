/*1.- Crear una función que devuelva la diferencia de precio entre el producto más caro y el más
barato.*/
create or replace function difPrecios
return number
as 
	v_diferencia number;
begin 
	select max(precio_uni) - min(precio_uni) into v_diferencia from productos;
	
	return v_diferencia;
end difPrecios;
/*Función creada.*/	
		
select difPrecios from dual;		
/*DIFPRECIOS
----------
     43000*/
	 
/*2.- Crear un procedimiento que muestre los datos del cliente con domicilio en Las Rozas que
todavía no ha realizado ninguna compra.*/	
create or replace procedure domicilioVentas
as 
	v_cliente clientes%rowtype;
begin 
	select * into v_cliente from clientes
		where domicilio like 'LAS ROZAS'
		and not exists (select nif from ventas	
						where clientes.nif = ventas.nif);
						
	dbms_output.put_line(v_cliente.nombre || ' ' || v_cliente.nif || ' ' || v_cliente.domicilio || '.');
end domicilioVentas;
/*Procedimiento creado.*/

execute domicilioVentas;
/*ANTONIO 999I LAS ROZAS.*/

/*3.- Crear un procedimiento que dado un producto (cod_producto) inserte una venta de 10 unidades
con fecha de hoy para todos los clientes. Dar un mensaje de error apropiado en caso de que no
exista el producto.*/
create or replace procedure insertarVentas (p_prod number)
as
    v_comprorProd productos.cod_producto%type;
begin
    select cod_producto into v_comprorProd from productos
        where cod_producto = p_prod;
	
	insert into ventas
		select distinct nif, p_prod, sysdate, 10 from clientes;

exception
    when no_data_found then
        dbms_output.put_line('El producto no existe.');
end insertarVentas;
/*Procedimiento creado.*/
	 
execute insertarVentas(4);
/*Procedimiento PL/SQL terminado correctamente.
111A                  4 01/11/21         10
222B                  4 01/11/21         10
333C                  4 01/11/21         10
444D                  4 01/11/21         10
555E                  4 01/11/21         10
666F                  4 01/11/21         10
777G                  4 01/11/21         10
888H                  4 01/11/21         10
999I                  4 01/11/21         10*/

execute insertarVentas(10);
/*El producto no existe.
Procedimiento PL/SQL terminado correctamente.*/

/*4.- Crear un procedimiento que muestre los datos del producto con mayor número de ventas.*/
create or replace procedure maxVentas
as 
	v_producto productos%rowtype;
begin 
	select * into v_producto from productos
		where cod_producto in (select cod_producto from ventas	
								group by cod_producto 
								having count(*) = (select max(count(cod_producto)) from ventas			
													group by cod_producto));
													
	dbms_output.put_line('Cod: ' || v_producto.cod_producto || '. Descrip: ' || v_producto.descripcion || '. Línea: ' || v_producto.linea_producto 
		|| '. Precio:  ' || v_producto.precio_uni || '. Stock: ' || v_producto.stock);												
end maxVentas;
/*Procedimiento creado.*/

execute maxVentas;
/*Cod: 6. Descrip: DISCO IDE 2.5MB. Línea: DISCOS. Precio:  25000. Stock: 0*/

/*5.- Crear una función que tenga como argumento el código de un empleado y devuelva la diferencia
entre su salario y el máximo salario de su departamento. La función devolverá -1 si no existe ese
empleado.*/
create or replace function difSalario (num_emp emple.emp_no%type)
return number 
as 
	guardaEmple emple.salario%type;
	guardaSalario emple.salario%type;
begin 
	select salario into guardaEmple from emple 
		where emp_no = num_emp;
	
	select max(salario) into guardaSalario from emple;
		
	guardaSalario := guardaSalario - guardaEmple;
		
	return guardaSalario;
exception 
	when no_data_found then 
		return -1;
end difSalario;
/*Función creada.*/

select difSalario('7369') from dual;
/*DIFSALARIO('7369')
------------------
            546000*/

select difSalario('1000') from dual;
/*DIFSALARIO('1000')
------------------
                -1*/
				
/*6.-Crear un procedimiento que reciba un número n y calcule, en una variable de salida, el porcentaje
que suponen estos n empleados respecto al total de empleados de la base de datos.*/
create or replace procedure porcentajeTotal (n number, salida out number)
as 
	v_total_emple number;
begin 
	select count(*) into v_total_emple from emple;

	salida := (n * 100) / v_total_emple;
end porcentajeTotal;
/*Procedimiento creado.*/

declare 
	salida number(4,2);
begin 
	porcentajeTotal(4, salida);
	dbms_output.put_line(salida || '%.'	);
end;
/*28,57%.
Procedimiento PL/SQL terminado correctamente.*/

























