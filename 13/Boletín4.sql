/*1.- Crear un trigger que simule un borrado en cascada, de modo que al
borrar un departamento, borre todos los empleados de ese
departamento.*/
create or replace trigger borradoCascada
    before delete on depart for each row 
begin 
    delete from emple where emple.dept_no = :old.dept_no;

    dbms_output.put_line('Se ha borrado el departamento ' || :old.dept_no || ' y todos los empleados asociados a él.');
end;

delete depart 
    where dept_no = 20;

/*2.- Crear un trigger que simule una modificación en cascada, de modo
que al modificar un departamento, actualice su valor para todos sus
empleados.*/
create or replace trigger modificaCascada
    before update of dept_no on depart for each row 
begin 
    update emple set dept_no = :new.dept_no
        where dept_no = :old.dept_no;

    dbms_output.put_line('Se ha modificado el número del departamento ' || :old.dept_no || ' que ahora es: ' 
        || :new.dept_no || '. A los empleados también se les ha actualizado el departamento.');
end;

update depart set dept_no = 50
    where dept_no = 20;

/*3.- Crear un trigger que impida que un empleado pertenezca a un
departamento inexistente.*/
create or replace trigger empleadoDepartamento
    before insert or update of dept_no on emple for each row
declare 
    v_comprueba depart.dept_no%type;
begin   
    select dept_no into v_comprueba from depart 
        where dept_no = :new.dept_no;

        dbms_output.put_line('')




/*4.- Crear un trigger para impedir que se aumente el salario de un
empleado en más de un 20%.*/
create or replace trigger subir20 
    before update of salario on emple for each row 
begin 
    if :new.salario > :old.salario * 1.20 then
        raise_application_error(-20000, 'No es posible aumentar el salario más del 20%.');
    end if;
end;

update emple set salario = 1100
    where emp_no = 7934;

/*5.- Escribir un disparador de base de datos que haga fallar cualquier
operación de modificación del apellido o del número de un empleado, o
que suponga una subida de sueldo superior al 20%.*/
create or replace trigger datosEmpleados 
    before update of apellido, emp_no, salario on emple for each row
begin 
    if :new.apellido <> :old.apellido then 
        raise_application_error(-20000, 'No es posible cambiar el apellido.');
    end if;

    if :new.emp_no <> :old.emp_no then 
        raise_application_error(-20000, 'No es posible cambiar el número de empleado.');
    end if;

    if :new.salario > :old.salario * 1.20 then 
        raise_application_error(-20000, 'No es posible aumentar el salario más del 20%.');
    end if;
end;

update emple set salario = 1320
    where emp_no = 7934;

update emple set apellido = 'FERNÁNDEZ'
    where emp_no = 1;

update emple set emp_no = 2
    where emp_no = 7934;

create or replace datosEmpleados
    before update on emple for each row
begin 
    if updating('APELLIDO') then 
        raise_application_error(-20000, 'No es posible cambiar el apellido.');
    elsif updating('EMP_NO') then 
        raise_application_error(-20000, 'No es posible cambiar el número de empleado.');
    elsif updating('SALARIO') then 
        raise_application_error(-20000, 'No es posible aumentar el salario más del 20%.');
    end if;
end;

/*6.- Crear un trigger que garantice que la comisión de los nuevos
empleados sea del 1% de su salario.*/
create or replace trigger comision1
    before insert on emple for each row
begin   
    :new.comision = :new.salario * 0.01;

    dbms_output.put_line('La comisión debe ser del 1% del salario.');
end;

insert into emple
    values(2, 'VERDÚ', 'ANALISTA', 7698, to char(sysdate('dd/mm/yy')), 2000, 0, 30);


/*7.- Dadas las tablas Centros, Personal y Profesores, crear un trigger
que al insertar o borrar un profesor en la tabla Personal mantenga
actualizada la tabla Profesores.*/
create or replace trigger profesor
    before 

 
