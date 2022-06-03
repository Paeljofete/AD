-- BOLETÍN 4 REPASO TRIGGERS.

/*1. Crea un procedimiento que vuelque el contenido de Emple en un Varray y muestre su contenido.*/
create or replace procedure varrayEmple 
as 
    cursor c1 is 
        select * from emple;

    type tr_emple is record(
        emp_no emple.emp_no%TYPE,
        apellido emple.apellido%TYPE,
        oficio emple.oficio%TYPE,
        dir emple.dir%TYPE,
        fecha_alt emple.fecha_alt%TYPE,
        salario emple.salario%TYPE,
        comision emple.comision%TYPE,
        dept_no emple.dept_no%TYPE);

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
        dept_no depart.dept_no%TYPE,
        dnombre depart.dnombre%TYPE,
        loc depart.loc%TYPE);
    
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
        emp_no emple.emp_no%TYPE,
        apellido emple.apellido%TYPE,
        oficio emple.oficio%TYPE,
        dir emple.dir%TYPE,
        fecha_alt emple.fecha_alt%TYPE,
        salario emple.salario%TYPE,
        comision emple.comision%TYPE,
        dept_no emple.dept_no%TYPE);

    type tv_emple is varray(14) of tr_emple;

    va_emple tv_emple;

    procedure anidadaDepart;
    
    type tr_depart is record(
        dept_no depart.dept_no%TYPE,
        dnombre depart.dnombre%TYPE,
        loc depart.loc%TYPE);
    
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



drop procedure 
anidadaDepart