--TEMA 12.

--CASO PRÁCTICO 1.
/*El siguiente ejemplo ilustra lo que hemos visto hasta ahora respecto a cursores y atributos de cursor: se trata de visualizar los apellidos de 
los empleados pertenecientes al departamento 20 numerándolos secuencialmente.*/
declare 
	cursor c1 is 
	select apellido from emple 
		where dept_no = 20;
		
	v_apellido emple.apellido%type;
begin 
	open c1;
	
	loop 
		fetch c1 into v_apellido;
		dbms_output.put_line(to_char(c1%rowcount, '99.') || v_apellido);
	
		exit when c1%notfound; 
	end loop;
	
	close c1;
end;
/*1.SANCHEZ
2.JIMENEZ
3.GIL
4.ALONSO
5.FERNANDEZ
5.FERNANDEZ
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 1.
/*Escribe el ejercicio anterior subsanando el error de diseño para que no aparezca el último empleado duplicado. Hacerlo
primero manteniendo el bucle LOOP…EXIT WHEN, y posteriormente probar con un bucle WHILE. Observa las diferencias
en ambos casos.*/
declare 
	cursor c1 is 
		select apellido from emple 
			where dept_no = 20;
		
	v_apellido emple.apellido%type;
begin 
	open c1;
	
	loop 
		fetch c1 into v_apellido;
		exit when c1%notfound;
		
		dbms_output.put_line(to_char(c1%rowcount, '99.') || v_apellido);		
	end loop;
	
	close c1;
end;
/*1.SANCHEZ
2.JIMENEZ
3.GIL
4.ALONSO
5.FERNANDEZ*/

declare 
	cursor c1 is 
		select apellido from emple 
			where dept_no = 20;
	
	v_apellido emple.apellido%type;
begin 
	open c1;
	
	fetch c1 into v_apellido;
	while c1%found loop 
		dbms_output.put_line(to_char(c1%rowcount, '99.') || v_apellido);
		fetch c1 into v_apellido;
	end loop;
	
	if c1%rowcount = 0 then 
		dbms_output.put_line('No hay datos.');
	end if;

	close c1;
end;
/*1.SANCHEZ
2.JIMENEZ
3.GIL
4.ALONSO
5.FERNANDEZ*/
----------------------------------------------------------------------------------

--CASO PRÁCTICO 2.
/*En el siguiente ejemplo se visualizan los empleados de un departamento cualquiera usando variables de acoplamiento:*/
create or replace procedure ver_emple_por_dept(dep varchar2)
as 
    v_dept number(2);
    v_apellido varchar2(10);

    cursor c1 is 
        select apellido from emple 
            where dept_no = v_dept;
begin 
    v_dept := dep;

    open c1;

    fetch c1 into v_apellido;

    while c1%found loop 
        dbms_output.put_line(v_apellido);

        fetch c1 into v_apellido;
    end loop;

    close c1;
end;

execute ver_emple_por_dept(30);
/*ARROYO
SALA
MARTIN
NEGRO
TOVAR
JIMENO*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 2.
/*Escribe un procedimiento que reciba una cadena y visualice el apellido y el número de empleado de todos los empleados
cuyo apellido contenga la cadena especificada. Al finalizar, visualiza el número de empleados mostrados. El
procedimiento empleará variables de acoplamiento para la selección de filas y los atributos del cursor estudiados en
el epígrafe anterior.*/
create or replace procedure apell_y_num_emple(cadena varchar2)
as 
	cursor c1 is 
		select apellido, emp_no from emple 
			where apellido like '%' || upper(cadena) || '%';
			
	v_emple c1%rowtype;
    contador number default 0;
begin 	
	open c1;
	
	fetch c1 into v_emple;

	while c1%found loop 
        contador := contador + 1;

		dbms_output.put_line(v_emple.apellido || ' ' || v_emple.emp_no || '.');

		fetch c1 into v_emple;
	end loop;

    if contador = 1 then 
        dbms_output.put_line(contador || ' empleado encontrado.');
    elsif contador = 0 then 
        dbms_output.put_line('No se han encontrado empleados.');
    else    
        dbms_output.put_line(contador || ' empleados encontrados.');
    end if;
	
	close c1;
end;

execute apell_y_num_emple('f');
/*FERNANDEZ 7902.
1 empleado encontrado.*/

execute apell_y_num_emple('a');
/*SANCHEZ 7369.
ARROYO 7499.
SALA 7521.
MARTIN 7654.
TOVAR 7844.
ALONSO 7876.
FERNANDEZ 7902.
7 empleados encontrados.*/

execute apell_y_num_emple('x');
/*No se han encontrado empleados.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 3.
/*Escribiremos un bloque PL/SQL que visualice el apellido y la fecha de alta de todos los empleados ordenados por
fecha de alta.*/
--1. Mediante una estructura cursor FOR…LOOP.
declare 
    cursor c1 is 
        select apellido, fecha_alt from emple 
            order by fecha_alt;
begin 
    for v1 in c1 loop 
        dbms_output.put_line(v1.apellido || ': ' || v1.fecha_alt);
    end loop;
end;
/*ARROYO: 20/02/80
SANCHEZ: 17/12/80
SALA: 22/02/81
JIMENEZ: 02/04/81
NEGRO: 01/05/81
CEREZO: 09/06/81
TOVAR: 08/09/81
ALONSO: 23/09/81
MARTIN: 29/09/81
GIL: 09/11/81
REY: 17/11/81
JIMENO: 03/12/81
FERNANDEZ: 03/12/81
MUÑOZ: 23/01/82*/

--2. Utilizando un bucle WHILE.
declare 
    cursor c1 is 
        select apellido, fecha_alt from emple 
            order by fecha_alt;
        
    v_reg_emp c1%rowtype;
begin 
    open c1;

    fetch c1 into v_reg_emp;

    while c1%found loop 
        dbms_output.put_line(v_reg_emp.apellido || ': ' || v_reg_emp.fecha_alt);

        fetch c1 into v_reg_emp;
    end loop;

    close c1;
end;
/*ARROYO: 20/02/80
SANCHEZ: 17/12/80
SALA: 22/02/81
JIMENEZ: 02/04/81
NEGRO: 01/05/81
CEREZO: 09/06/81
TOVAR: 08/09/81
ALONSO: 23/09/81
MARTIN: 29/09/81
GIL: 09/11/81
REY: 17/11/81
JIMENO: 03/12/81
FERNANDEZ: 03/12/81
MUÑOZ: 23/01/82*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 3.
/*Escribe el procedimiento realizado anteriormente en la actividad 2 pero usando un cursor FOR…LOOP. Observa las
diferencias con la estructura anterior. Debemos tener en cuenta que el cursor estará cerrado al salir del bucle y no
estarán disponibles sus atributos (en concreto %ROWCOUNT).*/
create or replace procedure apell_y_num_emple(cadena varchar2)
as 
	cursor c1 is 
		select apellido, emp_no from emple 
			where apellido like '%' || upper(cadena) || '%';

    contador number default 0;
begin 
    for v1 in c1 loop 
        contador := contador + 1;

        dbms_output.put_line(v1.apellido || ' ' || v1.emp_no || '.');
    end loop;

    if contador = 1 then 
        dbms_output.put_line(contador || ' empleado encontrado.');
    elsif contador = 0 then 
        dbms_output.put_line('No se han encontrado empleados.');
    else    
        dbms_output.put_line(contador || ' empleados encontrados.');
    end if;
end;

execute apell_y_num_emple('f');
/*FERNANDEZ 7902.
1 empleado encontrado.*/

execute apell_y_num_emple('a');
/*SANCHEZ 7369.
ARROYO 7499.
SALA 7521.
MARTIN 7654.
TOVAR 7844.
ALONSO 7876.
FERNANDEZ 7902.
7 empleados encontrados.*/

execute apell_y_num_emple('x');
/*No se han encontrado empleados.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 4.
/*Escribe un programa que muestre, en formato similar a las rupturas de control o secuencia vistas en SQL*Plus los
siguientes datos:
– Para cada empleado: apellido y salario.
– Para cada departamento: número de empleados y suma de los salarios del departamento.
– Al final del listado: número total de empleados y suma de todos los salarios.*/
create or replace procedure listar_emple 
as 
    cursor c1 is 
        select apellido, salario, dept_no from emple 
            order by dept_no, apellido;
        
    vr_emp c1%rowtype;

    dep_ant emple.dept_no%type default 0;
    cont_emple number(4) default 0;
    sum_sal number(9,2) default 0;
    tot_emple number(4) default 0;
    tot_sal number(10,2) default 0;
begin 
    open c1;

    loop 
        fetch c1 into vr_emp;

        /* Si es el primer Fetch inicializamos dep_ant */
        if c1%rowcount = 1 then 
            dep_ant := vr_emp.dept_no;
        end if;
    
        /* Comprobación nuevo departamento (o finalización) y resumen del anterior e inicialización
        de contadores y acumuladores parciales */
        if dep_ant <> vr_emp.dept_no or c1%notfound then 
            dbms_output.put_line('Departamento: ' || dep_ant || 'Nº. Empleados: ' || cont_emple || 'Suma salarios: ' || sum_sal);

            dep_ant := vr_emp.dept_no;
            tot_emple := tot_emple + cont_emple;
            tot_sal := tot_sal + sum_sal;
            cont_emple := 0;
            sum_sal := 0;
        end if;

        exit when c1%notfound;

        /* Escribir Líneas de detalle incrementar y acumular */
        dbms_output.put_line(rpad(vr_emp.apellido, 10) || ' * ' || lpad(to_char(vr_emp.salario, '999,999'), 12));

        cont_emple := cont_emple + 1;
        sum_sal := sum_sal + vr_emp.salario;
    end loop;

    close c1;

    /* Escribir totales informe */
    dbms_output.put_line(' TOTAL EMPLEADOS: ' || tot_emple || '. TOTAL SALARIOS: ' || tot_sal || '.');
end;

execute listar_emple;
/*
CEREZO     *      318,500
MUÑOZ      *      169,000
REY        *      650,000
Departamento: 10Nº. Empleados: 3Suma salarios: 1137500
ALONSO     *      143,000
FERNANDEZ  *      390,000
GIL        *      390,000
JIMENEZ    *      386,750
SANCHEZ    *      104,000
Departamento: 20Nº. Empleados: 5Suma salarios: 1413750
ARROYO     *      208,000
JIMENO     *      123,500
MARTIN     *      162,500
NEGRO      *      370,500
SALA       *      162,500
TOVAR      *      195,000
Departamento: 30Nº. Empleados: 6Suma salarios: 1222000
TOTAL EMPLEADOS: 14. TOTAL SALARIOS: 3773250.*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 4.
/*Haz los cambios necesarios en el programa anterior para que realice el mismo listado usando una estructura de CURSOR
FOR…LOOP (hay que tener en cuenta el ámbito de las variables de registro del cursor).
Hecho esto, podemos incluir en el programa rupturas por oficio, indicando en este caso únicamente el nombre del
oficio y el número de empleados que tiene. Se entiende que se mantienen las rupturas por departamento y los subtotales;
y dentro de cada departamento se harán, rupturas por oficio.*/



----------------------------------------------------------------------------------

--CASO PRÁCTICO 5.
/*El siguiente ejemplo recibe un número de empleado y una cantidad que se incrementará al salario del empleado
correspondiente. Utilizaremos dos excepciones, una definida por el usuario salario_nulo y la otra predefinida
NO_DATA_FOUND.*/
create or replace procedure subir_salario(
    num_empleado integer,
    incremento real)
as 
    salario_actual real;
    salario_nulo exception;
begin
    select salario into salario_actual from emple 
        where emp_no = num_empleado;
    
    if salario_actual is null then 
        raise salario_nulo;
    end if;

    update emple set salario = salario + incremento 
        where emp_no = num_empleado;
exception 
    when no_data_found then 
        dbms_output.put_line(num_empleado || ' no encontrado. ERROR.');
    when salario_nulo then 
        dbms_output.put_line(num_empleado || ' salario nulo. ERROR.');
end;

execute subir_salario(8000, 100);
/*8000 no encontrado. ERROR.*/

update emple set salario = null 
    where emp_no = 7934
execute subir_salario(7934, 100);
/*7934 salario nulo. ERROR.*/

execute subir_salario(7844, 100);
/*Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 6.
/*El siguiente ejemplo ilustra lo estudiado hasta ahora respecto a la gestión de excepciones. Crearemos un bloque donde
se define la excepción err_blancos asociada con un error definido por el programador y la excepción
no_hay_espacio asociándola con el error número -1547 de Oracle.*/
declare 
    cod_err number(6);
    vnif varchar2(10);
    vnom varchar2(15);
    err_blancos exception;
    no_hay_espacio exception;
    pragma exception_init(no_hay_espacio, -1547);
begin 
    select col1, col2 into vnif, vnom from temp2;

    if substr(vnom, 1,1) <= ' ' then 
        raise err_blancos;
    end if;

    update clientes set nombre = vnom where nif = vnif;
exception 
    when err_blancos then 
        insert into temp2(col1) 
            values('ERROR blancos.');
    when no_hay_espacio then 
        insert into temp2(col1) 
            values('ERROR tablespace.');
    when no_data_found then 
        insert into temp2(col1) 
            values('ERROR no había datos.');
    when too_many_rows then 
        insert into temp2(col1) 
            values('ERROR demasiados datos.');
    when others then 
        cod_err := sqlcode;
        insert into temp2(col1) 
            values(cod_err);
end;

----------------------------------------------------------------------------------

--CASO PRÁCTICO 7.
/*El siguiente ejemplo muestra el funcionamiento de RAISE_APPLICATION_ ERROR en un procedimiento de funcionalidad
similar al estudiado en el caso práctico 7 (subir_salario).*/
create or replace procedure subir_sueldo(
    num_emple number, 
    incremento number)
as 
    salario_actual number;
begin 
    select salario into salario_actual from emple 
        where emp_no = num_emple;
    
    if salario_actual is null then 
        raise_application_error(-20010, 'Salario nulo.');
    else 
        update emple set salario = salario_actual + incremento
            where emp_no = num_emple;
    end if;
end;

update emple set salario = null 
    where emp_no = 7934
execute subir_sueldo(7934, 100);
/*ERROR en línea 1:
ORA-20010: Salario nulo.
ORA-06512: en "SCOTT.SUBIR_SUELDO", línea 11
ORA-06512: en línea 1*/

execute subir_salario(7844, 100);
/*Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------