-- BOLETÍN 4 REPASO TRIGGERS.

/*1. Crea un procedimiento que vuelque el contenido de Emple en un Varray y muestre su contenido.*/
create or replace procedure varrayEmple 
as 
    cursor c1 is 
        select * from emple;

    type tr_emple is record(
        emp_no emple.emp_no%type,
        apellido emple.apellido%type,
        oficio emple.oficio%type,
        dir emple.dir%type,
        fecha_alt emple.fecha_alt%type,
        salario emple.salario%type,
        comision emple.comision%type,
        dept_no emple.dept_no%type);

    type tv_emple is varray(14) of tr_emple;

    va_emple tv_emple := tv_emple(null, null, null, null, null, null, null, null, null, null, null, null, null, null);

    n integer := 0;
begin 
    for v1 in c1 loop 
        n := c1%rowcount;
        va_emple(n) := v1;
    end loop;

    for i in 1..n loop 
        dbms_output.put_line(va_emple(i).emp_no || ' - ' || va_emple(i).apellido || ' - ' || va_emple(i).oficio || ' - '
            || va_emple(i).dir || ' - ' || va_emple(i).fecha_alt || ' - ' || va_emple(i).salario || ' - ' || va_emple(i).comision
            || ' - ' || va_emple(i).dept_no || '.');
    end loop;
end;

execute varrayEmple;
/*7369 - SANCHEZ - EMPLEADO - 7902 - 17/12/1990 - 1500 -  - 20.
7499 - ARROYO - VENDEDOR - 7698 - 20/02/1990 - 1500 - 390 - 30.
7521 - SALA - VENDEDOR - 7698 - 22/02/1991 - 1625 - 650 - 30.
7566 - JIMENEZ - DIRECTOR - 7839 - 02/04/1991 - 2900 -  - 20.
7654 - MARTIN - VENDEDOR - 7698 - 29/09/1991 - 1600 - 1020 - 30.
7698 - NEGRO - DIRECTOR - 7839 - 01/05/1991 - 3005 -  - 30.
7782 - CEREZO - DIRECTOR - 7839 - 09/06/1991 - 2885 -  - 10.
7788 - GIL - ANALISTA - 7566 - 09/11/1991 - 3000 -  - 20.
7839 - REY - PRESIDENTE -  - 17/11/1991 - 4100 -  - 10.
7844 - TOVAR - VENDEDOR - 7698 - 08/09/1991 - 1350 - 0 - 30.
7876 - ALONSO - EMPLEADO - 7788 - 23/09/1991 - 1430 -  - 20.
7900 - JIMENO - EMPLEADO - 7698 - 03/12/1991 - 1335 -  - 30.
7902 - FERNANDEZ - ANALISTA - 7566 - 03/12/1991 - 3000 -  - 20.
7934 - MUÑOZ - EMPLEADO - 7782 - 23/01/1992 - 1690 -  - 10.*/

----------------------------------------------------------------------------------

/*2. Crea un procedimiento que vuelque el contenido de Depart en una tabla anidada y muestre su
contenido.*/
create or replace procedure anidadaDepart
as 
    cursor c1 is 
        select * from depart;
    
    type tr_depart is record(
        dept_no depart.dept_no%type,
        dnombre depart.dnombre%type,
        loc depart.loc%type);
    
    type ta_depart is table of tr_depart;

    va_depart ta_depart;

    n integer := 0;
begin 
    va_depart := ta_depart();

    for v1 in c1 loop 
        n := c1%rowcount;
        va_depart.extend;
        va_depart(n).dept_no := v1.dept_no;
        va_depart(n).dnombre := v1.dnombre;
        va_depart(n).loc := v1.loc;
    end loop; 

    for i in 1..n loop 
        dbms_output.put_line(va_depart(i).dept_no || ' - ' || va_depart(i).dnombre || ' - ' || va_depart(i).loc || '.');
    end loop;
end;

execute anidadaDepart;
/*10 - CONTABILIDAD - SEVILLA.
20 - INVESTIGACION - MADRID.
30 - VENTAS - BARCELONA.
40 - PRODUCCION - BILBAO.*/

----------------------------------------------------------------------------------

/*3. Crea un paquete con los procedimientos anteriores. Añade procedimientos para actualizar la
información de ambas colecciones.*/
create or replace package varrayAnidada 
as 
    procedure varrayEmple;

    type tr_emple is record(
        emp_no emple.emp_no%type,
        apellido emple.apellido%type,
        oficio emple.oficio%type,
        dir emple.dir%type,
        fecha_alt emple.fecha_alt%type,
        salario emple.salario%type,
        comision emple.comision%type,
        dept_no emple.dept_no%type);

    type tv_emple is varray(14) of tr_emple;

    va_emple tv_emple;

    procedure anidadaDepart;
    
    type tr_depart is record(
        dept_no depart.dept_no%type,
        dnombre depart.dnombre%type,
        loc depart.loc%type);
    
    type ta_depart is table of tr_depart;

    va_depart ta_depart;
end;

create or replace package body varrayAnidada
as 
    procedure varrayEmple 
    as 
        cursor c1 is    
            select * from emple;
        
        n integer := 0;

        va_emple tv_emple := tv_emple(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
    begin 
        for v1 in c1 loop 
            n := c1%rowcount;
            va_emple(n) := v1;
        end loop;

        for i in 1..n loop 
            dbms_output.put_line(va_emple(i).emp_no || ' - ' || va_emple(i).apellido || ' - ' || va_emple(i).oficio || ' - '
                || va_emple(i).dir || ' - ' || va_emple(i).fecha_alt || ' - ' || va_emple(i).salario || ' - ' || va_emple(i).comision
                || ' - ' || va_emple(i).dept_no || '.');
        end loop;
    end;

    procedure anidadaDepart
    as 
        cursor c1 is 
            select * from depart;
        
        n integer := 0;
    begin 
        va_depart := ta_depart();

        for v1 in c1 loop 
            n := c1%rowcount;
            va_depart.extend;
            va_depart(n).dept_no := v1.dept_no;
            va_depart(n).dnombre := v1.dnombre;
            va_depart(n).loc := v1.loc;
        end loop;

        for i in 1..n loop 
            dbms_output.put_line(va_depart(i).dept_no || ' - ' || va_depart(i).dnombre || ' - ' || va_depart(i).loc || '.');
        end loop;
    end;
end;

execute varrayAnidada.varrayEmple;
/*7369 - SANCHEZ - EMPLEADO - 7902 - 17/12/1990 - 1500 -  - 20.
7499 - ARROYO - VENDEDOR - 7698 - 20/02/1990 - 1500 - 390 - 30.
7521 - SALA - VENDEDOR - 7698 - 22/02/1991 - 1625 - 650 - 30.
7566 - JIMENEZ - DIRECTOR - 7839 - 02/04/1991 - 2900 -  - 20.
7654 - MARTIN - VENDEDOR - 7698 - 29/09/1991 - 1600 - 1020 - 30.
7698 - NEGRO - DIRECTOR - 7839 - 01/05/1991 - 3005 -  - 30.
7782 - CEREZO - DIRECTOR - 7839 - 09/06/1991 - 2885 -  - 10.
7788 - GIL - ANALISTA - 7566 - 09/11/1991 - 3000 -  - 20.
7839 - REY - PRESIDENTE -  - 17/11/1991 - 4100 -  - 10.
7844 - TOVAR - VENDEDOR - 7698 - 08/09/1991 - 1350 - 0 - 30.
7876 - ALONSO - EMPLEADO - 7788 - 23/09/1991 - 1430 -  - 20.
7900 - JIMENO - EMPLEADO - 7698 - 03/12/1991 - 1335 -  - 30.
7902 - FERNANDEZ - ANALISTA - 7566 - 03/12/1991 - 3000 -  - 20.
7934 - MUÑOZ - EMPLEADO - 7782 - 23/01/1992 - 1690 -  - 10.*/

execute varrayAnidada.anidadaDepart;
/*10 - CONTABILIDAD - SEVILLA.
20 - INVESTIGACION - MADRID.
30 - VENTAS - BARCELONA.
40 - PRODUCCION - BILBAO.*/

----------------------------------------------------------------------------------

/*4. Crea un paquete con dos procedimientos que vuelquen el contenido de emple y depart en dos tablas
indexadas y muestren su contenido. Añade procedimientos para actualizar la información de ambas
tablas indexadas.*/
create or replace package indexEmpleDepart 
as 
    procedure indexEmple;

    type tr_emple is record(
        emp_no emple.emp_no%type,
        apellido emple.apellido%type,
        oficio emple.oficio%type,
        dir emple.dir%type,
        fecha_alt emple.fecha_alt%type,
        salario emple.salario%type,
        comision emple.comision%type,
        dept_no emple.dept_no%type);

    type ti_emple is table of tr_emple index by binary_integer;

    va_emple ti_emple;

    procedure indexDepart;

    type tr_depart is record(
        dept_no depart.dept_no%type,
        dnombre depart.dnombre%type,
        loc depart.loc%type);
    
    type ti_depart is table of tr_depart index by binary_integer;

    va_depart ti_depart;
end;

create or replace package body indexEmpleDepart 
as 
    procedure indexEmple
    as 
        cursor c1 is 
            select * from emple;

        n integer := 0;
    begin 
        for v1 in c1 loop 
            va_emple(v1.emp_no).emp_no := v1.emp_no;
            va_emple(v1.emp_no).apellido := v1.apellido;
            va_emple(v1.emp_no).oficio := v1.oficio;
            va_emple(v1.emp_no).dir := v1.dir;
            va_emple(v1.emp_no).fecha_alt := v1.fecha_alt;
            va_emple(v1.emp_no).salario := v1.salario;
            va_emple(v1.emp_no).comision := v1.comision;
            va_emple(v1.emp_no).dept_no := v1.dept_no;
        end loop;

        n := va_emple.first;

        while va_emple.exists(n) loop 
            dbms_output.put_line(va_emple(n).emp_no || ' - ' || va_emple(n).apellido || ' - ' || va_emple(n).oficio || ' - '
                || va_emple(n).dir || ' - ' || va_emple(n).fecha_alt || ' - ' || va_emple(n).salario || ' - ' || va_emple(n).comision
                || ' - ' || va_emple(n).dept_no || '.');
            
            n := va_emple.next(n);
        end loop;
    end;

    procedure indexDepart 
    as 
        cursor c1 is 
            select * from depart;
        
        n integer := 0;
    begin
        for v1 in c1 loop 
            va_depart(v1.dept_no).dept_no := v1.dept_no;
            va_depart(v1.dept_no).dnombre := v1.dnombre;
            va_depart(v1.dept_no).loc := v1.loc;
        end loop;

        n := va_depart.first;

        while va_depart.exists(n) loop 
            dbms_output.put_line(va_depart(n).dept_no || ' - ' || va_depart(n).dnombre || ' - ' || va_depart(n).loc || '.');

            n := va_depart.next(n);
        end loop;
    end;
end;

execute indexEmpleDepart.indexEmple;
/*7369 - SANCHEZ - EMPLEADO - 7902 - 17/12/1990 - 1500 -  - 20.
7499 - ARROYO - VENDEDOR - 7698 - 20/02/1990 - 1500 - 390 - 30.
7521 - SALA - VENDEDOR - 7698 - 22/02/1991 - 1625 - 650 - 30.
7566 - JIMENEZ - DIRECTOR - 7839 - 02/04/1991 - 2900 -  - 20.
7654 - MARTIN - VENDEDOR - 7698 - 29/09/1991 - 1600 - 1020 - 30.
7698 - NEGRO - DIRECTOR - 7839 - 01/05/1991 - 3005 -  - 30.
7782 - CEREZO - DIRECTOR - 7839 - 09/06/1991 - 2885 -  - 10.
7788 - GIL - ANALISTA - 7566 - 09/11/1991 - 3000 -  - 20.
7839 - REY - PRESIDENTE -  - 17/11/1991 - 4100 -  - 10.
7844 - TOVAR - VENDEDOR - 7698 - 08/09/1991 - 1350 - 0 - 30.
7876 - ALONSO - EMPLEADO - 7788 - 23/09/1991 - 1430 -  - 20.
7900 - JIMENO - EMPLEADO - 7698 - 03/12/1991 - 1335 -  - 30.
7902 - FERNANDEZ - ANALISTA - 7566 - 03/12/1991 - 3000 -  - 20.
7934 - MUÑOZ - EMPLEADO - 7782 - 23/01/1992 - 1690 -  - 10.*/

execute indexEmpleDepart.indexDepart;
/*10 - CONTABILIDAD - SEVILLA.
20 - INVESTIGACION - MADRID.
30 - VENTAS - BARCELONA.
40 - PRODUCCION - BILBAO.*/


