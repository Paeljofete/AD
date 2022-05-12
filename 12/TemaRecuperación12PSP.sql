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
            dbms_output.put_line('Departamento: ' || dep_ant || '. Nº. Empleados: ' || cont_emple || '. Suma salarios: ' || sum_sal);

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
Departamento: 10. Nº. Empleados: 3. Suma salarios: 1137500
ALONSO     *      143,000
FERNANDEZ  *      390,000
GIL        *      390,000
JIMENEZ    *      386,750
SANCHEZ    *      104,000
Departamento: 20. Nº. Empleados: 5. Suma salarios: 1413750
ARROYO     *      208,000
JIMENO     *      123,500
MARTIN     *      162,500
NEGRO      *      370,500
SALA       *      162,500
TOVAR      *      195,000
Departamento: 30. Nº. Empleados: 6. Suma salarios: 1222000
TOTAL EMPLEADOS: 14. TOTAL SALARIOS: 3773250.*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 4.
/*Haz los cambios necesarios en el programa anterior para que realice el mismo listado usando una estructura de CURSOR
FOR…LOOP (hay que tener en cuenta el ámbito de las variables de registro del cursor).
Hecho esto, podemos incluir en el programa rupturas por oficio, indicando en este caso únicamente el nombre del
oficio y el número de empleados que tiene. Se entiende que se mantienen las rupturas por departamento y los subtotales;
y dentro de cada departamento se harán, rupturas por oficio.*/
--Variable de acoplamiento.
create or replace procedure listar_emple 
as 
    v_dept emple.dept_no%type;
    v_oficio emple.oficio%type;
    cont_emple number(4) default 0;
    sum_sal number(9,2) default 0;
    tot_emple number(4) default 0;
    tot_sal number(10,2) default 0;
    cont_oficio number(2) default 0;

    cursor c1 is 
        select distinct dept_no from emple;

    cursor c2 is 
        select distinct oficio from emple 
            where dept_no = v_dept;

    cursor c3 is 
        select apellido, salario from emple 
            where dept_no = v_dept 
            and oficio = v_oficio;
begin 
    for v1 in c1 loop 
        v_dept := v1.dept_no;

        for v2 in c2 loop 
            v_oficio := v2.oficio;

            for v3 in c3 loop 
                dbms_output.put_line(rpad(v3.apellido, 10) || ' * ' || lpad(to_char(v3.salario, '999,999'), 12));
                
                cont_emple := cont_emple + 1;
                sum_sal := sum_sal + v3.salario;
                cont_oficio := cont_oficio + 1;
            end loop;

            if cont_oficio > 0 then 
                dbms_output.put_line(chr(9) || 'Oficio: ' || v2.oficio || '. ' || cont_oficio || ' empleados.');
            end if;

            cont_oficio := 0;
        end loop;

        dbms_output.put_line('Departamento: ' || v1.dept_no || '. Nº. Empleados: ' || cont_emple || '. Suma salarios: ' || sum_sal);

        tot_emple := tot_emple + cont_emple;
        tot_sal := tot_sal + sum_sal;
        cont_emple := 0;
        sum_sal := 0;
    end loop;

    dbms_output.put_line(' TOTAL EMPLEADOS: ' || tot_emple || '. TOTAL SALARIOS: ' || tot_sal || '.');
end;

execute listar_emple;
/*
CEREZO     *      318,500
	Oficio: DIRECTOR. 1 empleados.
MUÑOZ      *      169,000
	Oficio: EMPLEADO. 1 empleados.
REY        *      650,000
	Oficio: PRESIDENTE. 1 empleados.
Departamento: 10. Nº. Empleados: 3. Suma salarios: 1137500
GIL        *      390,000
FERNANDEZ  *      390,000
	Oficio: ANALISTA. 2 empleados.
JIMENEZ    *      386,750
	Oficio: DIRECTOR. 1 empleados.
SANCHEZ    *      104,000
ALONSO     *      143,000
	Oficio: EMPLEADO. 2 empleados.
Departamento: 20. Nº. Empleados: 5. Suma salarios: 1413750
NEGRO      *      370,500
	Oficio: DIRECTOR. 1 empleados.
JIMENO     *      123,500
	Oficio: EMPLEADO. 1 empleados.
ARROYO     *      208,000
SALA       *      162,500
MARTIN     *      162,500
TOVAR      *      195,000
	Oficio: VENDEDOR. 4 empleados.
Departamento: 30. Nº. Empleados: 6. Suma salarios: 1222000
TOTAL EMPLEADOS: 14. TOTAL SALARIOS: 3773250.*/

--Cursor con parámetro.
create or replace procedure listar_emple 
as 
    cont_emple number(4) default 0;
    sum_sal number(9,2) default 0;
    tot_emple number(4) default 0;
    tot_sal number(10,2) default 0;
    cont_oficio number(2) default 0;

    cursor c1 is 
        select distinct dept_no from emple;
    
    cursor c2(v_dept emple.dept_no%type) is 
        select distinct oficio from emple 
            where dept_no = v_dept;

    cursor c3(v_dept emple.dept_no%type, v_oficio emple.oficio%type) is 
        select apellido, salario from emple
            where dept_no = v_dept 
            and oficio = v_oficio;
begin   
    for v1 in c1 loop 

        for v2 in c2(v1.dept_no) loop   

            for v3 in c3(v1.dept_no, v2.oficio) loop 
                 dbms_output.put_line(rpad(v3.apellido, 10) || ' * ' || lpad(to_char(v3.salario, '999,999'), 12));
                
                cont_emple := cont_emple + 1;
                sum_sal := sum_sal + v3.salario;
                cont_oficio := cont_oficio + 1;
            end loop;

            if cont_oficio > 0 then 
                dbms_output.put_line(chr(9) || 'Oficio: ' || v2.oficio || '. ' || cont_oficio || ' empleados.');
            end if;

            cont_oficio := 0;
        end loop;

        dbms_output.put_line('Departamento: ' || v1.dept_no || '. Nº. Empleados: ' || cont_emple || '. Suma salarios: ' || sum_sal);

        tot_emple := tot_emple + cont_emple;
        tot_sal := tot_sal + sum_sal;
        cont_emple := 0;
        sum_sal := 0;
    end loop;

    dbms_output.put_line(' TOTAL EMPLEADOS: ' || tot_emple || '. TOTAL SALARIOS: ' || tot_sal || '.');
end;
/*
CEREZO     *      318,500
	Oficio: DIRECTOR. 1 empleados.
MUÑOZ      *      169,000
	Oficio: EMPLEADO. 1 empleados.
REY        *      650,000
	Oficio: PRESIDENTE. 1 empleados.
Departamento: 10. Nº. Empleados: 3. Suma salarios: 1137500
GIL        *      390,000
FERNANDEZ  *      390,000
	Oficio: ANALISTA. 2 empleados.
JIMENEZ    *      386,750
	Oficio: DIRECTOR. 1 empleados.
SANCHEZ    *      104,000
ALONSO     *      143,000
	Oficio: EMPLEADO. 2 empleados.
Departamento: 20. Nº. Empleados: 5. Suma salarios: 1413750
NEGRO      *      370,500
	Oficio: DIRECTOR. 1 empleados.
JIMENO     *      123,500
	Oficio: EMPLEADO. 1 empleados.
ARROYO     *      208,000
SALA       *      162,500
MARTIN     *      162,500
TOVAR      *      195,000
	Oficio: VENDEDOR. 4 empleados.
Departamento: 30. Nº. Empleados: 6. Suma salarios: 1222000
TOTAL EMPLEADOS: 14. TOTAL SALARIOS: 3773250.*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 5.
/*Escribe un programa que incremente el salario de los empleados de un determinado departamento que se pasará 
como primer parámetro. El incremento será una cantidad en euros que se pasará como segundo parámetro
en la llamada. El programa deberá informar del número de filas afectadas por la actualización. Se actualizarán 
los salarios individualmente y usando el ROWID.*/
create or replace procedure incrementa_sueldo(
    dep emple.dept_no%type,
    cantidad number)
as 
    v_contador number default 0;  

    cursor c1 is 
        select emp_no, salario, rowid from emple 
            where dept_no = dep;    

    v_reg c1%rowtype;
begin 
    open c1;
    
    fetch c1 into v_reg;

    while c1%found loop
        v_contador := v_contador + 1;
        
        update emple 
            set salario = salario + cantidad
            where rowid = v_reg.rowid;

        fetch c1 into v_reg;
    end loop;

    dbms_output.put_line('Salario actualizado para ' || v_contador || ' empleados.');
end;
    
execute incrementa_sueldo(20, 50);
/*Salario actualizado para 5 empleados.*/

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

--ACTIVIDAD PROPUESTA 6.
/*Escribe un procedimiento que reciba todos los datos de un nuevo empleado y procese la transacción de alta, gestionando
posibles errores. El procedimiento deberá gestionar en concreto los siguientes puntos:
– no_existe_departamento.
– no_existe_director.
– numero_empleado_duplicado.
– Salario nulo: con RAISE_APPLICATION_ERROR.
– Otros posibles errores de Oracle visualizando código de error y el mensaje de error.*/
create or replace procedure alta_emple(
    p_emp_no emple.emp_no%type,
    p_apellido emple.apellido%type,
    p_oficio emple.oficio%type,
    p_dir emple.dir%type,
    p_fecha emple.fecha_alt%type,
    p_salario emple.salario%type,
    p_comision emple.comision%type,
    p_dept_no emple.dept_no%type)
as 
    no_existe_departamento exception;
    no_existe_director exception;
    numero_empleado_duplicado exception;

    cursor c1 is 
        select dept_no from emple
            where dept_no = p_dept_no;
    
    cursor c2 is 
        select dir from emple 
            where dir = p_dir;
    
    cursor c3 is 
        select emp_no from emple
            where emp_no = p_emp_no;
begin 

    if p_salario is null then
        raise_application_error(-20010, 'Salario nulo.'); 
    else 
        for v1 in c1 loop 
            if c1%rowcount = 0 then 
                raise no_existe_departamento;
            else 
                for v2 in c2 loop 
                    if c2%rowcount = 0 then 
                        raise no_existe_director;
                    else    
                        for v3 in c3 loop 
                            if c3%rowcount <> 0 then 
                                raise numero_empleado_duplicado;
                            else 
                                insert into emple 
                                    values(p_emp_no, p_apellido, p_oficio, p_dir, p_fecha, p_salario, p_comision, p_dept_no);
                                dbms_output.put_line('Nuevo empleado añadido.');
                            end if;
                        end loop;
                    end if;
                end loop;
            end if;
        end loop;
    end if;
exception 
    when no_existe_departamento then 
        dbms_output.put_line('El departamento indicado no existe.');
    when no_existe_director then 
        dbms_output.put_line('El número del director no es correcto.');
    when numero_empleado_duplicado then 
        dbms_output.put_line('El número de empleado ya existe.');
    when others then 
        dbms_output.put_line('Error: ' || sqlcode || sqlerrm);
end;

execute alta_emple(7369, 'TENA', 'ANALISTA', 7902, sysdate, 250000, 50, 10);
/*El número de empleado ya existe.*/
execute alta_emple(8000, 'TENA', 'ANALISTA', 7902, sysdate, null, 50, 20);
/*Error: -20010ORA-20010: Salario nulo.*/

drop procedure alta_emple;

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 7.
/*Crea el programa anterior y la tabla de pruebas TEMP (Col1 VARCHAR2
(40)). Ejecuta el programa introduciendo diversos valores (0, 1, 2, 3,…),
observa y razona su efecto en la tabla.*/
create table temp (
    col1 varchar2(40)
);

create or replace procedure prueba_savepoint(numfilas number)
as 
begin 
    savepoint ninguna;
    insert into temp(col1)
        values('Primera fila.');
    
    savepoint una;
    insert into temp(col1)
        values('Segunda fila.');
    
    savepoint dos;
    if numfilas = 1 then 
        rollback to una;
    elsif numfilas = 2 then 
        rollback to dos;
    else 
        rollback to ninguna;
    end if;

    commit;
exception 
    when others then 
        rollback;
end;

execute prueba_savepoint(0);
/*ninguna fila seleccionada*/
execute prueba_savepoint(1);
/*COL1
----------------------------------------
Primera fila.*/
execute prueba_savepoint(2);
/*COL1
----------------------------------------
Primera fila.
Primera fila.
Segunda fila.*/
execute prueba_savepoint(3);
/*COL1
----------------------------------------
Primera fila.
Primera fila.
Segunda fila.*/
execute prueba_savepoint(4);
/*COL1
----------------------------------------
Primera fila.
Primera fila.
Segunda fila.*/

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------