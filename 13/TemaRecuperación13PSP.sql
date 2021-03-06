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
create or replace package gest_emple 
as   
    function buscar_emple_por_apellido
        (p_apellido emple.apellido%type)
        return emple.emp_no%type;

    procedure insertar_nuevo_emple
        (p_emp_no emple.emp_no%type,
        p_apellido emple.apellido%type,
        p_oficio emple.oficio%type,
        p_fecha emple.fecha_alt%type,
        p_salario emple.salario%type,
        p_comision emple.comision%type,
        p_dept_no depart.dept_no%type);

    procedure borrar_emple
        (p_emple_borrar emple.emp_no%type);

    procedure modificar_oficio_emple
        (p_oficio emple.oficio%type,
        p_emp_no emple.emp_no%type);
    
    procedure modificar_dept_emple
        (p_dept_no depart.dept_no%type,
        p_emp_no emple.emp_no%type);

    procedure modificar_dir_emple   
        (p_dir emple.dir%type,
        p_emp_no emple.emp_no%type);

    procedure modificar_salario_emple
        (p_salario emple.salario%type,
        p_emp_no emple.emp_no%type);
    
    procedure modificar_comision_emple
        (p_comision emple.comision%type,
        p_emp_no emple.emp_no%type);

    procedure visualizar_datos_emple
        (p_emp_no emple.emp_no%type);

    procedure visualizar_datos_emple
        (p_apellido emple.apellido%type);
    
    procedure subida_salario_pct
        (p_porcentaje number);
    
    procedure subida_salario_imp
        (p_importe number);
end;

create or replace package body gest_emple 
as
    cursor c1 is 
        select emp_no from emple;
        
    procedure insertar_nuevo_emple
        (p_emp_no emple.emp_no%type,
        p_apellido emple.apellido%type,
        p_oficio emple.oficio%type,
        p_fecha emple.fecha_alt%type,
        p_salario emple.salario%type,
        p_comision emple.comision%type,
        p_dept_no depart.dept_no%type)
    as 
        v_dept_no depart.dept_no%type;
        v_contador number default 0;
        v_dir emple.dir%type;
        v_oficio emple.oficio%type;
        no_existe exception;
    begin   
        select count(dept_no) into v_contador from depart
            where dept_no = p_dept_no;

        if v_contador = 0 then 
            raise no_existe;
        end if;  

        select dir, depart.dept_no, oficio into v_dir, v_dept_no, v_oficio from emple, depart
            where depart.dept_no = v_dept_no
            and emple.dept_no = depart.dept_no
            and oficio = 'DIRECTOR'
            group by dir, depart.dept_no, oficio;    

        insert into emple 
            values(p_emp_no, p_apellido, p_oficio, v_dir, p_fecha, p_salario, p_comision, v_dept_no);   
        dbms_output.put_line('Empleado/a incluido/a.');
    exception  
        when  no_data_found then 
            insert into emple 
                values(p_emp_no, p_apellido, 'DIRECTOR', p_emp_no, p_fecha, p_salario, p_comision, p_dept_no);
            dbms_output.put_line('Empleado/a incluido/a.');
        when no_existe then 
            dbms_output.put_line('Error. El departamento no existe.');
    end;

    procedure borrar_emple
        (p_emple_borrar emple.emp_no%type)
    as 
        v_emp_no emple.emp_no%type;
        v_dir emple.dir%type;

        cursor c1 is 
            select emp_no from emple 
                where dir = p_emple_borrar;
    begin   
        select dir into v_dir from emple 
            where emp_no = p_emple_borrar;

        for v1 in c1 loop 
            update emple set dir = v_dir 
                where emp_no = v1.emp_no;
        end loop;

        delete from emple   
            where emp_no = p_emple_borrar;

        dbms_output.put_line('Borrado ralizado.');
    exception
        when no_data_found then 
            dbms_output.put_line('Error. No existe el empleado.');
    end; 

    procedure modificar_oficio_emple
        (p_oficio emple.oficio%type,
        p_emp_no emple.emp_no%type)
    as 
        no_existe exception;
        v_emp_no emple.emp_no%type;
        v_oficio emple.oficio%type;
    begin 
        select emp_no into v_emp_no from emple
            where emp_no = p_emp_no;
            
        select distinct oficio into v_oficio from emple 
            where oficio = p_oficio;

        update emple set oficio = p_oficio 
            where emp_no = p_emp_no; 
        dbms_output.put_line('Cambio de oficio realizado.');
    exception 
        when no_data_found then 
            dbms_output.put_line('Error. No se encuentra el dato.');      
    end;

    procedure modificar_dept_emple
        (p_dept_no depart.dept_no%type,
        p_emp_no emple.emp_no%type)
    as 
        v_dept_no depart.dept_no%type;
        v_emp_no emple.emp_no%type;
    begin 
        select dept_no into v_dept_no from depart 
            where dept_no = p_dept_no;

        select emp_no into v_emp_no from emple 
            where emp_no = p_emp_no;

        update emple set dept_no = p_dept_no 
            where emp_no = p_emp_no;
        dbms_output.put_line('Cambio de departamento realizado.');
    exception 
        when no_data_found then   
            dbms_output.put_line('Error. No se encuentra el dato.'); 
    end;

    procedure modificar_dir_emple   
        (p_dir emple.dir%type,
        p_emp_no emple.emp_no%type)
    as 
        v_dir emple.dir%type;
        v_emp_no emple.emp_no%type;
    begin 
        select dir into v_dir from emple 
            where dir = p_dir;

        select emp_no into v_emp_no from emple 
            where emp_no = p_emp_no;

        update emple set dir = p_dir 
            where emp_no = p_emp_no;
        dbms_output.put_line('Cambio de director realizado.');
    exception 
        when no_data_found then   
            dbms_output.put_line('Error. No se encuentra el dato.'); 
    end;

    procedure modificar_salario_emple
        (p_salario emple.salario%type,
        p_emp_no emple.emp_no%type)
    as 
        v_emp_no emple.emp_no%type;
    begin
        select emp_no into v_emp_no from emple 
            where emp_no = p_emp_no;

        update emple set salario = p_salario 
            where emp_no = p_emp_no;
        dbms_output.put_line('Cambio de salario realizado.');
    exception 
        when no_data_found then   
            dbms_output.put_line('Error. No se encuentra el empleado.'); 
    end;

    procedure modificar_comision_emple
        (p_comision emple.comision%type,
        p_emp_no emple.emp_no%type)
    as 
        v_emp_no emple.emp_no%type;
    begin
        select emp_no into v_emp_no from emple 
            where emp_no = p_emp_no;

        update emple set comision = p_comision
            where emp_no = p_emp_no;
        dbms_output.put_line('Cambio de comisión realizado.');
    exception 
        when no_data_found then   
            dbms_output.put_line('Error. No se encuentra el empleado.'); 
    end;

    procedure visualizar_datos_emple
        (p_emp_no emple.emp_no%type)
    as 
        v_emple emple%rowtype;
    begin 
        select * into v_emple from emple 
            where emp_no = p_emp_no;
        
        dbms_output.put_line('Empleada/o: ' || v_emple.emp_no || ' - ' || v_emple.apellido || ' - ' || v_emple.oficio || '.');
        dbms_output.put_line(chr(9) || 'Director/a: ' || v_emple.dir || '.' || chr(10) || chr(9) || 'Departamento: ' || v_emple.dept_no || '.' || chr(10) || chr(9) || 'Fecha alta: ' || v_emple.fecha_alt || '.'
            || chr(10) || chr(9) || 'Salario: ' || v_emple.salario || '.' || chr(10) || chr(9) || 'Comisión: ' || v_emple.comision || '.');
    exception   
        when no_data_found then 
            dbms_output.put_line('Error. Empleada/o no registrada/o.');
    end;

    procedure visualizar_datos_emple
        (p_apellido emple.apellido%type)
    as 
        v_emple emple%rowtype;
        v_emp_no emple.emp_no%type;
    begin 
        select emp_no into v_emp_no from emple 
            where apellido = p_apellido;

        select * into v_emple from emple 
            where emp_no = v_emp_no;
        
        dbms_output.put_line('Empleada/o: ' || v_emple.emp_no || ' - ' || v_emple.apellido || ' - ' || v_emple.oficio || '.');
        dbms_output.put_line(chr(9) || 'Director/a: ' || v_emple.dir || '.' || chr(10) || chr(9) || 'Departamento: ' || v_emple.dept_no || '.' || chr(10) || chr(9) || 'Fecha alta: ' || v_emple.fecha_alt || '.'
            || chr(10) || chr(9) || 'Salario: ' || v_emple.salario || '.' || chr(10) || chr(9) || 'Comisión: ' || v_emple.comision || '.');
    exception   
        when no_data_found then 
            dbms_output.put_line('Error. Empleada/o no registrada/o.');
    end;

    function buscar_emple_por_apellido
        (p_apellido emple.apellido%type)
        return emple.emp_no%type
    as 
        v_emp_no emple.emp_no%type;
    begin 
        select emp_no into v_emp_no from emple 
            where apellido = p_apellido;
        return v_emp_no;
    end;

    procedure subida_salario_pct
        (p_porcentaje number)
    as 
        mayor_porcentaje exception;
    begin 
        for v1 in c1 loop 
            if p_porcentaje <= 25 then 
                update emple set salario = salario + ((salario * p_porcentaje) / 100) 
                    where emp_no = v1.emp_no;
            else    
                raise mayor_porcentaje;
            end if;
        end loop;

        dbms_output.put_line('Sueldo actualizado.');
    exception
        when mayor_porcentaje then 
            dbms_output.put_line('El porcentaje de subida no puede ser superior al 25%.');
    end;

    procedure subida_salario_imp
        (p_importe number)
    as 
        v_media_salario number (9,2);
        mayor_porcentaje exception;
    begin 
        select avg(salario) into v_media_salario from emple;

        v_media_salario := (v_media_salario * 25) /100;

        for v1 in c1 loop 
            if p_importe <= v_media_salario then 
                update emple set salario = salario + p_importe
                    where emp_no = v1.emp_no; 
            else
                raise mayor_porcentaje;
            end if;
        end loop;

        dbms_output.put_line('Sueldo actualizado.');
    exception
        when mayor_porcentaje then 
            dbms_output.put_line('El porcentaje de subida no puede ser superior a ' || v_media_salario || '.');
    end; 
end;

execute gest_emple.insertar_nuevo_emple(1000, 'TENA', 'EMPLEADO', sysdate, 2500, 50, 10);
/*Empleado/a incluido/a.*/
rollback;
execute gest_emple.insertar_nuevo_emple(1000, 'TENA', 'EMPLEADO', sysdate, 2500, 50, 50);
/*Error. El departamento no existe.*/
rollback;
execute gest_emple.insertar_nuevo_emple(1000, 'TENA', 'EMPLEADO', sysdate, 2500, 50, 40);
/*Empleado/a incluido/a.*/

execute gest_emple.borrar_emple(7369);
/*Borrado ralizado.*/
rollback;
execute gest_emple.borrar_emple(7698);
/*Borrado ralizado.*/
rollback;

execute gest_emple.modificar_oficio_emple('DIRECTOR', 7369);
/*Cambio de oficio realizado.*/
rollback;
execute gest_emple.modificar_oficio_emple('DEV', 7369);
/*Error. No se encuentra el dato.*/
execute gest_emple.modificar_oficio_emple('DIRECTOR', 1000);
/*Error. No se encuentra el dato.*/

execute gest_emple.modificar_dept_emple(40, 7369);
/*Cambio de departamento realizado.*/
rollback;
execute gest_emple.modificar_dept_emple(50, 7369);
/*Error. No se encuentra el dato.*/
execute gest_emple.modificar_dept_emple(40, 1000);
/*Error. No se encuentra el dato.*/

execute gest_emple.modificar_dir_emple(7782, 7369);
/*Cambio de director realizado.*/
rollback;
execute gest_emple.modificar_dir_emple(7369, 7499);
/*Error. No se encuentra el dato.*/
execute gest_emple.modificar_dir_emple(7782, 1000);
/*Error. No se encuentra el dato.*/
execute gest_emple.modificar_dir_emple(1000, 7369);
/*Error. No se encuentra el dato.*/

execute gest_emple.modificar_salario_emple(2500, 7369);
/*Cambio de salario realizado.*/
rollback;
execute gest_emple.modificar_salario_emple(2500, 1000);
/*Error. No se encuentra el empleado.*/

execute gest_emple.modificar_comision_emple(250, 7369);
/*Cambio de comisión realizado.*/
rollback;
execute gest_emple.modificar_comision_emple(250, 1000);
/*Error. No se encuentra el empleado.*/

execute gest_emple.visualizar_datos_emple(7654);
/*Empleada/o: 7654 - MARTIN - VENDEDOR.
	Director/a: 7698.
	Departamento: 30.
	Fecha alta: 29/09/91.
	Salario: 1600.
	Comisión: 1020.*/
execute gest_emple.visualizar_datos_emple(1000);
/*Error. Empleada/o no registrada/o.*/

execute gest_emple.visualizar_datos_emple('FERNANDEZ');
/*Empleada/o: 7902 - FERNANDEZ - ANALISTA.
	Director/a: 7566.
	Departamento: 20.
	Fecha alta: 03/12/91.
	Salario: 3000.
	Comisión: .*/
execute gest_emple.visualizar_datos_emple('TENA');
/*Error. Empleada/o no registrada/o.*/

select gest_emple.buscar_emple_por_apellido('FERNANDEZ') from dual;
/*GEST_EMPLE.BUSCAR_EMPLE_POR_APELLIDO('FERNANDEZ')
-------------------------------------------------
                                             7902*/

execute gest_emple.subida_salario_pct(25);
/*Sueldo actualizado.*/
execute gest_emple.subida_salario_pct(28);
/*El porcentaje de subida no puede ser superior al 25%.*/

execute gest_emple.subida_salario_imp(250);
/*Sueldo actualizado.*/
execute gest_emple.subida_salario_imp(544);
/*El porcentaje de subida no puede ser superior a 543,93.*/

----------------------------------------------------------------------------------

-- BOLETÍN 4.

/*1.- Crear un trigger que simule un borrado en cascada, de modo que al
borrar un departamento, borre todos los empleados de ese
departamento.*/
create or replace trigger borraDepart 
    before delete on depart for each row 
begin 
    delete from emple 
        where emple.dept_no = :old.dept_no;
    
    dbms_output.put_line('Se ha borrado el departamento ' || :old.dept_no || ' y los empleados asociados al mismo.');
end;

delete depart 
    where dept_no = 10;
/*Se ha borrado el departamento 10 y los empleados asociados al mismo.*/

----------------------------------------------------------------------------------

/*2.- Crear un trigger que simule una modificación en cascada, de modo
que al modificar un departamento, actualice su valor para todos sus
empleados.*/
create or replace trigger modificaDepart 
    before update of dept_no on depart for each row 
begin 
    update emple set dept_no = :new.dept_no 
        where dept_no = :old.dept_no;
    
    dbms_output.put_line('Se ha modificado el número del departamento ' || :old.dept_no || ' que ahora es: ' 
        || :new.dept_no || '. A los empleados también se les ha actualizado el departamento.');
end;

update depart set dept_no = 50 
    where dept_no = 10;
/*Se ha modificado el número del departamento 10 que ahora es: 50. A los empleados también se les ha actualizado el departamento.*/

----------------------------------------------------------------------------------

/*3.- Crear un trigger que impida que un empleado pertenezca a un
departamento inexistente.*/
create or replace trigger departInex 
    before update of dept_no or insert on emple for each row 
declare 
    v_comprueba depart.dept_no%type;
begin 
    select dept_no into v_comprueba from depart 
        where dept_no = :new.dept_no;
exception 
    when no_data_found then 
        raise_application_error(-20500, 'Error. No existe el departamento.');
end;

update emple set dept_no = 50
    where dept_no = 10;
/*ORA-20500: Error. No existe el departamento.*/

update emple set dept_no = 20 
    where dept_no = 10;
/*1 fila actualizada.*/

----------------------------------------------------------------------------------

/*4.- Crear un trigger para impedir que se aumente el salario de un
empleado en más de un 20%.*/
create or replace trigger salario20 
    before update of salario on emple for each row 
begin 
    if :new.salario > :old.salario * 1.2 then 
        raise_application_error(-20000, 'Error. No es posible aumentar el salario más del 20%.');
    end if;
end;

update emple set salario = 1250
    where emp_no = 7369;
/*ORA-20000: Error. No es posible aumentar el salario más del 20%.*/
update emple set salario = 1100
    where emp_no = 7369;
/*1 fila actualizada.*/

----------------------------------------------------------------------------------

/*5.- Escribir un disparador de base de datos que haga fallar cualquier
operación de modificación del apellido o del número de un empleado, o
que suponga una subida de sueldo superior al 20%.*/
create or replace trigger modificaEmple 
    before update of apellido, emp_no, salario on emple for each row 
begin 
    if updating('APELLIDO') then 
        raise_application_error(-20000, 'Error. No es posible cambiar el apellido.');
    elsif updating('EMP_NO') then 
        raise_application_error(-20000, 'Error. No es posible cambiar el número de empleada/o.');
    elsif :new.salario > :old.salario * 1.2 then 
        raise_application_error(-20000, 'Error. No es posible aumentar el salario más del 20%.');
    end if;
end; 

update emple set apellido = 'TENA'
    where emp_no = 7369;
/*ORA-20000: Error. No es posible cambiar el apellido.*/
update emple set emp_no = 1000 
    where emp_no = 7369;
/*ORA-20000: Error. No es posible cambiar el número de empleada/o.*/
update emple set salario = 1250
    where emp_no = 7369;
/*ORA-20000: Error. No es posible aumentar el salario más del 20%.*/

----------------------------------------------------------------------------------

/*6.- Crear un trigger que garantice que la comisión de los nuevos
empleados sea del 1% de su salario.*/
create or replace trigger comision1 
    before insert on emple for each row 
begin 
    if :new.comision < :new.salario * 0.01 then 
        :new.comision := :new.salario * 0.01;

        dbms_output.put_line('Se va a actualizar la comisión para que sea el 1% del salario.');
    else 
        :new.comision := :new.comision;

        dbms_output.put_line('Empleada/o insertada/o');
    end if;
end;

insert into emple 
    values(1000, 'TENA', 'ANALISTA', 7839, sysdate, 2000, 10, 20);
/*Se va a actualizar la comisión  para que sea el 1% del salario.*/
select * from emple      
/*1000 TENA       ANALISTA         7839 28/05/22       2000         20         20*/
rollback;
insert into emple 
    values(1000, 'TENA', 'ANALISTA', 7839, sysdate, 2000, 30, 20);
/*Empleada/o insertada/o*/
select * from emple
/*1000 TENA       ANALISTA         7839 28/05/22       2000         30         20*/

----------------------------------------------------------------------------------

/*7.- Dadas las tablas Centros, Personal y Profesores, crear un trigger
que al insertar o borrar un profesor en la tabla Personal mantenga
actualizada la tabla Profesores.*/
create or replace trigger actualizadaProfesores
    before insert or delete on personal for each row
begin 
    if inserting then 
        if :new.funcion = 'PROFESOR' then 
            insert into profesores 
                values(:new.cod_centro, :new.dni, :new.apellidos, null);
            dbms_output.put_line('Se ha añadido en la tabla profesores también.');
        end if;
    elsif deleting then 
        if :old.funcion = 'PROFESOR' then 
            delete from profesores where dni = :old.dni;
            dbms_output.put_line('Se ha eliminado de la tabla profesores.');
        end if;
    end if;
end;

insert into personal 
    values(22, 2456897, 'Fernández Tena, Jose', 'PROFESOR', 200000);
/*Se ha añadido en la tabla profesores también.*/
rollback;
insert into personal 
    values(22, 2456897, 'Fernández Tena, Jose', 'ADMINISTRATIVO', 200000);
/*1 fila creada.*/
rollback;
delete personal 
    where dni = 1112345;
/*Se ha eliminado de la tabla profesores.*/    
delete personal 
    where dni = 4480099;
/*1 fila borrada.

----------------------------------------------------------------------------------

/*8.- Diseñar un trigger que mantenga actualizado el contenido de la
tabla estadísticas.
LIBROS(isbn,genero,titulo,autor);
ESTADISTICAS(genero,total_libros)*/
create table libros1
(
    isbn number(4),
    genero varchar2(20),
    titulo varchar2(30),
    autor varchar2(20)
);

create table estadisticas 
(
    genero varchar2(20),
    total_libros number(5)
);

create or replace trigger actualizaEstadisticas 
    after insert or update of genero or delete on libros1 for each row 
begin 
    if inserting then 
        update estadisticas set total_libros = total_libros + 1 
            where genero = :new.genero;
        dbms_output.put_line('Se ha añadido también en la tabla estadísticas.');
    elsif updating('GENERO') then 
        update estadisticas set total_libros = total_libros + 1 
            where genero = :new.genero;
        update estadisticas set total_libros = total_libros - 1 
            where genero = :old.genero;
        dbms_output.put_line('Se ha modificado también en la tabla estadísticas.');
    elsif deleting then 
        update estadisticas set total_libros = total_libros - 1 
            where genero = :old.genero;
        dbms_output.put_line('Se ha borrado también en la tabla estadísticas.');
    end if;
end;
        
insert into libros1
    values(1234, 'Aventuras', 'El Señor de los Anillos', 'JRR Tolkien');
/*Se ha añadido también en la tabla estadísticas.*/
update libros1 set genero = 'Fantasía'
    where isbn = 1234;
/*Se ha modificado también en la tabla estadísticas.*/
delete from libros1
    where isbn = 1234;
/*Se ha borrado también en la tabla estadísticas.*/

----------------------------------------------------------------------------------

-- BOLETÍN 5.

/*1.- Crear un trigger para impedir que ningún departamento tenga más de 7
empleados.*/
create or replace trigger depart7
    after insert or update on emple
declare 
    cursor c1 is 
        select count(emp_no) contador, dept_no from emple 
            group by dept_no;
begin 
    for v1 in c1 loop 
        if v1.contador > 7 then
            raise_application_error(-20000, 'Error. No es posible más de 7 empleadas/os por departamento.');
        end if;
    end loop;
end;

insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 2000, 50, 30);
/*1 fila creada.*/
insert into emple 
    values(1001, 'VERDÚ', 'VENDEDOR', 7698, sysdate, 2000, null, 30);   
/*ORA-20000: Error. No es posible más de 7 empleadas/os por departamento.*/
rollback;
insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 2000, 50, 30);
/*1 fila creada.*/
update emple set dept_no = 30 
    where emp_no = 7369;
/*ORA-20000: Error. No es posible más de 7 empleadas/os por departamento.*/

----------------------------------------------------------------------------------

/*2.-Crear trigger para impedir que el salario total por departamento sea
superior a 15000 euros.*/
create or replace trigger salarioTotal
    after insert or update on emple 
declare 
    cursor c1 is 
        select sum(salario) salario_total, dept_no from emple 
            group by dept_no;
begin 
    for v1 in c1 loop 
        if v1.salario_total > 15000 then 
            raise_application_error(-20000, 'Error. El salario del departamento no puede superar los 15000.');
        end if;
    end loop;
end;

insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 2000, 50, 20);
/*1 fila creada.*/
insert into emple 
    values(1001, 'VERDÚ', 'VENDEDOR', 7698, sysdate, 3000, null, 20);
/*ORA-20000: Error. El salario del departamento no puede superar los 15000.*/
update emple set salario = 4000
    where emp_no = 1000;
/*ORA-20000: Error. El salario del departamento no puede superar los 15000.*/

----------------------------------------------------------------------------------

/*3.- Crear un trigger sobre la tabla empleados para que no se permita que
un empleado sea jefe de más de cinco empleados.*/
create or replace trigger jef5 
    after insert or update on emple 
declare 
    cursor c1 is 
        select count(emp_no) num_emple, dir from emple  
            group by dir;
begin 
    for v1 in c1 loop 
        if v1.num_emple > 5 then 
            raise_application_error(-20000, 'Error. Máximo 5 empleadas/os por jefa/e.');
        end if;
    end loop;
end;

insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 2000, 50, 20);
/*ORA-20000: Error. Máximo 5 empleadas/os por jefa/e.*/
insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7566, sysdate, 2000, 50, 20);
/*1 fila creada.*/
update emple set dir = 7698 
    where emp_no = 7369;
/*ORA-20000: Error. Máximo 5 empleadas/os por jefa/e.*/

----------------------------------------------------------------------------------

/*4.-Crear un trigger para asegurar que ningún empleado pueda cobrar más
que su jefe.*/
create or replace trigger cobrarJef
    after insert or update on emple 
declare 
    v_emp_no emple.emp_no%type;

    cursor c1 is 
        select emp_no, dir, salario from emple;

    cursor c2 is    
        select salario from emple 
            where emp_no = v_emp_no;
begin 
    for v1 in c1 loop 
        v_emp_no := v1.dir;
    
        for v2 in c2 loop 
            if v1.salario > v2.salario then 
                raise_application_error(-20000, 'Error. No es posible que empleada/o supere el salario de jefa/e.');
            end if;
        end loop;
    end loop;
end;

insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 3006, 50, 20);
/*ORA-20000: Error. No es posible que empleada/o supere el salario de jefa/e.*/
insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 1000, 50, 20);
/*1 fila creada.*/
update emple set salario = 4000 
    where emp_no = 7369;
/*ORA-20000: Error. No es posible que empleada/o supere el salario de jefa/e.*/

----------------------------------------------------------------------------------

/*5.- Crear un trigger para impedir que un empleado y su jefe pertenezcan a
departamentos distintos.*/
create or replace trigger departDistint
    after insert or update on emple 
declare 
    v_dir emple.dir%type;

    cursor c1 is 
        select * from emple;
    
    cursor c2 is    
        select * from emple 
            where emp_no = v_dir;
begin 
    for v1 in c1 loop 
        v_dir := v1.dir;
    
        for v2 in c2 loop 
            if v1.dept_no <> v2.dept_no then 
                raise_application_error(-20000, 'Error. Empleada/o y jefa/e deben pertener al mismo departamento.');
            end if;
        end loop;
    end loop;
end;


insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 3006, 50, 20);
/*ORA-20000: Error. Empleada/o y jefa/e deben pertener al mismo departamento.*/
insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 3006, 50, 30);
/*1 fila creada.*/

----------------------------------------------------------------------------------

-- BOLETÍN 6.

/*1.- Dada la vista Vnotas( Nombrealumno,NombreAsignatura,Nota), diseñar
disparadores para:
-Insertar una nueva nota.
-Modificar la nota de un alumno.
-Borrar una nota.
-Borrar todas las notas de un alumno.*/
create view Vnotas as 
    select apenom, nombre, nota from notas, alumnos, asignaturas
        where notas.dni = alumnos.dni and notas.cod = asignaturas.cod
        group by apenom, nombre, nota;

-- Insertar una nueva nota.
create or replace trigger insertarNota 
    instead of insert on Vnotas for each row 
declare 
    v_dni alumnos.dni%type;
    v_cod asignaturas.cod%type;
begin 
    select dni into v_dni from alumnos 
        where apenom = :new.apenom;
    
    select cod into v_cod from asignaturas 
        where nombre = :new.nombre;

    insert into notas 
        values(v_dni, v_cod, :new.nota);
exception 
    when no_data_found then 
        dbms_output.put_line('Error. No existe el dato.');
end;

insert into Vnotas
    values('Alcalde García, Elena', 'FOL', 5);
/*1 fila creada.*/
insert into Vnotas
    values('Alcalde García, Elena', 'HOL', 5);
/*Error. No existe el dato.*/

-- Modificar la nota de un alumno.
create or replace trigger modificaNota 
    instead of update on Vnotas for each row 
declare 
    v_dni alumnos.dni%type;
    v_cod asignaturas.cod%type;
begin 
    select dni into v_dni from alumnos 
        where apenom = :old.apenom;
    
    select cod into v_cod from asignaturas 
        where nombre = :old.nombre;
    
    update notas set nota = :new.nota 
        where dni = v_dni 
        and cod = v_cod;
end;    

update Vnotas set nota = 10
    where apenom = 'Alcalde García, Elena'
        and nombre = 'FOL';
/*1 fila actualizada.*/

-- Borrar una nota.
create or replace trigger borraNota 
    instead of delete on Vnotas for each row 
declare 
    v_dni alumnos.dni%type;
    v_cod asignaturas.cod%type;
begin     
    select dni into v_dni from alumnos 
        where apenom = :old.apenom;
    
    select cod into v_cod from asignaturas 
        where nombre = :old.nombre;
    
    delete from notas 
        where dni = v_dni 
        and cod = v_cod;
end;
    
delete from Vnotas 
    where apenom = 'Alcalde García, Elena'
        and nombre = 'FOL';
/*1 fila borrada.*/

-- Borrar todas las notas de un alumno.
create or replace trigger eliminaNotas
    instead of delete on Vnotas for each row
declare 
    v_dni alumnos.dni%type;
    v_cod asignaturas.cod%type;
begin 
    select dni into v_dni from alumnos 
        where apenom = :old.apenom;
    
    delete from notas 
        where dni = v_dni;
end;

delete from Vnotas 
    where apenom = 'Alcalde García, Elena';
/*3 filas borradas.*/

----------------------------------------------------------------------------------

/*2.-Crear una vista, en la que aparezca el apellido del empleado, el
nombre de su departamento, y el apellido de su jefe.
Diseñar disparadores que permitan:
- Insertar un nuevo empleado.
- Cambiar el departamento del empleado.
- Cambiar el jefe del empleado.
- Borrar un empleado. (Puede que sea jefe de otro)*/
create view Vdatos_emple as 
    select e1.apellido, d.dnombre, e2.apellido Jefe from emple e1, depart d, emple e2
        where e1.dept_no = d.dept_no and e1.dir = e2.emp_no(+);

-- Insertar un nuevo empleado.
create or replace trigger insertar_emple 
    instead of insert on Vdatos_emple for each row 
declare 
    v_dept depart.dept_no%type;
    v_emple emple.emp_no%type;
    v_dir emple.dir%type;
begin   
    select dept_no into v_dept from depart   
        where lower(dnombre) = lower(:new.dnombre);

    select max(emp_no)+1 into v_emple from emple;

    select emp_no into v_dir from emple
        where lower(apellido) = lower(:new.jefe);

    insert into emple (emp_no, apellido, dept_no, dir)
        values(v_emple, :new.apellido, v_dept, v_dir);
end;

insert into Vdatos_emple (apellido, dnombre, Jefe)
    values('VERDÚ', 'CONTABILIDAD', 'REY');

-- Cambiar el departamento del empleado.
create or replace trigger cambiar_departamento
    instead of update on Vdatos_emple for each row 
declare
    v_emple emple.emp_no%type;
    v_dept depart.dept_no%type;
begin   
    select emp_no into v_emple from emple 
        where lower(apellido) = lower(:new.apellido);

    select dept_no into v_dept from depart   
        where lower(dnombre) = lower(:new.dnombre);

    update emple set dept_no = v_dept 
	    where emp_no = v_emple;
end;

update Vdatos_emple set dnombre = 'VENTAS'
	where apellido = 'VERDÚ';

-- Cambiar el jefe del empleado.
create or replace trigger cambiar_jefe
    instead of update on Vdatos_emple for each row 
declare
    v_emple emple.emp_no%type;
    v_dir emple.dir%type;
    v_dept emple.dept_no%type;
begin   
    select emp_no into v_emple from emple 
        where lower(apellido) = lower(:new.apellido);

    select emp_no into v_dir from emple
        where lower(apellido) = lower(:new.jefe);
    
    select dept_no into v_dept from emple 
        where emp_no = v_dir;

    update emple set dir = v_dir, dept_no = v_dept
	    where emp_no = v_emple;
end;

update Vdatos_emple set Jefe = 'JIMENEZ'
	where apellido = 'VERDÚ';

-- Borrar un empleado. (Puede que sea jefe de otro).
create or replace trigger borrar_empleado
    instead of delete on Vdatos_emple for each row
declare 
    v_emple emple.emp_no%type;
begin   
    select emp_no into v_emple from emple 
        where lower(apellido) = lower(:old.apellido);

    delete from emple 
        where emp_no = v_emple;
    
    update emple set dir = null
        where dir = v_emple;
end;

delete from Vdatos_emple
    where apellido = 'VERDÚ';
delete from Vdatos_emple
    where apellido = 'JIMENEZ';

----------------------------------------------------------------------------------

/*3.- Dadas las tablas, Clientes,Productos,Ventas, crear una vista que muestre:
Nombre del cliente,Descripción del producto, Fecha de
venta,unidades,PrecioUnitario, Subtotal(precio*unidades).

Diseñar disparadores para:
- Insertar una venta.
- Borrar una venta.
- Modificar las unidades de una venta.
- Borrar todas las ventas de un cliente.
- Borrar todas las ventas de un producto.*/
create view VclienVentProd as
 	select clientes.nombre, productos.descripcion, ventas.fecha, ventas.unidades,
	productos.precio_uni, (ventas.unidades * productos.precio_uni) subtotal 
	from clientes, productos, ventas
		where clientes.nif = ventas.nif and ventas.cod_producto = productos.cod_producto;

-- Insertar una venta.
create or replace trigger insetar_venta
    instead of insert on VclienVentProd for each row 
declare
    	v_dni clientes.nif%type;
	    v_cod productos.cod_producto%type;
begin  
    select nif into v_dni from clientes
	    where lower(nombre) = lower(:new.nombre);

    select cod_producto into v_dni from productos
	    where lower(descripcion) = lower(:new.descripcion);

    insert into ventas
    	values(v_dni, v_cod, :new.fecha, :new.unidades);   
end;                      

insert into VclienVentProd (nombre, descripcion, fecha, unidades) 
	values ('MARINA', 'DISCO SCSI 4MB', '26/08/2016', 2);

-- Borrar una venta.
create or replace trigger borra_venta
    instead of delete on VclienVentProd for each row 
declare
    	v_dni clientes.nif%type;
	    v_cod productos.cod_producto%type;
begin  
    select nif into v_dni from clientes
	    where lower(nombre) = lower(:old.nombre);

    select cod_producto into v_cod from productos
	    where lower(descripcion) = lower(:old.descripcion);

    delete from ventas
	    where nif = v_dni and cod_producto = v_cod;
end; 

delete from VclienVentProd
	where nombre = 'TERESA' and descripcion = 'DISCO SCSI 4MB';

-- Modificar las unidades de una venta.
create or replace trigger modifica_venta
    instead of update on VclienVentProd for each row 
declare
    	v_dni clientes.nif%type;
	    v_cod productos.cod_producto%type;
begin  
    select nif into v_dni from clientes
	    where lower(nombre) = lower(:new.nombre);

    select cod_producto into v_cod from productos
	    where lower(descripcion) = lower(:new.descripcion);

    update ventas set unidades = :new.unidades
	    where nif = v_dni and cod_producto = v_cod;
end; 

update VclienVentProd set unidades = 7
	where nombre = 'JAIME' and descripcion = 'PROCESADOR K6';

-- Borrar todas las ventas de un cliente.
create or replace trigger borrar_ventas
    instead of delete on VclienVentProd for each row 
declare
    	v_dni clientes.nif%type;
begin  
    select nif into v_dni from clientes
	    where lower(nombre) = lower(:old.nombre);
    
    delete from ventas
	    where nif = v_dni;
end; 

delete from VclienVentProd
	where nombre = 'TERESA';

-- Borrar todas las ventas de un producto.
create or replace trigger borrar_venta
    instead of delete on VclienVentProd for each row 
    declare
    	v_cod productos.cod_producto%type;
begin  
    select cod_producto into v_cod from productos
	    where lower(descripcion) = lower(:old.descripcion);

    delete from ventas
	    where cod_producto = v_cod;
end; 

delete from VclienVentProd
	where descripcion = 'DISCO SCSI 4MB';

----------------------------------------------------------------------------------

/*4.- Crear un trigger de sistema que inserte una fila en una tabla de
registros, creada previamente, con la siguiente información:
- Nombre del usuario, hora, 'Entrada' si se conecta a la BD
- Nombre del usuario, hora, 'Salida' si finaliza la conexión.*/
create table registros(
    usuario varchar2(20),
    momento date, 
    evento varchar2(20)
);

/*Conexión del sistema:
	Usuario: system
	Contraseña: manager*/

-- Entrada.
create or replace trigger acceso_sistema
   after logon on database
begin
    insert into registros (usuario, momento, evento)
        values (ora_login_user, systimestamp, ora_sysevent);
end; 

-- Salida.
create or replace trigger salida_sistema
   before logoff on database
begin
    insert into registros (usuario, momento, evento)
        values (ora_login_user, systimestamp, ora_sysevent);
end; 

----------------------------------------------------------------------------------

-- BOLETÍN 7.

/*1.- Se desea anotar en la tabla auditoria cualquier hecho ocurrido
(insertar, borrar o modificar) y el número de filas afectadas sobre
la tabla emple. (Ej: "Se han borrado 5 filas")
Resolver utilizando Triggers y Paquetes.*/
create table auditoria
(
    informacion varchar2(30)
);

create or replace package auditorEmple as 
    contador number default 0;
end;

create or replace trigger contarAuditoria 
    before insert or update or delete on emple for each row 
begin 
    auditorEmple.contador := auditorEmple.contador + 1;
end;

create or replace trigger actualizarAuditoria 
    after insert or update or delete on emple 
begin 
    if inserting then 
		insert into auditoria
		    values(auditorEmple.contador || ' filas insertadas.');
	elsif deleting then
		insert into auditoria
		values(auditorEmple.contador || ' filas borradas.');
	elsif updating then
		insert into auditoria
		values(auditorEmple.contador || ' filas modificadas.');
    end if;
end;

create or replace trigger contador0
    before insert or update or delete on emple
begin
	auditorEmple.contador := 0;
end;

update emple set salario = 3000 
    where emp_no = 7369;
/*1 fila actualizada.*/
delete emple 
    where emp_no = 7369;
/*1 fila borrada.*/
select * from auditoria;
/*INFORMACION
------------------------------
1 filas modificadas.
1 filas borradas.*/

----------------------------------------------------------------------------------

/*2.- Se quiere conseguir la siguiente funcionalidad:
Al borrar un empleado, el campo dir se pondrá igual a nulo en todos
los empleados que dependan de él.
Resolver utilizando Triggers y Paquetes.*/
create or replace package dependenDir
as 
    type tr_emple is record(numero_emp_no emple.emp_no%type);
    type ta_emple is table of tr_emple index by binary_integer;

    tabla ta_emple;
end;

create or replace trigger borrarTabla 
    before delete on emple 
begin 
    dependenDir.tabla.delete;
end;

create or replace trigger cargarTabla 
    after delete on emple for each row 
declare 
    contador number;
begin 
    contador := dependenDir.tabla.count;
    contador := contador + 1;
    dependenDir.tabla(contador).numero_emp_no := :old.emp_no;
end;

create or replace trigger mostrarTabla 
    after delete on emple 
begin 
    for i in 1..dependenDir.tabla.count loop 
        update emple set dir = null 
            where dir = dependenDir.tabla(i).numero_emp_no;
        dbms_output.put_line('Eliminada/o: ' || dependenDir.tabla(i).numero_emp_no || '.');
    end loop;
end;

delete from emple 
    where emp_no = 7839;
/*Eliminada/o: 7839.*/

----------------------------------------------------------------------------------

/*3.- Retomamos los ejercicios 2 y 3 del boletin 4. Cargamos los dos y
modificamos el código del departamento 10. Su nuevo valor será 11.
Resolver utilizando Triggers y Paquetes.*/
create or replace package pk1 
as  
    type tr_depart is record(anterior depart.dept_no%type, nuevo depart.dept_no%type);
    type ta_depart is table of tr_depart index by binary_integer;

    tabla ta_depart;

    procedure actualizar_emple;
end;

create or replace package body pk1 
as 
    procedure actualizar_emple 
    as
    begin 
        for i in 1.. pk1.tabla.count loop 
            update emple set dept_no = tabla(i).nuevo 
                where dept_no = tabla(i).anterior;
        end loop;
    end;
end;

create or replace trigger borrarTabla
    before update of dept_no on depart 
begin 
    pk1.tabla.delete;
end;

create or replace trigger cargarTabla 
    after update of dept_no on depart for each row 
declare 
    contador number default 0;
begin 
    contador := pk1.tabla.count;
    contador := contador + 1;
    pk1.tabla(contador).anterior := :old.dept_no;
    pk1.tabla(contador).nuevo := :new.dept_no;
end;

create or replace trigger actualizarDatos 
    after update of dept_no on depart 
begin   
    pk1.actualizar_emple();
end;

create or replace trigger mostrarTabla
    before insert or update on emple for each row 
declare 
    tipo depart.dept_no%type;
begin 
    select dept_no into tipo from depart 
        where dept_no = :new.dept_no;
exception
    when no_data_found then 
        raise_application_error(-20000, 'Error. No existe el departamento.');
end;

update depart set dept_no = 11 
    where dept_no = 10;

----------------------------------------------------------------------------------

/*4.- Añadir un campo nuevo a la tabla depart llamado media_salario que
almacene la media de salarios de cada departamento.
Se quiere que se actualice su valor al insertar, borrar y modificar
la tabla emple. Resolver utilizando Triggers y Paquetes.*/
alter table depart 
    add media_salario number default 0;

create or replace package pk1 
as 
    type tr_depart is record(n_dept_no depart.dept_no%type);
    type ta_depart is table of tr_depart index by binary_integer;

    media number(9,2);

    tabla ta_depart;
    
    procedure actualizar_datos;
end;

create or replace package body pk1 
as 
    procedure actualizar_datos 
    as 
    begin 
        for i in 1.. pk1.tabla.count loop 
            select avg(salario) into pk1.media from emple 
                where dept_no = pk1.tabla(i).n_dept_no;
            
            update depart set media_salario = media 
                where dept_no = pk1.tabla(i).n_dept_no;
        end loop;
    end;
end;

create or replace trigger borrarTabla 
    before insert or update or delete on emple 
begin 
    pk1.tabla.delete;
end;

create or replace trigger cargarTabla 
    after insert or update or delete on emple 
declare 
    contador number default 1;
    
    cursor c1 is 
        select distinct dept_no from depart;
begin 
    for v1 in c1 loop 
        pk1.tabla(contador).n_dept_no := v1.dept_no;

        contador := contador + 1;
    end loop;

    pk1.actualizar_datos;
end;

update emple set salario = 1500
    where emp_no = 7369;

select * from depart;
/* DEPT_NO DNOMBRE        LOC            MEDIA_SALARIO
---------- -------------- -------------- -------------
        10 CONTABILIDAD   SEVILLA              2891,67
        20 INVESTIGACION  MADRID                  2366
        30 VENTAS         BARCELONA            1735,83
        40 PRODUCCION     BILBAO*/


