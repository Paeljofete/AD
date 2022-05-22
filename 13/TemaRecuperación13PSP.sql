--TEMA 13.

--ACTIVIDAD PROPUESTA 1.
/*Escribe un disparador que inserte en la tabla auditaremple(col1 (VARCHAR2(200)) cualquier cambio que supere el 5% del salario del
empleado indicando la fecha y hora, el empleado, y el salario anterior y posterior.*/
create table auditaremple(
    col1 varchar2(200)
);

create or replace trigger supere_cinco
    before update of salario on emple for each row 
        when(new.salario > old.salario * 1.05)
begin 
    insert into auditaremple
        values('Fecha: ' || to_char(sysdate, 'dd/mm/yyyy. hh:mm') || '. Empleado: ' || :old.emp_no || ' - ' || :old.apellido
            || '. Salario anterior: ' || :old.salario || '. Salario actualizado: ' || :new.salario || '.');

    dbms_output.put_line('Datos insertados en la tabla.');
end;

update emple set salario = 2000
    where emp_no = 7934;

update emple set salario = 2200
    where emp_no = 7369;
/*Datos insertados en la tabla.*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 1.
/*Supongamos que disponemos de la siguiente vista:*/
create view emplead as 
    select emp_no, apellido, oficio, dnombre, loc from emple, depart
        where emple.dept_no = depart.dept_no;
--Las siguientes operaciones de manipulación sobre los datos de la vista darán como resultado:
insert into emplead 
    values (7999, 'MARTINEZ', 'VENDEDOR', 'CONTABILIDAD', 'SEVILLA');
/*ERROR en línea 1: ORA-01776: no se puede modificar más de una tabla base a través
de una vista.*/
update emplead set dnombre = 'CONTABILIDAD' where apellido = 'SALA';
/*ERROR en línea 1:ORA-01779: no se puede modificar una columna que se corresponde
con una tabla reservada por clave*/
--Para facilitar estas operaciones de manipulación crearemos el siguiente disparador de sustitución:
create or replace trigger t_ges_emplead
    instead of delete or insert or update on emplead for each row 
declare 
    v_dept depart.dept_no%type;
begin 
    if deleting then 
        delete from emple where emp_no = :old.emp_no;
    elsif inserting then 
        select dept_no into v_dept from depart 
            where depart.dnombre = :new.dnombre 
            and loc = :new.loc;
        
        insert into emple(emp_no, apellido, oficio, dept_no)
            values(:new.emp_no, :new.apellido, :new.oficio, v_dept);
    elsif updating('dnombre') then 
        select dept_no into v_dept from depart 
            where dnombre = :new.dnombre;

        update emple set dept_no = v_dept   
            where emp_no = :old.emp_no;
    elsif updating('oficio') then 
        update emple set oficio = :new.oficio
            where emp_no = :old.emp_no;
    else 
        raise_application_error(-20500, 'Error en la actualización');
    end if;
end;

----------------------------------------------------------------------------------

--CASO PRÁCTICO 2.
/*Escribiremos un disparador que controlará las conexiones de los usuarios en la base de datos.
Para ello introducirá en la tabla control_conexiones el nombre de usuario (USER), la fecha y hora en la que se produce
el evento de conexión, y la operación CONEXIÓN que realiza el usuario.*/
create or replace trigger control_conexiones
    after logon on database
begin 
    insert into control_conexiones(usuario, momento, evento)
        values(ora_login_user, systimestamp, ora_sysevent);
end;
--Para que el disparador pueda crearse deberá estar creada la tabla control_conexiones:
create table control_conexiones (
    usuario varchar2(20),
    momento timestamp, 
    evento varchar2(20));
/*Para crear este disparador a nivel ON DATABASE hay que tener el privilegio ADMINISTER DATABASE TRIGGER, de lo contrario
sólo nos permitirá crearlo ON SCHEMA.
Una vez creado el disparador cualquier evento de conexión en el esquema producirá el disparo del trigger y la consiguiente
inserción de la fila en la tabla.*/
create table control_eventos (
    usuario varchar2(20), 
    momento timestamp, 
    evento varchar2(40));

create or replace trigger ctrl_eventos 
    after ddl on database 
begin 
    insert into control_eventos(usuario, momento, evento)
        values(user, systimestamp, ora_sysevent || ' * ' || ora_dict_obj_name);
end;

----------------------------------------------------------------------------------

--CASO PRÁCTICO 3.
/*Escribiremos un bloque PL/SQL que realizará lo siguiente:
    – Declarar un cursor basado en una consulta.
    – Definir un tipo de registro compatible con el cursor.
    – Definir un tipo de VARRAY cuyos elementos son del tipo registro previamente definido.
    – Declarar inicializar y usar una variable de tipo VARRAY cargando el contenido del cursor en los elementos y posteriormente
    mostrando el contenido de estos.*/
declare 
    /* Declaramos un cursor basado en una consulta */
    cursor c1 is 
        select dnombre, count(emp_no) numemple from depart, emple 
            where depart.dept_no = emple.dept_no
            group by depart.dept_no, dnombre;
    
    /* Definimos un tipo compatible con el cursor */
    type tr_depto is record(
        nombredep depart.dnombre%type,
        numemple integer
    );

    /* Definimos un tipo VARRAY basado en el tipo anterior */
    type tv_depto is varray(6) of tr_depto;

    /* Declaramos e inicializamos una variable del tipo VARRAY definido arriba */
    va_departamentos tv_depto := tv_depto(null, null, null, null, null, null);

    /* Declaramos una variable para usarla como índice */
    n integer := 0;
begin 
    /* Cargar valores en la variable */
    for v1 in c1 loop 
        n := c1%rowcount;
        va_departamentos(n) := v1;
    end loop;

    /* Mostrar los datos de la variable */
    for i in 1..n loop 
        dbms_output.put_line('* Dnombre: ' || va_departamentos(i).nombredep || ' * Nº Empleados: ' || va_departamentos(i).numemple);
    end loop;
end;

/* Dnombre: CONTABILIDAD * Nº Empleados: 3
* Dnombre: INVESTIGACION * Nº Empleados: 5
* Dnombre: VENTAS * Nº Empleados: 6*/

----------------------------------------------------------------------------------

--ACTIVIDAD PROPUESTA 3.
/*Reescribe el bloque PL/SQL del caso práctico del epígrafe anterior usando una tabla anidada en lugar de un VARRAY.
Debemos tener presente que no es necesario inicializar a NULL varios elementos, sino inicializar con una lista vacía
y, después, podemos crear nuevos elementos en el bucle de carga usando el método EXTEND.*/
declare 
    /* Declaramos un cursor basado en una consulta */
    cursor c1 is 
        select dnombre, count(emp_no) numemple from depart, emple 
            where depart.dept_no = emple.dept_no
            group by depart.dept_no, dnombre;
    /* Definimos un tipo compatible con el cursor */
    type tr_depto is record(
        nombredep depart.dnombre%type,
        numemple integer
    );

    /* Definimos un tipo tabla anidada basada en el tipo anterior.*/
    type t_depto is table of tr_depto;

    /* Declaramos e inicializamos una variable del tipo de la tabla.*/
    vt_departamentos t_depto := t_depto();

    /* Declaramos una variable para usarla como índice */
    n integer := 0;
begin 
    /* Cargar valores en la variable */
    for v1 in c1 loop  
        n := c1%rowcount;
        vt_departamentos.extend;
        vt_departamentos(n) := v1;
    end loop;

    /* Mostrar los datos de la variable */
    for i in 1..n loop 
        dbms_output.put_line('* Dnombre: ' || vt_departamentos(i).nombredep || ' * Nº Empleados: ' || vt_departamentos(i).numemple);
    end loop;
end;

/* Dnombre: CONTABILIDAD * Nº Empleados: 3
* Dnombre: INVESTIGACION * Nº Empleados: 5
* Dnombre: VENTAS * Nº Empleados: 6*/

----------------------------------------------------------------------------------

--CASO PRÁCTICO 4.
/*A continuación reescribiremos el código del Caso práctico 3 usando una tabla indexada y los atributos disponibles
para recorrer la tabla.*/
declare 
    /* Declaramos un cursor basado en una consulta */
    cursor c1 is 
        select depart.dept_no, dnombre, count(emp_no) numemple from depart, emple 
            where depart.dept_no = emple.emp_no
            group by depart.dept_no, dnombre;
        
    /* Definimos un tipo compatible con el cursor */
    type tr_depto is record(
        nombredep depart.dnombre%type,
        numemple integer
    );

    /* Definimos un tipo TABLA INDEXADA basado en el tipo anterior */
    type ti_depto is table of tr_depto index by binary_integer;

    /* Declaramos la variable del tipo TABLA INDEXADA */
    va_departamentos ti_depto;

    /* Declaramos una variable para usarla como índice */
    n binary_integer := 0;
begin 
    /* Cargar valores. El indice es el NºDpto */
    for v1 in c1 loop 
        va_departamentos(v1.dept_no).nombredep := v1.dnombre;
        va_departamentos(v1.dept_no).numemple := v1.numemple;
    end loop;

    /* Mostrar los datos de la variable */
    n := va_departamentos.first;

    while va_departamentos.exists(n) loop 
        dbms_output.put_line('* Dep Nº: ' || n || ' * Dnombre: ' || va_departamentos(n).nombredep || ' * Nº Empleados: ' || va_departamentos(n).numemple);
    
        n := va_departamentos.next(n);
    end loop;
end;

/* Dep Nº :10 * Dnombre:CONTABILIDAD * NºEmpleados: 3
* Dep Nº :20 * Dnombre:INVESTIGACION * NºEmpleados: 5
* Dep Nº :30 * Dnombre:VENTAS * NºEmpleados: 6*/

----------------------------------------------------------------------------------

--ACTIVIDADES COMPLEMENTARIAS.

/*Escribe un disparador de base de datos que permita auditar las operaciones de inserción o borrado de
datos que se realicen en la tabla EMPLE según las siguientes especificaciones:
    – Se creará desde SQL*Plus la tabla auditaremple con la columna col1 VARCHAR2(200).
    – Cuando se produzca cualquier manipulación, se insertará una fila en dicha tabla que contendrá: fecha y
    hora, número de empleado, apellido y la operación de actualización INSERCIÓN o BORRADO.*/
create table auditaremple(
    col1 varchar2(200)
);

create or replace trigger auditar_emple 
    before insert or delete on emple for each row 
begin 
    if inserting then 
        insert into auditaremple
            values(to_char(sysdate, 'HH24:MI DD/MM/YYYY') || '. ' || :new.emp_no || ' - ' || :new.apellido || '. Inserción.');
    elsif deleting then 
        insert into auditaremple
            values(to_char(sysdate, 'HH24:MI DD/MM/YYYY') || '. ' || :old.emp_no || ' - ' || :old.apellido || '. Borrado.'); 
    end if;
end;

insert into emple (emp_no, apellido, dept_no)
    values(1000, 'CEPEDANO', 10);

delete from emple 
    where emp_no = 1000;

select * from auditaremple;
/*COL1
------------------------------------------------------------------------------------------------------------------------------------------------------
14:03 21/05/2022. 1000 - CEPEDANO. Borrado.
14:02 21/05/2022. 1000 - CEPEDANO. Inserción.*/

----------------------------------------------------------------------------------

/*Escribe un trigger que permita auditar las modificaciones en la tabla EMPLEADOS, insertando los siguientes
datos en la tabla auditaremple: fecha y hora, número de empleado, apellido, la operación de actualización MODIFICACIÓN
y el valor anterior y el valor nuevo de cada columna modificada (sólo en las columnas modificadas).*/
create or replace trigger mofificar_emple
    before update on emple for each row 
declare 
    v_cadena auditaremple.col1%type;
begin   
    v_cadena := to_char(sysdate, 'HH24:MI DD/MM/YYYY') || '. ' || :old.emp_no || '. Modificación. '; 

    if updating('emp_no') then 
        v_cadena := v_cadena || :old.emp_no || ' - ' || :new.emp_no;
    elsif updating('apellido') then 
        v_cadena := v_cadena || :old.apellido || ' - ' || :new.apellido;
    elsif updating('oficio') then 
        v_cadena := v_cadena || :old.oficio || ' - ' || :new.oficio;
    elsif updating('dir') then 
        v_cadena := v_cadena || :old.dir || ' - ' || :new.dir;    
    elsif updating('fecha_alt') then 
        v_cadena := v_cadena || :old.fecha_alt || ' - ' || :new.fecha_alt; 
    elsif updating('salario') then 
        v_cadena := v_cadena || :old.salario || ' - ' || :new.salario; 
    elsif updating('comision') then 
        v_cadena := v_cadena || :old.comision || ' - ' || :new.comision;  
    elsif updating('dept_no') then 
        v_cadena := v_cadena || :old.dept_no || ' - ' || :new.dept_no;      
    end if;

    insert into auditaremple
        values(v_cadena);
end;

update emple set oficio = 'ANALISTA' 
    where emp_no = 7369;

update emple set salario = 2000
    where emp_no = 7654;

select * from auditaremple;
/*COL1
------------------------------------------------------------------------------------------------------------------------------------------------------
14:18 21/05/2022. 7654. Modificación. 1600 - 2000
14:18 21/05/2022. 7369. Modificación. EMPLEADO - ANALISTA*/

----------------------------------------------------------------------------------

/* Suponiendo que disponemos de la vista:*/
create view departam as 
    select depart.dept_no, dnombre, loc, count(emp_no) tot_emple from emple, depart 
        where emple.dept_no(+) = depart.dept_no
        group by depart.dept_no, dnombre, loc;

/*Construye un disparador que permita realizar actualizaciones
en la tabla depart a partir de la vista departam,
de forma similar al ejemplo del trigger t_ges_emplead. Se
contemplarán las siguientes operaciones:
    – Insertar y borrar departamento.
    – Modificar la localidad de un departamento.*/
create or replace trigger t_ges_depart 
    instead of delete or insert or update on departam for each row 
begin 
    if deleting then 
        delete from depart 
            where dept_no = :old.dept_no;
    elsif inserting then 
        insert into depart
            values(:new.dept_no, :new.dnombre, :new.loc, :new.tot_emple);
    elsif updating('loc') then 
        update depart set loc = :new.loc 
            where dept_no = :old.dept_no;
    else    
        raise_application_error(-20500, 'Error en la actualización.');
    end if;
end;

insert into departam 
    values(50, 'DESARROLLO', 'SEVILLA', 10);
select * from depart;
/*   DEPT_NO DNOMBRE        LOC
---------- -------------- --------------
        10 CONTABILIDAD   SEVILLA
        20 INVESTIGACION  MADRID
        30 VENTAS         BARCELONA
        40 PRODUCCION     BILBAO
        50 DESARROLLO     SEVILLA*/

update departam set loc = 'SALAMANCA'
    where dept_no = 50;
select * from depart;
/*   DEPT_NO DNOMBRE        LOC
---------- -------------- --------------
        10 CONTABILIDAD   SEVILLA
        20 INVESTIGACION  MADRID
        30 VENTAS         BARCELONA
        40 PRODUCCION     BILBAO
        50 DESARROLLO     SALAMANCA*/

delete from departam 
    where dept_no = 50;
select * from depart;
/*   DEPT_NO DNOMBRE        LOC
---------- -------------- --------------
        10 CONTABILIDAD   SEVILLA
        20 INVESTIGACION  MADRID
        30 VENTAS         BARCELONA
        40 PRODUCCION     BILBAO*/

----------------------------------------------------------------------------------

/*Escribe un paquete para gestionar los departamentos. Se llamará gest_depart e incluirá, al menos, los
siguientes subprogramas:
    – insertar_nuevo_depart: inserta un departamento nuevo. Recibe el nombre y la localidad del nuevo
    departamento. Creará el nuevo departamento comprobando que el nombre no se duplique y le asignará
    como número de departamento la decena siguiente al último número de departamento utilizado.
    – borrar_depart: borra un departamento. Recibirá dos números de departamento: el primero corresponde
    al departamento que queremos borrar y el segundo, al departamento al que pasarán los empleados del departamento
    que se va a eliminar. El procedimiento se encargará de realizar los cambios oportunos en los
    números de departamento de los empleados correspondientes.
    – modificar_loc_depart: modifica la localidad del departamento. Recibirá el número del departamento
    que se modifica y la nueva localidad, y realizará el cambio solicitado.
    – visualizar_datos_depart: visualizará los datos de un departamento cuyo número se pasará en la llamada.
    Además de los datos relativos al departamento, se visualizará el número de empleados que pertenecen
    actualmente al departamento.
    – visualizar_datos_depart: versión sobrecargada del procedimiento anterior que, en lugar del número del
    departamento, recibirá el nombre del departamento. Realizará una llamada a la función buscar_depart_
    por_nombre que se indica en el apartado siguiente.
    – buscar_depart_por_nombre: función local al paquete. Recibe el nombre de un departamento y
    devuelve el número del mismo.*/
create or replace package gest_depart 
as   
    procedure insertar_nuevo_depart
        (p_dnombre depart.dnombre%type,
        p_loc depart.loc%type);
    
    procedure borrar_depart
        (p_dept_borrar depart.dept_no%type,
        p_dept_guarda depart.dept_no%type);

    procedure modificar_loc_depart
        (p_dept_no depart.dept_no%type,
        p_loc depart.loc%type);
    
    procedure visualizar_datos_depart
        (p_dept_no depart.dept_no%type);

    procedure visualizar_datos_depart
        (p_dnombre depart.dnombre%type);
end;

create or replace package body gest_depart 
as
    function buscar_depart_por_nombre
        (p_dnombre depart.dnombre%type)
        return depart.dept_no%type;
    
    procedure insertar_nuevo_depart(
        p_dnombre depart.dnombre%type,
        p_loc depart.loc%type)
    as 
        nombre_repetido exception;
        v_dnombre depart.dnombre%type;
        v_encontrado number default 0;
        v_dept_no depart.dept_no%type;
        v_vacio exception;
    begin 
        declare          
        begin 
            select dnombre, count(dnombre) into v_dnombre, v_encontrado from depart
                where dnombre = p_dnombre
                group by dnombre;

            if v_encontrado = 1 then 
                raise nombre_repetido;
            end if;
        exception            
            when no_data_found then 
                null;
        end;

        select max(dept_no) into v_dept_no from depart;

        if v_dept_no is null then 
            raise v_vacio;
        end if;

        insert into depart 
            values((trunc(v_dept_no, -1) + 10), p_dnombre, p_loc);
        
        dbms_output.put_line('Departamento incluido.');
    exception            
        when v_vacio then 
            insert into depart 
                values(10, p_dnombre, p_loc);
            dbms_output.put_line('Departamento incluido.');
        when nombre_repetido then 
            dbms_output.put_line('Error. El nombre del departamento ya existe.');
    end;

    procedure borrar_depart(
        p_dept_borrar depart.dept_no%type,
        p_dept_guarda depart.dept_no%type)
    as 
        v_dept_no depart.dept_no%type;
    begin 
        select dept_no into v_dept_no from depart
            where dept_no = p_dept_borrar;

        select dept_no into v_dept_no from depart
            where dept_no = p_dept_guarda;

        update emple set dept_no = p_dept_guarda
            where dept_no = p_dept_borrar;

        delete from depart 
            where dept_no = p_dept_borrar;

        dbms_output.put_line('Empleados cambiados al departamento ' || p_dept_guarda || '. Borrado el departamento ' || p_dept_borrar || '.');
    exception
        when no_data_found then 
            dbms_output.put_line('Error. No existe el departamento.');
    end;

    procedure modificar_loc_depart(
        p_dept_no depart.dept_no%type,
        p_loc depart.loc%type)
    as 
        v_dept_no depart.dept_no%type;
    begin 
        select dept_no into v_dept_no from depart
            where dept_no = p_dept_no;

        update depart set loc = p_loc 
            where dept_no = p_dept_no;
        
        dbms_output.put_line('Departamento cambiado de localidad.');
    exception 
        when no_data_found then 
            dbms_output.put_line('Error. El departamento no existe.');
    end;

    procedure visualizar_datos_depart
        (p_dept_no depart.dept_no%type)
    as 
        v_dept depart%rowtype;
        v_emp_no emple.emp_no%type;
    begin 
        select * into v_dept from depart 
            where dept_no = p_dept_no;
        
        select count(*) into v_emp_no from emple 
            where dept_no = p_dept_no;
        
        dbms_output.put_line('Departamento: ' || v_dept.dept_no || ' - ' || v_dept.dnombre || ' - ' || v_dept.loc || '. Número empleados: ' || v_emp_no || '.');
    exception 
        when no_data_found then 
            dbms_output.put_line('Error. El departamento no existe.');
    end;

    procedure visualizar_datos_depart
        (p_dnombre depart.dnombre%type)
    as 
        v_dept depart%rowtype;
        v_emp_no emple.emp_no%type;
        v_dept_no depart.dept_no%type;
        no_existe exception;
    begin 
        v_dept_no := buscar_depart_por_nombre(p_dnombre);

        select * into v_dept from depart 
            where dept_no = v_dept_no;
        
        select count(*) into v_emp_no from emple 
            where dept_no = v_dept_no;
        
        dbms_output.put_line('Departamento: ' || v_dept.dept_no || ' - ' || v_dept.dnombre || ' - ' || v_dept.loc || '. Número empleados: ' || v_emp_no || '.');
    end; 

    function buscar_depart_por_nombre
        (p_dnombre depart.dnombre%type)
        return depart.dept_no%type
    as 
        v_dept_no depart.dept_no%type;
    begin 
        select dept_no into v_dept_no from depart 
            where dnombre = p_dnombre;
        return v_dept_no;
    end;
end;

execute gest_depart.insertar_nuevo_depart('CONTABILIDAD', 'MURCIA');
/*Error. El nombre del departamento ya existe.*/
execute gest_depart.insertar_nuevo_depart('DESARROLLO', 'MURCIA');
/*Departamento incluido.*/

execute gest_depart.borrar_depart(10, 40);
/*Empleados cambiados al departamento 40. Borrado el departamento 10.*/
execute gest_depart.borrar_depart(40, 10);
/*Error. No existe el departamento.*/
execute gest_depart.borrar_depart(50, 20);
/*Error. No existe el departamento.*/

execute gest_depart.modificar_loc_depart(10, 'MURCIA');
/*Departamento cambiado de localidad.*/
execute gest_depart.modificar_loc_depart(50, 'MURCIA');
/*Error. El departamento no existe.*/

execute gest_depart.visualizar_datos_depart(10);
/*Departamento: 10 - CONTABILIDAD - SEVILLA. Número empleados: 3.*/
execute gest_depart.visualizar_datos_depart(50);
/*Error. El departamento no existe.*/

execute gest_depart.visualizar_datos_depart('CONTABILIDAD');
/*Departamento: 10 - CONTABILIDAD - SEVILLA. Número empleados: 3.*/

----------------------------------------------------------------------------------

/*Escribir un paquete completo para gestionar los empleados.

El paquete se llamará gest_emple e incluirá, al menos los siguientes subprogramas:

    -insertar_nuevo_emple
    -borrar_emple: Cuando se borra un empleado todos los empleados que
    dependían de él pasarán a depender del director del empleado borrado.
    -modificar_oficio_emple
    -modificar_dept_emple
    -modificar_dir_emple
    -modificar_salario_emple
    -modificar_comision_emple
    -visualizar_datos_emple: También se incluirá una versión sobrecargada del
    procedimiento que recibirá el apellido del empleado.
    -buscar_emple_por_apellido. Función local que recibe el apellido y devuelve
    el número.

Todos los procedimientos recibirán el número del empleado seguido de los demás
datos necesarios.
También se incluirá en el paquete un cursor, que será utilizado en los
siguientes procedimientos que afectarán a todos los empleados:

    -subida_salario_pct: incrementará el salario de todos los empleados el
    porcentaje indicado en la llamada que no podrá ser superior al 25%.
    -subida_salario_imp: sumará al salario de todos los empleados el importe
    indicado en la llamada. Antes de proceder a incrementar los salarios se
    comprobará que el importe indicado no supera el 25% del salario medio.*/
