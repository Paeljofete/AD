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
