--Tema 10.

--CASO PRÁCTICO 1.
/*En el siguiente ejemplo se borra el departamento número 20, pero evitando posibles errores por violar restricciones
de integridad referencial, pues el departamento tiene empleados asociados. Para ello crearemos antes un departamento
provisional, al que asignamos los empleados del departamento 20 antes de borrar dicho departamento. El programa
también informa del número de empleados afectados.*/
declare 
    v_num_empleados number(2);
begin   
    insert into depart 
        values(99, 'PROVISIONAL', null);

    update emple set dept_no = 99
        where dept_no = 20;

    v_num_empleados := sql%rowcount;

    delete from depart
        where dept_no = 20;

    dbms_output.put_line(v_num_empleados || ' Empleado ubicados en PROVISIONAL.');
exception
    when others then 
        raise_application_error(-20000, 'Error en aplicación.');
end;
/*5 Empleado ubicados en PROVISIONAL.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 2.
/*El siguiente bloque visualiza el apellido y el oficio del empleado cuyo número es 7900.*/
declare 
    v_ape varchar2(10);
    v_oficio varchar2(10);
begin 
    select apellido, oficio into v_ape, v_oficio from emple     
        where emp_no = 7900;
    
    dbms_output.put_line(v_ape || ' * ' || v_oficio || '.');
end;
/*JIMENO * EMPLEADO.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 3.
/*El ejemplo anterior, con gestión de excepciones, sería:*/
declare 
    v_ape varchar2(10);
    v_oficio varchar2(10);
begin 
    select apellido, oficio into v_ape, v_oficio from emple 
        where emp_no = 7900;
    
    dbms_output.put_line(v_ape || ' * ' || v_oficio || '.');
exception   
    when no_data_found then 
        raise_application_error(-20000, 'Error no hay datos.');
    when too_many_rows then 
        raise_application_error(-20000, 'Error demasiados datos.');
    when others then 
        raise_application_error(-20000, 'Error en la aplicación.');
end;

----------------------------------------------------------------------------------

--CASO PRÁCTICO 4.
/*El siguiente código crea un trigger que se ejecutará automáticamente cuando se elimine algún empleado en la tabla
correspondiente visualizando el número y el nombre de los empleados borrados:*/
create or replace trigger audit_borrado_emple
    before delete on emple for each row 
begin 
    dbms_output.put_line('Borrado empleado: ' || :old.emp_no || ' - ' || :old.apellido || '.');
end;

----------------------------------------------------------------------------------

--CASO PRÁCTICO 5.
/*El siguiente programa solicitará la introducción de un número de cliente y visualizará el nombre del cliente correspondiente
con el número introducido. Para introducir el número de cliente recurriremos a las variables de sustitución de SQL*Plus.*/
declare 
    v_nom clientes08.nombre%type;
begin 
    select nombre into v_nom from clientes08
        where cliente_no = &vn_cli;
    
    dbms_output.put_line(v_nom);
end;
/*Introduzca un valor para vn_cli: 102
antiguo   5:         where cliente_no = &vn_cli;
nuevo   5:         where cliente_no = 102;
LOGITRONICA S.L
Procedimiento PL/SQL terminado correctamente.
*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 6.
/*Introduciendo estas líneas desde el indicador de SQL*Plus dispondremos de un procedimiento PL/SQL sencillo para
consultar los datos de un cliente:*/
create or replace procedure ver_depart(numdepart number)
as 
    v_dnombre varchar2(14);
    v_localidad varchar2(14);
begin 
    select dnombre, loc into v_dnombre, v_localidad from depart 
        where dept_no = numdepart;

    dbms_output.put_line('Núm. depart: ' || numdepart || '. Nombre depart: ' || v_dnombre || '. Localidad: ' || v_localidad || '.');
exception   
    when no_data_found then 
        dbms_output.put_line('No encontrado el departemento.');
end;

execute ver_depart(20);
/*Núm. depart: 20. Nombre depart: INVESTIGACION. Localidad: MADRID.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 7.
/*Ejemplos de aplicación:
1. En el siguiente procedimiento se visualiza el precio de un producto cuyo número se pasa como parámetro.*/
create or replace procedure ver_precio(v_num_producto number)
as 
    v_precio number;
begin 
    select precio_uni into v_precio from productos 
        where cod_producto = v_num_producto;

    dbms_output.put_line('Precio actual: ' || v_precio || '.') ;
end;

execute ver_precio(3);
/*Precio actual: 7000.
Procedimiento PL/SQL terminado correctamente.*/

/*2. Escribiremos un procedimiento que modifique el precio de un producto pasándole el número del producto y el nuevo precio.
El procedimiento comprobará que la variación de precio no supere el 20 por 100:*/
create or replace procedure modificar_precio_producto(
    numproducto number, 
    nuevoprecio number)
as 
    v_precioant number(5);
begin 
    select precio_uni into v_precioant from productos 
        where cod_producto = numproducto;

    if(v_precioant * 0.2) > (nuevoprecio - v_precioant) then 
        update productos set precio_uni = nuevoprecio 
            where cod_producto = numproducto;
    else 
        dbms_output.put_line('Error, modificación supera 20%.');
    end if;
exception 
    when no_data_found then 
        dbms_output.put_line('No encontrado producto ' || numproducto);
end;

execute modificar_precio_producto(3, 10000);
/*Error, modificación supera 20%.
Procedimiento PL/SQL terminado correctamente.*/

execute modificar_precio_producto(11, 10000);
/*No encontrado producto 11
Procedimiento PL/SQL terminado correctamente.*/

execute modificar_precio_producto(3, 7100);
/*Procedimiento PL/SQL terminado correctamente.*/

/*3. Escribiremos una función que devuelva el valor con IVA de una cantidad que se pasará como primer parámetro. La función
también podrá recoger un segundo parámetro opcional, que será el tipo de IVA siendo el valor por defecto 16.*/
create or replace function con_iva(
    cantidad number, 
    tipo number default 16)

    return number
as 
    v_resultado number(10,2) default 0;
begin 
    v_resultado := cantidad * (1 + (tipo / 100));

    return(v_resultado);
end;

begin dbms_output.put_line(con_iva(200));
end;
/*232
Procedimiento PL/SQL terminado correctamente.*/

select cod_producto, precio_uni, con_iva(precio_uni) precio_con_iva from productos;
/*COD_PRODUCTO PRECIO_UNI PRECIO_CON_IVA
------------ ---------- --------------
           1      15000          17400
           2      10000          11600
           3       7100           8236
           4      40000          46400
           5      20000          23200
           6      25000          29000
           7      20000          23200
           8      50000          58000
           9      22000          25520*/

----------------------------------------------------------------------------------

--ACTIVIDADES COMPLEMENTARIAS.

/*1. Construye un bloque PL/SQL que escriba el texto 'Hola'.*/
declare 
begin 
    dbms_output.put_line('Hola.');
end;
/*Hola.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*2. ¿Qué hace el siguiente bloque PL/SQL?
DECLARE
    v_num NUMBER;
BEGIN
    SELECT count(*) INTO v_num FROM productos;
    DBMS_OUTPUT.PUT_LINE(v_num);
END;*/

Cuenta el número de filas que tiene la tabla productos.
/*9
Procedimiento PL/SQL terminado correctamente*/

----------------------------------------------------------------------------------

/*3. Introduce el bloque anterior desde SQL*Plus y guardarlo en un fichero.*/
save c:\fichero.sql replace;
/*Escrito fichero c:\fichero.sql*/

----------------------------------------------------------------------------------

/*4. Ejecuta la orden SELECT especificada en el bloque
anterior desde SQL*Plus sin la cláusula INTO.*/
select count(*) from productos;
/*  COUNT(*)
----------
         9*/

----------------------------------------------------------------------------------

/*5. Carga y ejecuta el bloque de nuevo, y comprueba que
el resultado aparece en pantalla.*/
start c:\fichero.sql;
/*9
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*6. Escribe desde SQL*Plus el ejemplo número 1 del epígrafe
«Uso de subprogramas almacenados» y prueba a
ejecutarlo con distintos valores.*/
create or replace procedure ver_depart (numdepart number)
as 
	v_dnombre VARCHAR2(14);
	v_localidad VARCHAR2(14);
begin 
	select dnombre, loc into v_dnombre, v_localidad from depart
		where dept_no = numdepart;
	dbms_output.put_line('Num depart: ' || numdepart || '* Nombre dep: ' || v_dnombre || '* Localidad: ' || v_localidad);
exception 
	when no_data_found then 
	dbms_output.put_line('No encontrado departamento ');
end ver_depart;

execute ver_depart(10);
/*Num depart: 10* Nombre dep: CONTABILIDAD* Localidad: SEVILLA
Procedimiento PL/SQL terminado correctamente.*/

execute ver_depart(50);
/*No encontrado departamento
Procedimiento PL/SQL terminado correctamente.*/

execute ver_depart(99);
/*Num depart: 99* Nombre dep: PROVISIONAL* Localidad:
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*7. Identifica en el ejemplo número 2 del epígrafe «Uso
de subprogramas almacenados» los siguientes elementos:*/

	-- La cabecera del procedimiento.
	create or replace procedure 
	-- El nombre del procedimiento.
	modificar_precio_producto
	-- Los parámetros del procedimiento.
	(numproducto number, nuevoprecio number)
	-- Las variables locales.
	v_precioant number(5)
	-- el comienzo y el final del bloque PL/SQL 
	create or replace procedure modificar_precio_producto(numproducto number, nuevoprecio number) / end modificar_precio_producto;
	-- El comienzo y el final de la sección declarativa, ejecutable y de gestión de excepciones.
	as / begin / exception
	-- ¿Qué hace la cláusula into? 
	guarda el dato obtenido de la consulta en la variable local creada en el procedimiento.
	-- ¿Qué hace when_no_data_found? 
	devuelve una excepción de dato no encontrado.
	-- ¿Por qué no tiene la cláusula declare? ¿Qué tiene en su lugar?
	porque no es un bloque, es un procedimiento y tiene el create procedure.

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--Tema 11.

--ACTIVIDAD PROPUESTA 1.
/*Indica los errores que aparecen en las siguientes instrucciones y la forma de corregirlos.*/
declare 
	num1 number(8,2) := 0				--falta el ;
	num2 number(8,2) not null := 0;		
	num3 number(8,2) not null;			--falta inicializar.
	cantidad integer(3);				
	precio, descuento number(6);		--hay que separarlas, no se pueden declarar así. precio number(6); descuento number(6);
	num4 num1%rowtype;					--está copiando una tabla con el rowtype, tendría que ser num4 num1%type.
	dto constant integer;				--siempre tiene que inicializarse. 
begin   
    ...
end;

----------------------------------------------------------------------------------

--CASO PRÁCTICO 1.
/*Supongamos que pretendemos modificar el salario de un empleado especificado en función del número de empleados
que tiene a su cargo:
    – Si no tiene ningún empleado a su cargo la subida será 50 €.
    – Si tiene 1 empleado la subida será 80 €.
    – Si tiene 2 empleados la subida será 100 €.
    – Si tiene más de tres empleados la subida será 110 €.
Además, si el empleado es PRESIDENTE se incrementará el salario en 30 €.*/
declare 
    v_empleado_no number(4,0);
    v_c_empleados number(2);
    v_aumento number(7) default 0;
    v_oficio varchar2(10);
begin 
    v_empleado_no := &vt_empno;

    select oficio into v_oficio from emple 
        where emp_no = v_empleado_no;

    if v_oficio = 'PRESIDENTE' then 
        v_aumento := 30;
    end if;

    select count(*) into v_c_empleados from emple 
        where dir = v_empleado_no;

    if v_c_empleados = 0 then 
        v_aumento := v_aumento + 50;
    elsif v_c_empleados = 1 then 
        v_aumento := v_aumento + 80;
    elsif v_c_empleados = 2 then 
        v_aumento := v_aumento + 100;
    else 
        v_aumento := v_aumento + 110;
    end if;

    update emple set salario = salario + v_aumento 
        where emp_no = v_empleado_no;
    
    dbms_output.put_line(v_aumento);
end;
/*Introduzca un valor para vt_empno: antiguo   7:     v_empleado_no := &vt_empno;
nuevo   7:     v_empleado_no := 7782;
80
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 2.
/*Supongamos que deseamos analizar una cadena que contiene los dos apellidos para guardar el primer apellido en una
variable a la que llamaremos v_1apel. Entendemos que el primer apellido termina cuando encontramos cualquier
carácter distinto de los alfabéticos (en mayúsculas).*/
declare 
    v_apellidos varchar2(25);
    v_1apel varchar2(25);
    v_caracter char;
    v_posicion integer := 1;
begin 
    v_apellidos := '&vs_apellidos';

    v_caracter := substr(v_apellidos, v_posicion, 1);

    while v_caracter between 'a' and 'z' loop 
        v_1apel := v_1apel || v_caracter;
        v_posicion := v_posicion + 1;
        v_caracter := substr(v_apellidos, v_posicion, 1);
    end loop;

    dbms_output.put_line('Primer apellido: ' || v_1apel || '*');
end;
/*Introduzca un valor para vs_apellidos: antiguo   7:     v_apellidos := '&vs_apellidos';
nuevo   7:     v_apellidos := 'sanchez perez';
Primer apellido: sanchez*
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 3.
/*Vamos a construir de dos maneras un bloque PL/SQL que escriba la cadena 'HOLA' al revés.*/
--Bucle for.
declare 
    r_cadena varchar2(10);
begin 
    for i in reverse 1..length('Hola') loop 
        r_cadena := r_cadena || substr('Hola', i, 1);
    end loop;

    dbms_output.put_line(r_cadena);
end;
/*aloH
Procedimiento PL/SQL terminado correctamente.*/

--Bucle while.  
declare 
    r_cadena varchar2(10);
    i binary_integer;
begin 
    i := length('Hola');

    while i >= 1 loop 
        r_cadena := r_cadena || substr('Hola', i, 1);
        i := i - 1;
    end loop;

    dbms_output.put_line(r_cadena);
end;
/*aloH
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 2.´
/*Escribe un bloque PL/SQL que realice la misma función del ejemplo anterior pero usando un bucle ITERAR.*/
declare 
    r_cadena varchar2(10);
    i binary_integer;
begin   
    i := length('Hola');

    loop 
        r_cadena := r_cadena || substr('Hola', i, 1);
    exit when i <= 1;
        i := i - 1;
    end loop;

    dbms_output.put_line(r_cadena);
end;
/*aloH
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 4.
/*Crearemos un procedimiento que reciba un número de empleado y una cadena correspondiente a su nuevo oficio.
El procedimiento deberá localizar el empleado, modificar el oficio y visualizar los cambios realizados.*/
create or replace procedure cambiar_oficio(
    num_empleado number, 
    nuevo_oficio varchar2)
as 
    v_anterior_oficio emple.oficio%type;
begin 
    select oficio into v_anterior_oficio from emple 
        where emp_no = num_empleado;
    
    update emple set oficio = nuevo_oficio 
        where emp_no = num_empleado;

    dbms_output.put_line(num_empleado || ' Oficio anterior: ' || v_anterior_oficio || ' - nuevo oficio: ' || nuevo_oficio);
end;

execute cambiar_oficio(7902, 'DIRECTOR');
/*7902 Oficio anterior: DIRECTOR - nuevo oficio: DIRECTOR
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 3.
/*Escribe un procedimiento con funcionalidad similar al ejemplo anterior,
que recibirá un número de empleado y un número de departamento y
asignará al empleado el departamento indicado en el segundo parámetro.*/
create or replace procedure cambiar_depart(
    num_empleado emple.emp_no%type,
    num_depart emple.dept_no%type)
as 
    v_depart_anterior emple.dept_no%type;
begin 
    select dept_no into v_depart_anterior from emple 
        where emp_no = num_empleado;
    
    update emple set dept_no = num_depart 
        where emp_no = num_empleado;
    
    dbms_output.put_line(num_empleado || '. Departamento anterior: ' || v_depart_anterior || ' - nuevo departamento: ' || num_depart || '.');
end;

execute cambiar_depart(7782, 40);
/*7782. Departamento anterior: 10 - nuevo departamento: 40.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 4.
/*Dado el siguiente procedimiento:*/
create or replace procedure crear_depart(
    v_num_dept depart.dept_no%type,
    v_dnombre depart.dnombre%type default 'PROVISIONAL',
    v_loc depart.loc%type default 'PROVISIONAL')
as 
begin   
    insert into depart 
        values(v_num_dept, v_dnombre, v_loc);
end;

/*Indica cuáles de las siguientes llamadas son correctas y cuáles incorrectas. En el caso de que sean incorrectas, escribe la llamada
correcta usando la notación posicional, siempre que sea posible:*/
execute crear_depart; --No hay parámetros.
/*BEGIN crear_depart; END;
      *
ERROR en línea 1:
ORA-06550: línea 1, columna 7:
PLS-00306: número o tipos de argumentos erróneos al llamar a 'CREAR_DEPART'
ORA-06550: línea 1, columna 7:
PL/SQL: Statement ignored*/

execute crear_depart(50); --Pondrá los datos por defectos que vienen dado en el procedimiento, PROVISIONAL.
/*Procedimiento PL/SQL terminado correctamente.
/*   DEPT_NO DNOMBRE        LOC
---------- -------------- --------------
        10 CONTABILIDAD   SEVILLA
        20 INVESTIGACION  MADRID
        30 VENTAS         BARCELONA
        40 PRODUCCION     BILBAO
        50 PROVISIONAL    PROVISIONAL*/

execute crear_depart('COMPRAS'); --El primer parámetro de entrada debe ser numérico.
/*BEGIN crear_depart('COMPRAS'); END;
*
ERROR en línea 1:
ORA-06502: PL/SQL: error: error de conversión de carácter a número numérico o de valor
ORA-06512: en línea 1*/

execute crear_depart(50,'COMPRAS');
/*Procedimiento PL/SQL terminado correctamente.
   DEPT_NO DNOMBRE        LOC
---------- -------------- --------------
        10 CONTABILIDAD   SEVILLA
        20 INVESTIGACION  MADRID
        30 VENTAS         BARCELONA
        40 PRODUCCION     BILBAO
        50 COMPRAS        PROVISIONAL*/

execute crear_depart('COMPRAS', 50); --El primer parámetro de entrada debe ser numérico.
/*BEGIN crear_depart('COMPRAS', 50); END;
*
ERROR en línea 1:
ORA-06502: PL/SQL: error: error de conversión de carácter a número numérico o de valor
ORA-06512: en línea 1*/

execute crear_depart('COMPRAS', 'VALENCIA'); --El primer parámetro de entrada debe ser numérico.
/*BEGIN crear_depart('COMPRAS', 'VALENCIA'); END;
*
ERROR en línea 1:
ORA-06502: PL/SQL: error: error de conversión de carácter a número numérico o de valor
ORA-06512: en línea 1*/

execute crear_depart(50,'COMPRAS', 'VALENCIA');
/*Procedimiento PL/SQL terminado correctamente.
   DEPT_NO DNOMBRE        LOC
---------- -------------- --------------
        10 CONTABILIDAD   SEVILLA
        20 INVESTIGACION  MADRID
        30 VENTAS         BARCELONA
        40 PRODUCCION     BILBAO
        50 COMPRAS        VALENCIA*/

execute crear_depart('COMPRAS',50, 'VALENCIA'); --El primer parámetro de entrada debe ser numérico.
/*BEGIN crear_depart('COMPRAS',50, 'VALENCIA'); END;
*
ERROR en línea 1:
ORA-06502: PL/SQL: error: error de conversión de carácter a número numérico o de valor
ORA-06512: en línea 1*/

execute crear_depart('VALENCIA', 'COMPRAS'); --El primer parámetro de entrada debe ser numérico.
/*BEGIN crear_depart('VALENCIA', 'COMPRAS'); END;
*
ERROR en línea 1:
ORA-06502: PL/SQL: error: error de conversión de carácter a número numérico o de valor
ORA-06512: en línea 1*/

execute crear_depart('VALENCIA', 50); --El primer parámetro de entrada debe ser numérico.
/*BEGIN crear_depart('VALENCIA', 50); END;
*
ERROR en línea 1:
ORA-06502: PL/SQL: error: error de conversión de carácter a número numérico o de valor
ORA-06512: en línea 1*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 5.
/*Supongamos que nos han solicitado un programa de cambio de divisas para un banco que cumpla las siguientes especificaciones:
    – Recibirá una cantidad en euros y el cambio (divisas/euro) de la divisa.
    – También podrá recibir una cantidad correspondiente a la comisión que se cobrará por la transacción. En el caso de que
    no reciba dicha cantidad el programa calculará la comisión que será de un 0,2% del importe, con un mínimo de 3 euros.
    – El programa calculará la comisión, la deducirá de la cantidad inicial y calculará el cambio en la moneda deseada, retornando
    estos dos valores (comisión y cambio) a los parámetros actuales del programa que realice la llamada para solicitar
    el cambio de divisas.*/
create or replace procedure cambiar_divisas(
    cantidad_euros in number,
    cambio_actual in number,
    cantidad_comision in out number,
    cantidad_divisas out number)
as 
    pct_comision constant number(3,2) := 0.2;
    minimo_comision constant number(6) default 3;
begin 
    if cantidad_comision is null then 
        cantidad_comision := greatest(cantidad_euros / 100 * pct_comision, minimo_comision);
    end if;

    cantidad_divisas := (cantidad_euros - cantidad_comision) * cambio_actual;
end;

/*Una vez creado el procedimiento podremos diseñar programas que hagan uso de él teniendo en cuenta que los parámetros
formales para llamar al programa deberán ser cuatro. De éstos, los dos últimos deberán ser variables, que recibirán los valores
de la ejecución del programa, tal como aparece en el siguiente procedimiento:*/
create or replace procedure mostrar_cambio_divisas(
    eur number,
    cambio number)
as 
    v_comision number(9);
    v_divisas number(9);
begin 
    cambiar_divisas(eur, cambio, v_comision, v_divisas);

    dbms_output.put_line('Euros: ' || to_char(eur, '999,999,999.999'));
    dbms_output.put_line('Divisar x 1 euro: ' || to_char(cambio, '999,999,999.999'));
    dbms_output.put_line('Euros comisión: ' || to_char(v_comision, '999,999,999.999'));
    dbms_output.put_line('Cantidad divisas: ' || to_char(v_divisas, '999,999,999.999'));
end;

/*Llamamos al programa pasándole la cantidad y el cambio respecto al euro de la divisa queremos cambiar a euros.*/

execute mostrar_cambio_divisas(2500, 1.220);
/*Euros:        2,500.000
Divisar x 1 euro:            1.220
Euros comisión:            5.000
Cantidad divisas:        3,044.000
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--ACTIVIDADES COMPLEMENTARIAS.

/*1. Escribe un procedimiento que reciba dos números y visualice su suma.*/
create or replace procedure suma(
    num1 number,
    num2 number)
as 
    suma number;
begin 
    suma := num1 + num2;

    dbms_output.put_line(num1 || ' + ' || num2 || ' = ' || suma);
end;

execute suma(20, 1250);
/*20 + 1250 = 1270
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*2. Codifica un procedimiento que reciba una cadena y la visualice al revés.*/
create or replace procedure cadena_al_reves(cadena varchar2)
as 
    r_cadena varchar2(50);
begin 
    for i in reverse 1..length(cadena) loop 
        r_cadena := r_cadena || substr(cadena, i, 1);
    end loop;

    dbms_output.put_line(r_cadena);
end;

execute cadena_al_reves('Esta actividad es para recuperar AD.');
/*.DA rarepucer arap se dadivitca atsE
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*3. Reescribe el código de los dos ejercicios anteriores para convertirlos en funciones que retornen los valores
que mostraban los procedimientos.*/
create or replace function sumaFun(num1 number, num2 number)
return number
as
	suma number;
begin
	suma := num1 + num2;
  return (suma);
end;

select sumafun (125.25, 120)
from dual;
/*SUMAFUN(125.25,120)
-------------------
             245,25*/

create or replace function cadena_al_reves_fun(cadena varchar2)
return varchar2
is
	r_cadena varchar2(50);
begin
  	for i in reverse 1..length(cadena)
    loop
		r_cadena := r_cadena || substr(cadena, i, 1);
	end loop;
	return (r_cadena);
end;

select cadena_al_reves_fun ('Probando la función que da la vuelta a la cadena.')
from dual;
/*CADENA_AL_REVES_FUN('PROBANDOLAFUNCIÓNQUEDALAVUELTAALACADENA.')
-------------------------------------------------------------------
.anedac al a atleuv al ad euq nóicnuf al odnaborP*/

----------------------------------------------------------------------------------

/*4. Escribe una función que reciba una fecha y devuelva
el año, en número, correspondiente a esa fecha.*/
create or replace function fecha_dev_anio(fecha date)
return number
as 
    v_anio number(4);
begin 
    v_anio := to_number(to_char(fecha, 'yyyy'));
    return v_anio;
end;

select fecha_dev_anio(sysdate)
from dual;
/*FECHA_DEV_ANIO(SYSDATE)
-----------------------
                   2022*/
select fecha_dev_anio('14/08/1985')
from dual;               
/*FECHA_DEV_ANIO('14/08/1985')
----------------------------
                        1985*/

----------------------------------------------------------------------------------
/*5. Escribe un bloque PL/SQL que haga uso de la función anterior.*/
declare 
    anio number(4);
begin 
    anio := fecha_dev_anio(sysdate);
    dbms_output.put_line('Año: ' || anio || '.');
end;
/*Año: 2022.
Procedimiento PL/SQL terminado correctamente.*/
declare 
    anio number(4);
begin 
    anio := fecha_dev_anio('14/08/1985');
    dbms_output.put_line('Año: ' || anio || '.');
end;
/*Año: 1985.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*6. Desarrolla una función que devuelva el número de años completos que hay entre dos fechas que se pasan
como parámetros.*/
create or replace function entre_fechas(
    fecha1 date, 
    fecha2 date)
return number 
as 
    v_dif_anios number(4);
begin 
    v_dif_anios := abs(trunc(months_between(fecha1, fecha2) / 12));
    return v_dif_anios;
end;

select entre_fechas(sysdate, '14/08/1985')
from dual;
/*ENTRE_FECHAS(SYSDATE,'14/08/1985')
----------------------------------
                                36*/

select entre_fechas('14/08/1985', '26/08/2016')
from dual;
/*ENTRE_FECHAS('14/08/1985','26/08/2016')
---------------------------------------
                                     31*/

----------------------------------------------------------------------------------

/*7. Escribe una función que, haciendo uso de la función anterior, devuelva los trienios que hay entre dos
fechas (un trienio son tres años).*/
create or replace function trienios(
    fecha1 date, 
    fecha2 date)
return number 
as 
    v_trienios number(4);
begin 
    v_trienios := trunc(entre_fechas(fecha1, fecha2) / 3);
    return v_trienios;
end;

select trienios(sysdate, '14/08/1985')
from dual;
/*TRIENIOS(SYSDATE,'14/08/1985')
------------------------------
                            12*/

select trienios('14/08/1985', '26/08/2016')
from dual;
/*TRIENIOS('14/08/1985','26/08/2016')
-----------------------------------
                                 10*/

----------------------------------------------------------------------------------

/*8. Codifica un procedimiento que reciba una lista de hasta cinco números y visualice su suma.*/
create or replace procedure suma(
    num1 number default 0,
    num2 number default 0,
    num3 number default 0, 
    num4 number default 0, 
    num5 number default 0)
as 
    suma number;
begin 
    suma := num1 + num2 + num3 + num4 + num5;

    dbms_output.put_line(num1 || ' + ' || num2 || ' + ' || num3 || ' + ' || num4 || ' + ' || num5 || ' = ' || suma);
end;

execute suma(15, 415, 12.5);
/*15 + 415 + 12,5 + 0 + 0 = 442,5
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*9. Escribe una función que devuelva solamente caracteres alfabéticos sustituyendo cualquier otro carácter
por blancos a partir de una cadena que se pasará en la llamada.*/
create or replace function alfabet(cadena varchar2)
return varchar2
as 
    b_cadena varchar2(50);
begin 
    for i in 1..length(cadena) loop 
        if(ascii(substr(cadena, i, 1)) not between 65 and 90 and ascii(substr(cadena, i, 1)) not between 97 and 122) then 
            b_cadena := b_cadena || ' ';
        else
            b_cadena := b_cadena || substr(cadena, i, 1);
        end if;
    end loop;

    return b_cadena;
end;

select alfabet('Héctor * Beren - Ciro. Jose, Patri.')
from dual;
/*ALFABET('HÉCTOR*BEREN-CIRO.JOSE,PATRI.')
---------------------------------------------
H ctor   Beren   Ciro  Jose  Patri*/

----------------------------------------------------------------------------------

/*10. Codifica un procedimiento que permita borrar un empleado cuyo número se pasará en la llamada.*/
create or replace procedure borra_emple(num_empleado emple.emp_no%type)
as 
begin 
    delete from emple where emp_no = num_empleado;
end;

execute borra_emple(7782);
/*Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*11. Escribe un procedimiento que modifique la localidad de un departamento. El procedimiento recibirá como
parámetros el número del departamento y la nueva localidad.*/
create or replace procedure modificar_loc(
    num_depar depart.dept_no%type,
    nueva_loc depart.loc%type)
as 
begin   
    update depart set loc = nueva_loc
        where dept_no = num_depar;
end;

execute modificar_loc(20, 'MURCIA');
/*Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*12. Visualiza todos los procedimientos y funciones del usuario almacenados en la base de datos y su situación
(valid o invalid).*/
select object_name, object_type, status from user_objects
    where object_type in('PROCEDURE', 'FUNCTION');
/*OBJECT_NAME                                                                                                                    OBJECT_TYPE        STATUS
-------------------------------------------------------------------------------------------------------------------------------- ------------------ -------
ALFABET                                                                                                                          FUNCTION           VALID
BORRAR                                                                                                                           PROCEDURE          VALID
BORRA_EMPLE                                                                                                                      PROCEDURE          VALID
BORRA_EMPLEADO                                                                                                                   PROCEDURE          VALID
CADENA_AL_REVES                                                                                                                  PROCEDURE          VALID
CADENA_AL_REVES_FUN                                                                                                              FUNCTION           VALID
CAMBIAR_DEPART                                                                                                                   PROCEDURE          INVALID
CAMBIAR_DIVISAS                                                                                                                  PROCEDURE          VALID
CAMBIAR_OFICIO                                                                                                                   PROCEDURE          INVALID
CAMBIO                                                                                                                           PROCEDURE          VALID
CONSULTAR_EMPLE                                                                                                                  PROCEDURE          INVALID
CON_IVA                                                                                                                          FUNCTION           VALID
CREAR_DEPART                                                                                                                     PROCEDURE          VALID
DATOS_EMPLE                                                                                                                      PROCEDURE          VALID
EJSQLDIN                                                                                                                         PROCEDURE          VALID
ENTRE_FECHAS                                                                                                                     FUNCTION           VALID
FECHA_DEV_ANIO                                                                                                                   FUNCTION           VALID
FILAS_EMPLE                                                                                                                      PROCEDURE          VALID
LOC_DEPART                                                                                                                       PROCEDURE          VALID
MODIFICAR_LOC                                                                                                                    PROCEDURE          VALID
MODIFICAR_PRECIO_PRODUCTO                                                                                                        PROCEDURE          VALID
MOD_OFICIO                                                                                                                       PROCEDURE          VALID
MOFICAR_LOC                                                                                                                      PROCEDURE          VALID
MOSTRARCAMBIO                                                                                                                    PROCEDURE          VALID
MOSTRAR_CAMBIO_DIVISAS                                                                                                           PROCEDURE          VALID
MOSTRAR_FECHA                                                                                                                    PROCEDURE          VALID
PRECIOTOTAL                                                                                                                      PROCEDURE          INVALID
PRODUCTO                                                                                                                         PROCEDURE          VALID
SIN_VOCALES                                                                                                                      PROCEDURE          VALID
SUMA                                                                                                                             PROCEDURE          VALID
SUMAFUN                                                                                                                          FUNCTION           VALID
TRIENIOS                                                                                                                         FUNCTION           VALID
VER_DEPART                                                                                                                       PROCEDURE          INVALID
VER_PRECIO                                                                                                                       PROCEDURE          VALID
34 filas seleccionadas.*/

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--BOLETÍN 1.- PL/SQL

/*1. Crear un procedimiento que reciba como parámetro un código de empleado y nos muestre por
pantalla el apellido, salario y nombre del departamento donde trabaja, si existe un empleado con
dicho código. En caso contrario, un mensaje de error que indique que el empleado con ese código
no existe. Haz uso de la Excepcion 'NO_DATA_FOUND'.*/
create or replace procedure buscar_emple (cod_emple emple.emp_no%type)
as 
    v_apellido emple.apellido%type;
    v_salario emple.salario%type;
    v_nomdep depart.dnombre%type;
begin 
    select apellido, salario, dnombre into v_apellido, v_salario, v_nomdep from emple, depart 
        where emple.dept_no = depart.dept_no
        and cod_emple = emp_no;
    
    dbms_output.put_line('Encontrado: ' || v_apellido || ' - ' || v_salario || ' - ' || v_nomdep || '.');
exception 
    when no_data_found then 
        dbms_output.put_line('No existe el número de empleado indicado.');
end;

execute buscar_emple(7782);
/*Encontrado: CEREZO - 2885 - CONTABILIDAD.
Procedimiento PL/SQL terminado correctamente.*/

execute buscar_emple(7782);
/*No existe el número de empleado indicado.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*2. Modifica los ejercicios complementarios 10 y 11 para que den un mensaje de error en caso de
que el empleado (ejercicio 10) ó el departamento (ejercicio 11) no existan. Haz uso de la Excepcion
'NO_DATA_FOUND'.*/

    /*10. Codifica un procedimiento que permita borrar un empleado cuyo número se pasará en la llamada.
    create or replace procedure borra_emple(num_empleado emple.emp_no%type)
    as 
    begin 
        delete from emple where emp_no = num_empleado;
    end;

    execute borra_emple(7782);
    Procedimiento PL/SQL terminado correctamente.*/
create or replace procedure borra_emple(num_empleado emple.emp_no%type)
as    
    v_emp_no emple.emp_no%type;
begin 
    select emp_no into v_emp_no from emple 
        where emp_no = num_empleado;

    delete from emple where emp_no = num_empleado;
exception 
    when no_data_found then
        dbms_output.put_line('No existe el número de empleado indicado.');
end;

execute borra_emple(7782);
/*Procedimiento PL/SQL terminado correctamente.*/

execute borra_emple(100);
/*No existe el número de empleado indicado.
Procedimiento PL/SQL terminado correctamente.*/

    /*11. Escribe un procedimiento que modifique la localidad de un departamento. El procedimiento recibirá como
    parámetros el número del departamento y la nueva localidad.
    create or replace procedure modificar_loc(
        num_depar depart.dept_no%type,
        nueva_loc depart.loc%type)
    as 
    begin   
        update depart set loc = nueva_loc
            where dept_no = num_depar;
    end;

    execute modificar_loc(20, 'MURCIA');
    Procedimiento PL/SQL terminado correctamente.*/
create or replace procedure modificar_loc(
        num_depar depart.dept_no%type,
        nueva_loc depart.loc%type)
as 
    v_depart depart.dept_no%type;
begin   
    select dept_no into v_depart from depart 
        where dept_no = num_depar;

    update depart set loc = nueva_loc
        where dept_no = num_depar;
exception 
    when no_data_found then
        dbms_output.put_line('No existe el número de departamento indicado.');
end;

execute modificar_loc(20, 'MURCIA');
/*Procedimiento PL/SQL terminado correctamente.*/

execute modificar_loc(60, 'MURCIA');
/*No existe el número de departamento indicado.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*3. Modifica los ejercicios complementarios 10 y 11 para que den un mensaje de error en caso de
que el empleado (ejercicio 10) ó el departamento (ejercicio 11) no existan. Haz uso del atributo
'SQL%ROWCOUNT'.*/
create or replace procedure borra_emple(num_empleado emple.emp_no%type)
as
begin
	delete from emple where emp_no = num_empleado;

	if sql%rowcount > 0 then
		dbms_output.put_line('Se ha borrado el empleado.');
	else
		dbms_output.put_line('No existe el número de empleado indicado.');
	end if;
end;

execute borra_emple(7782);
/*Se ha borrado el empleado.
Procedimiento PL/SQL terminado correctamente.*/

execute borra_emple(100);
/*No existe el número de empleado indicado.
Procedimiento PL/SQL terminado correctamente.*/

create or replace procedure modificar_loc(
        num_depar depart.dept_no%type,
        nueva_loc depart.loc%type)
as 
begin   
    update depart set loc = nueva_loc
        where dept_no = num_depar;

    if sql%rowcount > 0 then 
       	dbms_output.put_line('Se ha modificado el departamento.');
	else
		dbms_output.put_line('No existe el número de departamento indicado.');
	end if; 
end;

execute modificar_loc(20, 'MURCIA');
/*Se ha modificado el departamento.
Procedimiento PL/SQL terminado correctamente.*/

execute modificar_loc(60, 'MURCIA');
/*No existe el número de departamento indicado.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*4. Modifica el ejercicio propuesto 3 del tema para que muestre mensajes de error diferentes en caso
de que el empleado o el departamento no existan. Haz uso de bloques anidados y de la Excepción
'NO_DATA_FOUND'.*/

    /*Escribe un procedimiento con funcionalidad similar al ejemplo anterior,
    que recibirá un número de empleado y un número de departamento y
    asignará al empleado el departamento indicado en el segundo parámetro.
    create or replace procedure cambiar_depart(
        num_empleado emple.emp_no%type,
        num_depart emple.dept_no%type)
    as 
        v_depart_anterior emple.dept_no%type;
    begin 
        select dept_no into v_depart_anterior from emple 
            where emp_no = num_empleado;
        
        update emple set dept_no = num_depart 
            where emp_no = num_empleado;
        
        dbms_output.put_line(num_empleado || '. Departamento anterior: ' || v_depart_anterior || ' - nuevo departamento: ' || num_depart || '.');
    end;

    execute cambiar_depart(7782, 40);
    7782. Departamento anterior: 10 - nuevo departamento: 40.
    Procedimiento PL/SQL terminado correctamente.*/
create or replace procedure cambiar_depart(
    num_empleado emple.emp_no%type,
    num_depart emple.dept_no%type)
as 
    v_depart_anterior emple.dept_no%type;
    v_emp_anterior emple.emp_no%type;
begin 
    begin 
        select emp_no into v_emp_anterior from emple
			where emp_no = num_empleado;
    exception 
        when no_data_found then
            dbms_output.put_line('No existe el número de empleado indicado.');
    end;

    select dept_no into v_depart_anterior from depart 
        where dept_no = num_depart;

    update emple set dept_no = num_depart 
        where emp_no = num_empleado;

    if sql%rowcount > 0 then 
        dbms_output.put_line(num_empleado || '. Departamento anterior: ' || v_depart_anterior || ' - nuevo departamento: ' || num_depart || '.');
    end if;
exception 
    when no_data_found then
        dbms_output.put_line('No existe el número de departamento indicado.');  
end;

execute cambiar_depart(7782, 40);
/*7782. Departamento anterior: 40 - nuevo departamento: 40.
Procedimiento PL/SQL terminado correctamente.*/

execute cambiar_depart(100, 40);
/*No existe el número de empleado indicado.
Procedimiento PL/SQL terminado correctamente.*/

execute cambiar_depart(7782, 60);
/*No existe el número de departamento indicado.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*5. Realiza un procedimiento que consiga la misma salida que el ejercicio anterior haciendo uso de
un solo bloque y de una variable bandera.*/
create or replace procedure cambiar_depart(
    num_empleado emple.emp_no%type,
    num_depart emple.dept_no%type)
as 
    v_depart_anterior emple.dept_no%type;
    v_emp_anterior emple.emp_no%type;
    v_bandera boolean default false;
begin 
    select emp_no into v_emp_anterior from emple
		where emp_no = num_empleado;

    if sql%rowcount > 0 then 
        v_bandera := true;
    end if;

    select dept_no into v_depart_anterior from depart 
        where dept_no = num_depart;
    
    if sql%rowcount > 0 then 
        v_bandera := true;
    end if;

    update emple set dept_no = num_depart 
        where emp_no = num_empleado;

    dbms_output.put_line(num_empleado || '. Departamento anterior: ' || v_depart_anterior || ' - nuevo departamento: ' || num_depart || '.');
exception 
    when no_data_found then 
        if v_bandera = false then 
            dbms_output.put_line('No existe el número de empleado indicado.'); 
        else 
        dbms_output.put_line('No existe el número de departamento indicado.'); 
        end if;
end;

execute cambiar_depart (7782, 40);
/*7782. Departamento anterior: 40 - nuevo departamento: 40.
Procedimiento PL/SQL terminado correctamente.*/

execute cambiar_depart (100, 40);
/*No existe el número de empleado indicado.
Procedimiento PL/SQL terminado correctamente.*/

execute cambiar_depart (7782, 60);
/*No existe el número de departamento indicado.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*6. Realiza un procedimiento que consiga la misma salida que el ejercicio 4 haciendo uso de dos
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

begin dbms_output.put_line(busca_empleado(10)); 
end;
/*Empleado no reconocido.
-1*/

begin dbms_output.put_line(busca_empleado(7782)); 
end;
/*Empleado: 7782
7782*/

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

begin dbms_output.put_line (buscar_departamento (60));
end;
/*Departamento no reconocido.
-1*/

begin dbms_output.put_line (buscar_departamento (30));
end;
/*Departamento: 30
30*/

create or replace procedure cambiar_depart(
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
end;
	
execute cambiar_depart(7782, 40);
/*Empleado: 7782
Departamento: 40*/

execute cambiar_depart(100, 40);
/*Empleado no reconocido.
Departamento: 40*/

execute cambiar_depart(7782, 60);
/*Empleado: 7782
Departamento no reconocido.*/

execute cambiar_depart(100, 60);
/*Empleado no reconocido.
Departamento no reconocido.*/

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--BOLETÍN 2.- PL/SQL

/*1. Crear una función que dado un producto devuelva el total de unidades vendidas de dicho
producto. En caso de que no tenga ventas devolverá 0. En caso de que el producto no exista,
devolverá -1.*/
create or replace function unidadVendid(producto number)
return number 
as 
    v_unidades number;
begin 
    begin 
        select cod_producto into v_unidades from productos 
            where cod_producto = producto;
        
        select nvl(sum(unidades), 0) into v_unidades from ventas
            where cod_producto = producto;
    exception 
        when no_data_found then 
            return -1;
    end;
return v_unidades;
end;

select unidadVendid(1) from dual;
/*UNIDADVENDID(1)
---------------
              0*/

select unidadVendid(6) from dual;
/*UNIDADVENDID(6)
---------------
             12*/

select unidadVendid(10) from dual;
/*
UNIDADVENDID(10)
----------------
              -1*/

----------------------------------------------------------------------------------

/*2. Crea un procedimiento que haga lo mismo que la función anterior. El procedimiento tendrá un
argumento de entrada (p_producto) y otro de salida (p_total).*/
create or replace procedure unidadVendid(
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
end;

declare 
	p_producto number := 6;
	p_total number default 0;
begin
	unidadVendid(p_producto, p_total);  	
	dbms_output.put_line (p_total);
end;
/*12
Procedimiento PL/SQL terminado correctamente.*/

declare 
	p_producto number := 1;
	p_total number default 0;
begin
	unidadVendid(p_producto, p_total);  	
	dbms_output.put_line (p_total);
end;	
/*0
Procedimiento PL/SQL terminado correctamente.*/

declare 
	p_producto number := 10;
	p_total number default 0;
begin
	unidadVendid(p_producto, p_total);  	
	dbms_output.put_line (p_total);
end;
/*-1
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*4. Crear un procedimiento que reciba un NIF y una fecha y muestre el nombre del cliente al que se
le hizo la venta, la descripción del producto y las unidades vendidas. Dar los mensajes oportunos en
caso de que el cliente no exista o no tenga ventas ese día.*/
create or replace procedure inforVentaCliente(
    p_nif varchar2,
    p_fecha ventas.fecha%type)
as 
    v_nombre clientes.nombre%type;
    v_descrip productos.descripcion%type;
    v_unidades ventas.unidades%type;
    v_bandera number default 0;
begin 
    select nombre into v_nombre from clientes 
        where nif = p_nif;

    v_bandera := 1;

    select nombre, descripcion, unidades into v_nombre, v_descrip, v_unidades from clientes c, productos p, ventas v 
        where c.nif = p_nif
        and v.fecha = p_fecha
        and c.nif = v.nif 
        and v.cod_producto = p.cod_producto;

	dbms_output.put_line(p_fecha || ': ' || v_nombre || ' - ' || v_descrip || ' - ' || v_unidades || '.');
exception 
	when no_data_found then 
		if v_bandera = 0 then 
			dbms_output.put_line('No existe el cliente.');
		else 
			dbms_output.put_line('No hay ventas ese día de dicho producto.');
		end if;
end;

execute inforVentaCliente('111A', '22/09/97');
/*No hay ventas ese día de dicho producto.
Procedimiento PL/SQL terminado correctamente.*/

execute inforVentaCliente('999J', '22/09/97');
/*No existe el cliente.
Procedimiento PL/SQL terminado correctamente.*/

execute inforVentaCliente('111A', '18/10/97');
/*18/10/97: ANDRES - SIMM EDO 16MB - 3.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*4. Crear una función que reciba un NIF y devuelva la cantidad de ventas que dicho cliente ha
realizado. Si el cliente no ha hecho ninguna venta devolverá 0. Si el cliente no existe devolverá -1.*/
create or replace function compraCliente(p_nif clientes.nif%type)
return number
as 
    v_nif clientes.nif%type;
    v_unidades ventas.unidades%type;
begin 
    select nif into v_nif from clientes 
        where nif = p_nif;

    select count(*) into v_unidades from ventas 
        where nif = p_nif;

    return v_unidades;
exception   
    when no_data_found then 
        return -1;
end;

select compraCliente('111A') from dual;
/*COMPRACLIENTE('111A')
---------------------
                    2*/

select compraCliente('999I') from dual;
/*COMPRACLIENTE('999I')
---------------------
                    0*/

select compraCliente('999W') from dual;
/*COMPRACLIENTE('999W')
---------------------
                   -1*/

----------------------------------------------------------------------------------

/*5. Crear una función que reciba un nombre de cliente y devuelva la cantidad de ventas que dicho
cliente ha realizado. Utiliza una llamada a la función anterior. Si el cliente no existe devolverá -1.*/
create or replace function compraCliente2(p_nombre clientes.nombre%type)
return number 
as 
	v_nif clientes.nif%type;
	v_unidades ventas.unidades%type;
begin 
	select nif into v_nif from clientes
		where nombre = p_nombre;
	
	v_unidades := compraCliente(v_nif);
	
	return v_unidades;
exception 
	when no_data_found then 
		return -1;
end;

select compraCliente2('SANDRA') from dual;
/*COMPRACLIENTE2('SANDRA')
------------------------
                       4*/

select compraCliente2('ANTONIO') from dual;
/*COMPRACLIENTE2('ANTONIO')
-------------------------
                        0*/

select compraCliente2('BEREN') from dual;
/*
COMPRACLIENTE2('BEREN')
-----------------------
                     -1*/

----------------------------------------------------------------------------------

--BOLETÍN 3.- PL/SQL

/*1. Crear una función que devuelva la diferencia de precio entre el producto más caro y el más
barato.*/
create or replace function difPrecios
return number
as 
	v_diferencia number;
begin 
	select max(precio_uni) - min(precio_uni) into v_diferencia from productos;
	
	return v_diferencia;
end;
		
select difPrecios from dual;
/*DIFPRECIOS
----------
     42900*/

----------------------------------------------------------------------------------

/*2. Crear un procedimiento que muestre los datos del cliente con domicilio en Las Rozas que
todavía no ha realizado ninguna compra.*/
create or replace procedure domicilio
as 
	v_cliente clientes%rowtype;
begin 
	select * into v_cliente from clientes
		where domicilio like 'LAS ROZAS'
		and not exists (select nif from ventas	
						where clientes.nif = ventas.nif);
						
	dbms_output.put_line(v_cliente.nombre || ' ' || v_cliente.nif || ' ' || v_cliente.domicilio || '.');
end;

execute domicilio;
/*ANTONIO 999I LAS ROZAS.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*3. Crear un procedimiento que dado un producto (cod_producto) inserte una venta de 10 unidades
con fecha de hoy para todos los clientes. Dar un mensaje de error apropiado en caso de que no
exista el producto.*/
create or replace procedure insertarVentas(p_producto number)
as
    v_producto productos.cod_producto%type;
begin
    select cod_producto into v_producto from productos
        where cod_producto = p_producto;
	
	insert into ventas
		select distinct nif, p_producto, sysdate, 10 from clientes;
exception
    when no_data_found then
        dbms_output.put_line('El producto no existe.');
end;
	 
execute insertarVentas(2);
/*NIF        COD_PRODUCTO FECHA      UNIDADES
---------- ------------ -------- ----------
333C                  2 22/09/97          2
888H                  4 22/09/97          1
555E                  6 23/09/97          3
222B                  5 26/09/97          5
111A                  9 28/09/97          3
222B                  4 28/09/97          1
444D                  6 02/10/97          2
555E                  6 02/10/97          1
888H                  2 04/10/97          4
333C                  9 04/10/97          4
222B                  6 05/10/97          2
666F                  7 07/10/97          1
555E                  4 10/10/97          3
222B                  4 16/10/97          2
111A                  3 18/10/97          3
222B                  4 18/10/97          5
444D                  6 22/10/97          2
555E                  6 02/11/97          2
888H                  2 04/11/97          3
333C                  9 04/12/97          3
222B                  2 05/12/97          2
111A                  2 06/04/22         10
222B                  2 06/04/22         10
333C                  2 06/04/22         10
444D                  2 06/04/22         10
555E                  2 06/04/22         10
666F                  2 06/04/22         10
777G                  2 06/04/22         10
888H                  2 06/04/22         10
999I                  2 06/04/22         10
/*Procedimiento PL/SQL terminado correctamente.*/

execute insertarVentas(12);
/*El producto no existe.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*4. Crear un procedimiento que muestre los datos del producto con mayor número de ventas.*/
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
end;

execute maxVentas;
/*Cod: 2. Descrip: PLACA BASE VX. Línea: PB. Precio:  10000. Stock: 0*/

----------------------------------------------------------------------------------

/*5. Crear una función que tenga como argumento el código de un empleado y devuelva la diferencia
entre su salario y el máximo salario de su departamento. La función devolverá -1 si no existe ese
empleado.*/
create or replace function difSalario(num_emp emple.emp_no%type)
return number 
as 
	v_emp_no emple.salario%type;
	v_salario emple.salario%type;
    v_dept_no emple.dept_no%type;
begin 
	select salario, dept_no into v_emp_no, v_dept_no from emple 
		where emp_no = num_emp;
	
	select max(salario) into v_salario from emple 
        where dept_no = v_dept_no;
		
	v_salario := v_salario - v_emp_no;
		
	return v_salario;
exception 
	when no_data_found then 
		return -1;
end;

select * from emple 
    order by dept_no, salario;

/*  EMP_NO APELLIDO   OFICIO            DIR FECHA_AL    SALARIO   COMISION    DEPT_NO
---------- ---------- ---------- ---------- -------- ---------- ---------- ----------
      7934 MUÑOZ      EMPLEADO         7782 23/01/92       1690                    10
      7839 REY        PRESIDENTE            17/11/91       4100                    10
      7369 SANCHEZ    EMPLEADO         7902 17/12/90       1040                    20
      7876 ALONSO     EMPLEADO         7788 23/09/91       1430                    20
      7566 JIMENEZ    DIRECTOR         7839 02/04/91       2900                    20
      7788 GIL        ANALISTA         7566 09/11/91       3000                    20
      7902 FERNANDEZ  ANALISTA         7566 03/12/91       3000                    20
      7900 JIMENO     EMPLEADO         7698 03/12/91       1335                    30
      7844 TOVAR      VENDEDOR         7698 08/09/91       1350          0         30
      7499 ARROYO     VENDEDOR         7698 20/02/90       1500        390         30
      7654 MARTIN     VENDEDOR         7698 29/09/91       1600       1020         30
      7521 SALA       VENDEDOR         7698 22/02/91       1625        650         30
      7698 NEGRO      DIRECTOR         7839 01/05/91       3005                    30
      7782 CEREZO     DIRECTOR         7839 09/06/91       2885                    40*/

select difSalario('7369') from dual;
/*DIFSALARIO('7369')
------------------
              1960*/

select difSalario('7900') from dual;
/*DIFSALARIO('7900')
------------------
              1670*/

select difSalario('1000') from dual;
/*DIFSALARIO('1000')
------------------
                -1*/

----------------------------------------------------------------------------------	

/*6. Crear un procedimiento que reciba un número n y calcule, en una variable de salida, el porcentaje
que suponen estos n empleados respecto al total de empleados de la base de datos.*/
create or replace procedure porcentajeTotal(n number, salida out number)
as 
	v_total_emple number;
begin 
	select count(*) into v_total_emple from emple;

	salida := (n * 100) / v_total_emple;
end;

declare 
	salida number(4,2);
begin 
	porcentajeTotal(8, salida);
	dbms_output.put_line(salida || '%.'	);
end;
/*57,14%.
Procedimiento PL/SQL terminado correctamente.*/

























