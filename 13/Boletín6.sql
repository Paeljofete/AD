/*1.- Dada la vista Vnotas( Nombrealumno,NombreAsignatura,Nota), diseñar
disparadores para:
-Insertar una nueva nota.
-Modificar la nota de un alumno
-Borrar una nota.
-Borrar todas las notas de un alumno.*/
create view Vnotas as 
    select apenom, nombre, nota from notas, alumnos, asignaturas
        where notas.dni = alumnos.dni and notas.cod = asignaturas.cod
        group by apenom, nombre, nota;

--Insertar una nueva nota.
create or replace trigger insertar_notas 
    instead of insert on Vnotas for each row 
declare 
    v_datos alumnos.dni%type;
    v_cod asignaturas.cod%type;
begin   
    select dni into v_datos from alumnos 
        where lower(apenom) = lower(:new.apenom);

    select cod into v_cod from asignaturas
        where lower(nombre) = lower(:new.nombre);

    insert into notas 
        values(v_datos, v_cod, :new.nota);
end;

insert into Vnotas (apenom, nombre, nota)
    values('Alcalde García, Elena', 'FOL', 5);

--Modificar la nota de un alumno
create or replace trigger modificar_notas
    instead of update on Vnotas for each row 
declare 
    v_datos alumnos.dni%type;
    v_cod asignaturas.cod%type;
begin   
    select dni into v_datos from alumnos 
        where lower(apenom) = lower(:old.apenom);

    select cod into v_cod from asignaturas
        where lower(nombre) = lower(:old.nombre);

    update notas set nota = :new.nota
        where dni = v_datos
            and cod = v_cod;
end;       
    
update Vnotas set nota = 10
    where apenom = 'Alcalde García, Elena'
        and nombre = 'FOL';

--Borrar una nota.
create or replace trigger eliminar_nota
    instead of delete on Vnotas for each row
declare 
    v_datos alumnos.dni%type;
    v_cod asignaturas.cod%type;
begin 
    select dni into v_datos from alumnos 
        where lower(apenom) = lower(:old.apenom);

    select cod into v_cod from asignaturas
        where lower(nombre) = lower(:old.nombre);
    
    delete from notas 
        where dni = v_datos
            and cod = v_cod;
end;

delete from Vnotas 
    where apenom = 'Alcalde García, Elena'
        and nombre = 'FOL';

--Borrar todas las notas de un alumno.
create or replace trigger eliminar_notas
    instead of delete on Vnotas for each row
declare 
    v_datos alumnos.dni%type;
    v_cod asignaturas.cod%type;
begin 
    select dni into v_datos from alumnos 
        where lower(apenom) = lower(:old.apenom);
    
    delete from notas 
        where dni = v_datos;
end;

delete from Vnotas 
    where apenom = 'Alcalde García, Elena';

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
