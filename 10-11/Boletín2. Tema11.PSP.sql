/*1.-Crear una función que dado un producto devuelva el total de unidades vendidas de dicho
producto. En caso de que no tenga ventas devolverá 0. En caso de que el producto no exista,
devolverá -1.*/
create or replace function unidadesProd(producto number)
return number 
as 
	v_unid number;
begin 
	begin 
		select cod_producto into v_unid from productos
			where cod_producto = producto;

		select nvl(sum(unidades), 0) into v_unid from ventas
			where cod_producto = producto;
	exception 	
		when no_data_found then 
			return -1;
	end;
return v_unid;
end unidadesProd;
/*Función creada.*/

select unidadesProd(1) from dual;		
/*UNIDADESPROD(1)
---------------
              0*/

select unidadesProd(6) from dual;
/*UNIDADESPROD(6)
---------------
             12*/

select unidadesProd(10) from dual;
/*
UNIDADESPROD(10)
----------------
              -1*/


/*2.- Crea un procedimiento que haga lo mismo que la función anterior. El procedimiento tendrá un
argumento de entrada (p_producto) y otro de salida (p_total).*/
create or replace procedure unidProd (
	p_producto number,
	p_total out number)
as 
begin 
	begin 
		select cod_producto into p_total from productos
			where cod_producto = p_producto;

		select nvl(sum(unidades), 0) into p_total from ventas
			where cod_producto = p_producto;
	exception 	
		when no_data_found then 
			p_total := -1;
	end;
end unidProd;
/*Procedimiento creado.*/

declare 
	p_producto number := 6;
	p_total number default 0;
begin
	unidProd (p_producto, p_total);  	
	dbms_output.put_line (p_total);
end;
/*12
Procedimiento PL/SQL terminado correctamente.*/

declare 
	p_producto number := 1;
	p_total number default 0;
begin
	unidProd (p_producto, p_total);  	
	dbms_output.put_line (p_total);
end;	
/*0
Procedimiento PL/SQL terminado correctamente.*/

declare 
	p_producto number := 10;
	p_total number default 0;
begin
	unidProd (p_producto, p_total);  	
	dbms_output.put_line (p_total);
end;
/*-1
Procedimiento PL/SQL terminado correctamente.*/

/*3.- Crear un procedimiento que reciba un NIF y una fecha y muestre el nombre del cliente al que se
le hizo la venta, la descripción del producto y las unidades vendidas. Dar los mensajes oportunos en
caso de que el cliente no exista ó no tenga ventas ese día.*/
create or replace procedure cliDatVenta (
	v_nif varchar2, 
	v_fecha ventas.fecha%type)
as 
	v_nombre clientes.nombre%type;
	v_descrip productos.descripcion%type;
	v_unidades ventas.unidades%type;
	v_no_encontrado number(1) default 0;
begin
	select nombre into v_nombre from clientes
		where nif = v_nif;
		
	v_no_encontrado := 1;
	
	select nombre, descripcion, unidades into v_nombre, v_descrip, v_unidades from clientes, productos, ventas
		where clientes.nif = ventas.nif
		and ventas.cod_producto = productos.cod_producto
		and clientes.nif = v_nif
		and ventas.fecha = v_fecha;
	
	dbms_output.put_line(v_fecha || ': ' || v_nombre || ' - ' || v_descrip || ' - ' || v_unidades || '.');
exception 
	when no_data_found then 
		if v_no_encontrado = 0 then 
			dbms_output.put_line('No existe el cliente.');
		else 
			dbms_output.put_line('No hay ventas ese día.');
		end if;
end cliDatVenta;
/*Procedimiento creado.*/

execute cliDatVenta('333C', '22/09/97');
/*22/09/97: TERESA - PLACA BASE VX - 2.*/

execute cliDatVenta('333C', '30/08/20');
/*No hay ventas ese día.*/

execute cliDatVenta('999J', '22/09/97');
/*No existe el cliente.*/

/*4.- Crear una función que reciba un NIF y devuelva la cantidad de ventas que dicho cliente ha
realizado. Si el cliente no ha hecho ninguna venta devolverá 0. Si el cliente no existe devolverá -1.*/
create or replace function ventasClient(v_nif clientes.nif%type)
return number
as 
	v_dni clientes.nif%type;
	v_unid_vend ventas.unidades%type;
begin 
	select nif into v_dni from clientes
		where nif = v_nif;
		
	select count(*) into v_unid_vend from ventas
		where nif = v_nif;
		
	return v_unid_vend;
exception 
	when no_data_found then 
		return -1;
end ventasClient;
/*Función creada.*/

select ventasClient('333C') from dual;
/*VENTASCLIENT('333C')
--------------------
                   3*/

select ventasClient('999J') from dual;
/*VENTASCLIENT('999J')
--------------------
                  -1*/

select ventasClient('999I') from dual;
/*VENTASCLIENT('999I')
--------------------
                   0*/

/*5.- Crear una función que reciba un nombre de cliente y devuelva la cantidad de ventas que dicho
cliente ha realizado. Utiliza una llamada a la función anterior. Si el cliente no existe devolverá -1.*/
create or replace function ventasClient2(v_nombre clientes.nombre%type)
return number 
as 
	v_dni clientes.nif%type;
	v_unid_vend ventas.unidades%type;
begin 
	select nif into v_dni from clientes
		where nombre = v_nombre;
	
	v_unid_vend := ventasClient(v_dni);
	
	return v_unid_vend;
exception 
	when no_data_found then 
		return -1;
end ventasClient2;
/*Función creada.*/

select ventasClient2('TERESA') from dual;
/*VENTASCLIENT2('TERESA')
-----------------------
                      3*/

select ventasClient2('ANTONIO') from dual;
/*VENTASCLIENT2('ANTONIO')
------------------------
                       0*/
					   
select ventasClient2('CIRO') from dual;
/*VENTASCLIENT2('CIRO')
---------------------
                   -1*/