-- BOLETÍN 3 REPASO TRIGGERS.

/*1. Realiza un trigger que incremente en un 5% el salario de un empleado si cambia la localidad del
departamento en que trabaja.*/
create or replace trigger incrementaLocalidad
    before update of loc on depart for each row 
begin 
    update emple set salario = salario * 1.05
        where dept_no = :old.dept_no;
end;

update depart set loc = 'MURCIA'
    where dept_no = 10;

----------------------------------------------------------------------------------

/*2. Realizar un trigger que impida que un departamento tenga más de 5 empleados o menos de dos.*/
create or replace trigger maxMinEmple
    after insert or update or delete on emple
declare         
    cursor c1 is 
        select count(emp_no) contador, dept_no from emple
            group by dept_no;
begin 
    for v1 in c1 loop 
        if v1.contador < 2 or v1.contador > 5 then 
            raise_application_error(-20000, 'El departamento no puede tener más de 5 empleadas/os o menos de dos.');
        end if;
    end loop;
end;

insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 2000, 50, 30);
/*ORA-20000: El departamento no puede tener más de 5 empleadas/os o menos de dos.*/
delete from emple 
    where emp_no = 7934;
/*ORA-20000: El departamento no puede tener más de 5 empleadas/os o menos de dos.*/

----------------------------------------------------------------------------------

/*3. Realizar un trigger que mantenga actualizada la columna CosteSalarial, con la suma de los salarios
y comisiones de los empleados de dichos departamentos reflejando cualquier cambio que se
produzca en la tabla empleados.*/
alter table depart 
    add CosteSalarial number(10) default 0;

create or replace trigger salarioComision 
    after insert or delete or update on emple 
declare 
    cursor c1 is 
        select sum(salario + nvl(comision, 0)) CosteSalarial, dept_no from emple 
            group by dept_no;
begin 
    for v1 in c1 loop 
        update depart set CosteSalarial = v1.CosteSalarial 
            where dept_no = v1.dept_no;
    end loop;
end;

select * from depart;
/*   DEPT_NO DNOMBRE        LOC            MEDIA_SALARIO COSTESALARIAL
---------- -------------- -------------- ------------- -------------
        10 CONTABILIDAD   SEVILLA              2891,67             0
        20 INVESTIGACION  MADRID                  2366             0
        30 VENTAS         BARCELONA            1735,83             0
        40 PRODUCCION     BILBAO                                   0*/
update emple set salario = 2000 
    where emp_no = 7369;
/*1 fila actualizada.*/
select * from depart;
/*   DEPT_NO DNOMBRE        LOC            MEDIA_SALARIO COSTESALARIAL
---------- -------------- -------------- ------------- -------------
        10 CONTABILIDAD   SEVILLA              2891,67          8675
        20 INVESTIGACION  MADRID                  2366         12330
        30 VENTAS         BARCELONA            1735,83         12475
        40 PRODUCCION     BILBAO                                   0*/

----------------------------------------------------------------------------------

/*4. Realiza un trigger que registre en la base de datos los intentos de modificar, actualizar o borrar
datos en las filas de la tabla EMPLE correspondientes al presidente y a los jefes de departamento,
especificando el usuario, la fecha y la operación intentada.*/
create table cambiosJef(
    Registros varchar2(200)

create or replace trigger cambiosPresidJef
    before insert or update or delete on emple for each row 
        when(old.oficio = 'PRESIDENTE' or old.oficio = 'DIRECTOR' or new.oficio = 'PRESIDENTE' or new.oficio = 'DIRECTOR')
begin 
    if inserting then 
        insert into cambiosJef
            values('Usuario: ' || :new.apellido || ' - ' || :new.emp_no || '. ' || to_char(sysdate, 'HH:MI DD/MM/YYYY') || '. Inserción.');
    elsif updating then 
        insert into cambiosJef
            values('Usuario: ' || :old.apellido || ' - ' || :old.emp_no || '. ' || to_char(sysdate, 'HH:MI DD/MM/YYYY') || '. Modificación.');
    elsif deleting then 
        insert into cambiosJef
            values('Usuario: ' || :old.apellido || ' - ' || :old.emp_no || '. ' || to_char(sysdate, 'HH:MI DD/MM/YYYY') || '. Borrado.');
    end if;
end;

insert into emple 
    values(1000, 'TENA', 'DIRECTOR', 7698, sysdate, 2000, 50, 30);

update emple set oficio = 'VENDEDOR'
    where emp_no = 1000;

delete from emple 
    where emp_no = 1000;

insert into emple 
    values(1000, 'TENA', 'VENDEDOR', 7698, sysdate, 2000, 50, 30);

insert into emple 
    values(1000, 'TENA', 'DIRECTOR', 7698, sysdate, 2000, 50, 30);

delete from emple 
    where emp_no = 1000;

select * from cambiosJef
/*REGISTROS
----------------------------------------------------------------------------------
Usuario: TENA - 1000. 06:30 02/06/2022. Inserción.
Usuario: TENA - 1000. 06:30 02/06/2022. Modificación.
Usuario: TENA - 1000. 06:33 02/06/2022. Inserción.
Usuario: TENA - 1000. 06:33 02/06/2022. Borrado.*/

