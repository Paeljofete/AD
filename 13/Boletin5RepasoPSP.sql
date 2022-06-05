-- BOLETÍN 5 REPASO TRIGGERS Y PAQUETES.

/*1.-Crear un trigger para impedir que ningún departamento tenga más de 7
empleados.*/
create or replace package max7Emple
as 
    type tr_emple is record(
        num_dept emple.dept_no%type);

    type ti_emple is table of tr_emple index by binary_integer;

    va_emple ti_emple;
end;

create or replace trigger borraTabla 
    before insert or update on emple 
begin 
    max7Emple.va_emple.delete;
end;

create or replace trigger cargaDato 
    after insert or update on emple for each row 
declare 
    contador number;
begin 
    contador := max7Emple.va_emple.count;
    max7Emple.va_emple(contador + 1).num_dept := :new.dept_no;
end;

create or replace trigger controla7
    after insert or update on emple 
declare 
    v_dept_no emple.dept_no%type;
    n integer := 0;
begin 
    n := max7Emple.va_emple.first;

    while max7Emple.va_emple.exists(n) loop 
        select count(emp_no) into v_dept_no from emple 
            where dept_no = max7Emple.va_emple(n).num_dept;
        
        if v_dept_no > 7 then 
            raise_application_error(-20000, 'Error. No es posible más de 7 empleadas/os por departamento.');
        end if;
        
        n := max7Emple.va_emple.next(n);
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
create or replace package salarioTotal 
as  
    type tr_depart is record(
        num_dept depart.dept_no%type);
    
    type ti_depart is table of tr_depart index by binary_integer;

    va_depart ti_depart;
end;

create or replace trigger borraTabla   
    before insert or update on emple 
begin 
    salarioTotal.va_depart.delete;
end;

create or replace trigger cargaDato 
    after insert or update on emple for each row 
declare 
    contador number;
begin 
    contador := salarioTotal.va_depart.count;
    salarioTotal.va_depart(contador + 1).num_dept := :new.dept_no;
end;

create or replace trigger controlaSalario
    after insert or update on emple 
declare 
    v_salario emple.salario%type;
    n integer := 0;
begin 
    n := salarioTotal.va_depart.first;

    while salarioTotal.va_depart.exists(n) loop 
        select sum(salario) into v_salario from emple 
            where dept_no = salarioTotal.va_depart(n).num_dept;
        
        if v_salario > 15000 then 
            raise_application_error(-20000, 'Error. El salario del departamento no puede ser superior a 15000.');
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
create or replace package max5Jef
as 
    type tr_emple is record(
        direct emple.emp_no%type);

    type ti_emple is table of tr_emple index by binary_integer;

    va_emple ti_emple;
end;

create or replace trigger borraTabla
    before insert or update on emple 
begin 
    max5Jef.va_emple.delete;
end;

create or replace trigger cargaDato
    after insert or update on emple for each row 
declare 
    contador number;
begin 
    contador := max5Jef.va_emple.count;
    max5Jef.va_emple(contador + 1).direct := :new.dir;
end;

create or replace trigger controlaMax
    after insert or update on emple 
declare 
    v_dir emple.emp_no%type;
    n integer := 0;
begin 
    n := max5Jef.va_emple.first;

    while max5Jef.va_emple.exists(n) loop 
        select count(emp_no) into v_dir from emple 
            where dir = max5Jef.va_emple(n).direct;
        
        if v_dir > 5 then 
            raise_application_error(-20000, 'Error. Cada jefa/e puede tener como máximo 5 empleadas/os a cargo.');
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
create or replace package cobraJef 
as 
    type tr_emple is record(
        direct emple.emp_no%type);
    
    type ti_emple is table of tr_emple index by binary_integer;

    va_emple ti_emple;
end;

create or replace trigger borraTabla
    before insert or update on emple 
begin 
    cobraJef.va_emple.delete;
end;

create or replace trigger cargaDato 
    after insert or update on emple for each row 
declare 
    contador number;
begin 
    contador := cobraJef.va_emple.count;
    cobraJef.va_emple(contador + 1).direct := :new.dir;
end;

create or replace trigger controlaCobro 
    after insert or update on emple 
declare 
    v_cobro number;
    n integer := 0;
begin 
    n := cobraJef.va_emple.first;

    while cobraJef.va_emple.exists(n) loop 
        select count(*) into v_cobro from emple e, emple f 
            where e.dir = f.emp_no 
            and e.salario = f.salario 
            and cobraJef.va_emple(n).direct = e.dir;ç
        
        if v_cobro > 0 then 
            raise_application_error(-20000, 'Error. Las/os empleadas/os no pueden cobrar más que su jefa/e.');
        end if;
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



----------------------------------------------------------------------------------

/*5.- Crear un trigger para impedir que un empleado y su jefe pertenezcan a
departamentos distintos.*/
create or replace package jefEmple 
as 
    type tr_emple is record(
        num_emple emple.emp_no%type,
        direct emple.emp_no%type);
    
    type ti_emple is table of tr_emple index by binary_integer;

    va_emple ti_emple;
end;

create or replace trigger borraTabla 
    before insert or update on emple 
begin 
    jefEmple.va_emple.delete;
end;

create or replace trigger cargaDato
    after insert or update on emple for each row 
declare 
    contador number;
begin 
    contador := jefEmple.va_emple.count;
    jefEmple.va_emple(contador + 1).num_emple := :new.emp_no;
    jefEmple.va_emple(contador + 1).direct := :new.dir;
end;

create or replace trigger controlaDepart 
    after insert or update on emple 
declare 
    v_dept emple.dept_no%type;
    v_dir emple.dept_no%type;
    n integer := 0;
begin 
    n := jefEmple.va_emple.first;

    while jefEmple.va_emple.exists(n) loop 
        select dept_no into v_dept from emple 
            where emp_no = jefEmple.va_emple(n).num_emple;
        
        select dept_no into v_dir from emple 
            where emp_no = jefEmple.va_emple(n).direct;

        if v_dept <> v_dir then 
            raise_application_error(-20000, 'Error. Empleada/o y jefa/e no pueden pertenercer a departamentos diferentes.');
        end if;
    end loop;
end;
    



insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 3006, 50, 20);
/*ORA-20000: Error. Empleada/o y jefa/e deben pertener al mismo departamento.*/
insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 3006, 50, 30);
/*1 fila creada.*/



drop package max7Emple