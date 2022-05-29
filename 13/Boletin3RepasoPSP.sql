-- BOLETÍN 3 REPASO TRIGGERS.

/*1. Realiza un trigger que incremente en un 5% el salario de un empleado si cambia la localidad del
departamento en que trabaja.*/
create or replace trigger incrementaLocalidad
    before update of loc on depart for each row 
begin 
    update emple set salario = salario * 1.05
        where dept_no = :new.dept_no;
exception 
    when no_data_found then 
        dbms_output.put_line('Error. El departamento no existe.');
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
create or replace trigger 



----------------------------------------------------------------------------------

/*4. Realiza un trigger que registre en la base de datos los intentos de modificar, actualizar o borrar
datos en las filas de la tabla EMPLE correspondientes al presidente y a los jefes de departamento,
especificando el usuario, la fecha y la operación intentada.*/


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

drop trigger maxMinEmple