/*1.- Crear un trigger para impedir que ningún departamento tenga más de 7
empleados.*/
create or replace trigger maxEmple7
    after insert or update on emple
declare 
    cursor c1 is 
        select count(emp_no) numemple, dept_no from emple
            group by dept_no;
begin 
	for v1 in c1 loop 
        if v1.numemple > 7 then 
            raise_application_error(-20000, 'No es posible incluir más empleados en el departamento: '|| v1.dept_no || '.');
        end if;
	end loop;
end;

insert into emple 
    values(2, 'VERDÚ', 'ANALISTA', 7698, sysdate, 2000, 0, 30);
insert into emple 
    values(3, 'PLANES', 'EMPLEADO', 7698, sysdate, 1500, 0, 30);
update emple set dept_no = 30
    where emp_no = 1;

/*2.-Crear trigger para impedir que el salario total por departamento sea
superior a 1500000 euros.*/
create or replace trigger salarioTotal
    after insert or update on emple
declare 
    cursor c1 is 
        select sum(salario) total, dept_no from emple
            group by dept_no;
begin 
	for v1 in c1 loop 
        if v1.total > 1500000 then 
            raise_application_error(-20000, 'No es posible superar 1500000 en el salario total del departamento.');
        end if;
	end loop;
end;

insert into emple 
    values(2, 'VERDÚ', 'ANALISTA', 7698, sysdate, 1000000, 0, 30);
update emple set salario = 1000000
    where emp_no = 1;

/*3.- Crear un trigger sobre la tabla empleados para que no se permita que
un empleado sea jefe de más de cinco empleados.*/
create or replace trigger jefe5
    after insert or update on emple
declare
    cursor c1 is 
    select count(emp_no) empXjefe, dir from emple
        group by dir;
begin 
	for v1 in c1 loop 
        if v1.empXjefe > 5 then 
            raise_application_error(-20000, 'No es posible superar 5 empleados por jefe.');
        end if;
	end loop;
end;

insert into emple 
    values(2, 'VERDÚ', 'ANALISTA', 7698, sysdate, 1000000, 0, 30);
update emple set dir = 7698
    where emp_no = 1;

/*4.-Crear un trigger para asegurar que ningún empleado pueda cobrar más
que su jefe.*/
create or replace trigger supJefe
    after insert or update on emple
declare 
    v_acoplam emple.dir%type;

    cursor c1 is 
        select emp_no, salario from emple;

    cursor c2 is 
        select salario from emple
            where dir = v_acoplam;
begin 
	for v1 in c1 loop 
        v_acoplam := v1.emp_no;

        for v2 in c2 loop 
            if v1.salario < v2.salario then 
                raise_application_error(-20000, 'No es posible superar el salario del jefe.');
            end if;
        end loop;
	end loop;
end;

insert into emple 
    values(3, 'VERDÚ', 'ANALISTA', 7782, sysdate, 1800, 0, 30);
update emple set salario = 1900
    where emp_no = 7934;

/*5.- Crear un trigger para impedir que un empleado y su jefe pertenezcan a
departamentos distintos.*/
create or replace trigger separJefEmp
    after insert or update on emple
declare 
    v_acoplam number;

    cursor c1 is 
        select emp_no, dept_no from emple;

    cursor c2 is 
        select dept_no from emple
            where dir = v_acoplam;
begin 
	for v1 in c1 loop 
        v_acoplam := v1.emp_no;

        for v2 in c2 loop 
            if v1.dept_no <> v2.dept_no then 
                raise_application_error(-20000, 'No es posible separar empleado y jefe de departamento.');
            end if;
        end loop;
	end loop;
end;

insert into emple 
    values(3, 'VERDÚ', 'ANALISTA', 7782, sysdate, 1800, 0, 10);
