/*1.- Realiza un procedimiento que muestre por cada producto con ventas.
- Nombre Producto1
- Fecha1, unidades, importe y nombre del cliente.
- Fecha2, unidades, importe y nombre del cliente.
…
Nombre Producto2
…
Indicar el total de unidades vendidas al final del informe. Los datos deberán estar ordenados por Producto y Fecha. Nota: No utilices cursor con parámetro.
*/
create or replace procedure productosConVentas
as 
	v_acoplamiento ventas.cod_producto%type;
	cursor c1 is 
		select distinct cod_producto from ventas;
	
	cursor c2 is 
		select fecha, unidades, precio_uni, nombre from ventas v, productos p, clientes c
		where v.cod_producto = v_acoplamiento
		and v.cod_producto = p.cod_producto
		and v.nif = c.nif
		order by p.cod_producto, fecha;
begin 
	for v1 in c1 loop 
		dbms_output.put_line(chr(10) || v1.cod_producto);
		v_acoplamiento := v1.cod_producto;
		
		for v2 in c2 loop 
			dbms_output.put_line(chr(9) || v2.fecha || ' ' || v2.unidades || ' ' || v2.precio_uni || ' ' ||v2.nombre);
		end loop;
	end loop;
end;
/*2
	22/09/97 2 10000 TERESA
	04/10/97 4 10000 MARINA
	04/11/97 3 10000 MARINA
	05/12/97 2 10000 JAIME

3
	18/10/97 3 7000 ANDRES

4
	22/09/97 1 40000 MARINA
	28/09/97 1 40000 JAIME
	10/10/97 3 40000 SANDRA
	16/10/97 2 40000 JAIME
	18/10/97 5 40000 JAIME

5
	26/09/97 5 20000 JAIME

6
	23/09/97 3 25000 SANDRA
	02/10/97 2 25000 VICENTE
	02/10/97 1 25000 SANDRA
	05/10/97 2 25000 JAIME
	22/10/97 2 25000 VICENTE
	02/11/97 2 25000 SANDRA

7
	07/10/97 1 20000 ALBERTO

9
	28/09/97 3 22000 ANDRES
	04/10/97 4 22000 TERESA
	04/12/97 3 22000 TERESA*/

/*2.- Realiza un procedimiento que muestre, para cada venta, la fecha, el nombre del cliente, el nombre y precio del producto, las unidades vendidas y el importe de la venta. 
Ordenar los datos por fecha y cliente. Al final indicar el importe de todas las ventas.*/
create or replace procedure venta
as 
	total number default 0;
	
	cursor c1 is 
		select fecha, nombre, descripcion, precio_uni, unidades, (precio_uni * unidades) importe from ventas v, productos p, clientes c 
			where v.cod_producto = p.cod_producto
			and v.nif = c.nif
			order by fecha, nombre;
begin 	
	for v1 in c1 loop 
		dbms_output.put_line(chr(9) || v1.fecha || ' ' || v1.descripcion || ' ' || v1.precio_uni || ' ' || v1.unidades || ' ' || v1.importe);
		total := total + v1.importe;
	end loop;
	dbms_output.put_line('IMPORTE VENTAS:' || total);
end;
/*22/09/97 DISCO SCSI 4MB 40000 1 40000
	22/09/97 PLACA BASE VX 10000 2 20000
	23/09/97 DISCO IDE 2.5MB 25000 3 75000
	26/09/97 PROCESADOR K6 20000 5 100000
	28/09/97 DIMM SDRAM 32MB 22000 3 66000
	28/09/97 DISCO SCSI 4MB 40000 1 40000
	02/10/97 DISCO IDE 2.5MB 25000 1 25000
	02/10/97 DISCO IDE 2.5MB 25000 2 50000
	04/10/97 PLACA BASE VX 10000 4 40000
	04/10/97 DIMM SDRAM 32MB 22000 4 88000
	05/10/97 DISCO IDE 2.5MB 25000 2 50000
	07/10/97 PROCESADOR MMX 20000 1 20000
	10/10/97 DISCO SCSI 4MB 40000 3 120000
	16/10/97 DISCO SCSI 4MB 40000 2 80000
	18/10/97 SIMM EDO 16MB 7000 3 21000
	18/10/97 DISCO SCSI 4MB 40000 5 200000
	22/10/97 DISCO IDE 2.5MB 25000 2 50000
	02/11/97 DISCO IDE 2.5MB 25000 2 50000
	04/11/97 PLACA BASE VX 10000 3 30000
	04/12/97 DIMM SDRAM 32MB 22000 3 66000
	05/12/97 PLACA BASE VX 10000 2 20000
IMPORTE VENTAS:1251000*/

/*3.- Realiza un procedimiento que muestre por cada cliente con ventas:
Datos del cliente
Nombre Producto 1, Precio, Unidades
Nombre Producto 2, Precio, Unidades
…
PrecioMedioProductosComprados
Mostrar, al final del informe, el cliente que ha comprado más unidades. 
Nota: Utiliza cursor con parámetro.*/
create or replace procedure clienteConVentas
as 
	v_sumaNif number default 0;
	v_precioMedio number(10,2) default 0;
	v_contadorProd number default 0;
	v_clienteMax clientes.nombre%type;
	v_contadorUnidades number default 0;
	
	cursor c1 is 
		select distinct v.nif, nombre, domicilio from clientes c, ventas v
			where c.nif = v.nif;
			
	cursor c2(p_nif clientes.nif%type) is  
		select nombre, descripcion, precio_uni, unidades from productos p, ventas v, clientes c
			where v.nif = p_nif
			and p.cod_producto = v.cod_producto
			and v.nif = c.nif;
begin 
	for v1 in c1 loop 
		dbms_output.put_line(chr(10) || v1.nif || ' ' || v1.nombre || ' ' || v1.domicilio);
		
		for v2 in c2(v1.nif) loop 
			dbms_output.put_line(chr(9) || v2.descripcion || ' ' || v2.precio_uni || ' ' || v2.unidades);
			v_precioMedio := v_precioMedio + v2.precio_uni;
			v_contadorProd := v_contadorProd + 1;
			v_sumaNif := v_sumaNif + v2.unidades;
			v_clienteMax := v2.nombre;
		end loop;
	
		if v_sumaNif > v_contadorUnidades then 
			v_contadorUnidades := v_sumaNif;
		end if;
	
		v_precioMedio := v_precioMedio / v_contadorProd;
		dbms_output.put_line('PRECIO MEDIO PRODUCTOS COMPRADOS: ' || v_precioMedio);
	end loop;
	dbms_output.put_line('CLIENTE CON MÁS UNIDADES COMPRADAS: ' || v_clienteMax || '. ' || v_contadorUnidades || ' unidades.');
end;	
		
execute clienteConVentas;
/*
111A ANDRES POZUELO
	SIMM EDO 16MB 7000 3
	DIMM SDRAM 32MB 22000 3
PRECIO MEDIO PRODUCTOS COMPRADOS: 14500

222B JAIME ARAVACA
	PLACA BASE VX 10000 2
	DISCO SCSI 4MB 40000 1
	DISCO SCSI 4MB 40000 2
	DISCO SCSI 4MB 40000 5
	PROCESADOR K6 20000 5
	DISCO IDE 2.5MB 25000 2
PRECIO MEDIO PRODUCTOS COMPRADOS: 23687,5

333C TERESA LAS ROZAS
	PLACA BASE VX 10000 2
	DIMM SDRAM 32MB 22000 4
	DIMM SDRAM 32MB 22000 3
PRECIO MEDIO PRODUCTOS COMPRADOS: 7062,5

444D VICENTE MADRID
	DISCO IDE 2.5MB 25000 2
	DISCO IDE 2.5MB 25000 2
PRECIO MEDIO PRODUCTOS COMPRADOS: 4389,42

555E SANDRA MADRID
	DISCO SCSI 4MB 40000 3
	DISCO IDE 2.5MB 25000 3
	DISCO IDE 2.5MB 25000 1
	DISCO IDE 2.5MB 25000 2
PRECIO MEDIO PRODUCTOS COMPRADOS: 7022,91

666F ALBERTO POZUELO
	PROCESADOR MMX 20000 1
PRECIO MEDIO PRODUCTOS COMPRADOS: 1501,27

888H MARINA ARAVACA
	PLACA BASE VX 10000 4
	PLACA BASE VX 10000 3
	DISCO SCSI 4MB 40000 1
PRECIO MEDIO PRODUCTOS COMPRADOS: 2928,63
CLIENTE CON MÁS UNIDADES COMPRADAS: MARINA. 54 unidades.
*/

/*4.- Dado un nombre de artículo, una cantidad y un porcentaje, disminuir las existencias del artículo en esa cantidad y aumentar el precio en ese porcentaje. Utiliza excepciones definidas 
por el usuario para controlar que las existencias no pueden ser negativas y que el nuevo precio no debe superar los 10Є.*/
create or replace procedure actualizarInventario(nombre_articulo varchar2, cantidad_bajar number, porcentaje number)
as 
	e_almacen_negativo exception;
	e_precio_superado exception;
	v_cantidad_disminuir number;
	v_porcentaje number;
	v_descripcion productos.descripcion%type;
begin 
	select descripcion into v_descripcion from productos
		where descripcion = nombre_articulo;
		
	select stock, precio_uni into v_cantidad_disminuir, v_porcentaje from productos 
		where descripcion = nombre_articulo;
	
	v_porcentaje := v_porcentaje + (v_porcentaje * porcentaje / 100);
	v_cantidad_disminuir := v_cantidad_disminuir - cantidad_bajar;
	--pasar a euros.
	v_porcentaje := v_porcentaje / 166.38;

	if v_porcentaje > 10 then 
		raise e_precio_superado;
		elsif v_cantidad_disminuir < 0 then 
			raise e_almacen_negativo;
			else 
				update productos set stock = v_cantidad_disminuir, precio_uni = v_porcentaje 
					where descripcion = nombre_articulo;	
	end if;
exception 
	when no_data_found then 
		dbms_output.put_line('No existe el artículo.');
	when e_almacen_negativo then 
		dbms_output.put_line('El almacen se quedaría en negativo.');
	when e_precio_superado then 
		dbms_output.put_line('El precio supera los 10€');
end;
	
--se actualizan estos datos porque sino el stock siempre sería negativo, ya que en todos los casos es 0. 
--se cambia el precio a menos de 10 euros para poder comprobarlo también.
update productos set stock = 30, precio_uni = 1331 where descripcion = 'PROCESADOR P133';

execute actualizarInventario('PROCESADOR P133', 5, 2);
/*COD_PRODUCTO DESCRIPCION     LINEA_ PRECIO_UNI      STOCK
------------ --------------- ------ ---------- ----------
           1 PROCESADOR P133 PROCES          8         25
           2 PLACA BASE VX   PB          10000          0
           3 SIMM EDO 16MB   MEM          7000          0
           4 DISCO SCSI 4MB  DISCOS      40000          0
           5 PROCESADOR K6   PROCES      20000          0
           6 DISCO IDE 2.5MB DISCOS      25000          0
           7 PROCESADOR MMX  PROCES      20000          0
           8 PLACA BASE ATLA PB          50000          0
           9 DIMM SDRAM 32MB MEM         22000          0*/
		   
rollback;

update productos set stock = 30 where descripcion = 'PROCESADOR P133';

execute actualizarInventario('PROCESADOR P133', 5, 2);
/*El precio supera los 10€*/

rollback;

update productos set precio_uni = 1331 where descripcion = 'PROCESADOR P133';

execute actualizarInventario('PROCESADOR P133', 5, 2);
/*El almacen se quedaría en negativo.*/

rollback;

execute actualizarInventario('TARJETA GRAFICA', 5, 2);
/*No existe el artículo.*/

/*5.- Realiza un procedimiento que borre a los dos empleados más nuevos de cada departamento. Utiliza For Update.*/
create or replace procedure borrarNuevos 
as 
	v_dept emple.dept_no%type;
	v_contador number default 0;
	
	cursor c1 is 
		select distinct dept_no from emple;

	cursor c2 is 
		select * from emple 
			where dept_no = v_dept
			order by fecha_alt 
			for update;
begin 
	for v1 in c1 loop 
		v_contador := 1;
		v_dept := v1.dept_no;
		
		for v2 in c2 loop 
			delete emple 
				where current of c2;
				v_contador := v_contador + 1;
				exit when v_contador > 2;
		end loop;
	end loop;
end;

select * from emple 
	order by dept_no, fecha_alt desc;
/*
   EMP_NO APELLIDO   OFICIO            DIR FECHA_AL    SALARIO   COMISION    DEPT_NO
---------- ---------- ---------- ---------- -------- ---------- ---------- ----------
      7934 MUÑOZ      EMPLEADO         7782 23/01/82     169000                    10
      7839 REY        PRESIDENTE            17/11/81     650000                    10
      7782 CEREZO     DIRECTOR         7839 09/06/81     318500                    10
      7902 FERNANDEZ  ANALISTA         7566 03/12/81     390000                    20
      7788 GIL        ANALISTA         7566 09/11/81     390000                    20
      7876 ALONSO     EMPLEADO         7788 23/09/81     143000                    20
      7566 JIMENEZ    DIRECTOR         7839 02/04/81     386750                    20
      7369 SANCHEZ    EMPLEADO         7902 17/12/80     104000                    20
      7900 JIMENO     EMPLEADO         7698 03/12/81     123500                    30
      7654 MARTIN     VENDEDOR         7698 29/09/81     162500     182000         30
      7844 TOVAR      VENDEDOR         7698 08/09/81     195000          0         30
      7698 NEGRO      DIRECTOR         7839 01/05/81     370500                    30
      7521 SALA       VENDEDOR         7698 22/02/81     162500      65000         30
      7499 ARROYO     VENDEDOR         7698 20/02/80     208000      39000         30*/


execute borrarNuevos;
/*
    EMP_NO APELLIDO   OFICIO            DIR FECHA_AL    SALARIO   COMISION    DEPT_NO
---------- ---------- ---------- ---------- -------- ---------- ---------- ----------
      7934 MUÑOZ      EMPLEADO         7782 23/01/82     169000                    10
      7902 FERNANDEZ  ANALISTA         7566 03/12/81     390000                    20
      7788 GIL        ANALISTA         7566 09/11/81     390000                    20
      7876 ALONSO     EMPLEADO         7788 23/09/81     143000                    20
      7900 JIMENO     EMPLEADO         7698 03/12/81     123500                    30
      7654 MARTIN     VENDEDOR         7698 29/09/81     162500     182000         30
      7844 TOVAR      VENDEDOR         7698 08/09/81     195000          0         30
      7698 NEGRO      DIRECTOR         7839 01/05/81     370500                    30
*/















