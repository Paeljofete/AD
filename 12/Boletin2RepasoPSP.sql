--BOLETÍN 2. PL/SQL.

/*1. Realizar un procedimiento que incremente el salario el 10% a los empleados que tengan una
comisión superior al 5% del salario, y visualice el nombre, comisión y salario antiguo, y el nombre,
comisión y salario nuevo de todos los empleados.*/
create or replace procedure incrementa_salario 
as 
    v_apellido emple.apellido%type;
    v_comision emple.comision%type;
    v_salario emple.salario%type;
    v_salarioNuevo emple.salario%type;

    cursor c1 is 
        select apellido, comision, salario from emple 
            where comision > 0.05 * salario for update;
begin 
    open c1;
    
    fetch c1 into v_apellido, v_comision, v_salario;

    while c1%found loop 
        update emple set salario = salario * 1.1 
            where current of c1;

        select salario into v_salarioNuevo from emple  
            where apellido = v_apellido;

        dbms_output.put_line('Empleado: ' || v_apellido || '. Comisión: ' || v_comision || '. Salario: ' || v_salario || '.');
        dbms_output.put_line('Empleado: ' || v_apellido || '. Comisión: ' || v_comision || '. Salario: ' || v_salarioNuevo || '.');

        fetch c1 into v_apellido, v_comision, v_salario;
    end loop;

    close c1;
end;

execute incrementa_salario;
/*Empleado: ARROYO. Comisión: 390. Salario: 1650.
Empleado: ARROYO. Comisión: 390. Salario: 1815.
Empleado: SALA. Comisión: 650. Salario: 1788.
Empleado: SALA. Comisión: 650. Salario: 1967.
Empleado: MARTIN. Comisión: 1020. Salario: 1760.
Empleado: MARTIN. Comisión: 1020. Salario: 1936.*/
    
----------------------------------------------------------------------------------

/*2. Dadas las siguientes tablas:
-- tabla para almacenar todos los alumnos de la BD
    CREATE TABLE Alumnos
        (numMatricula NUMBER(4) PRIMARY KEY,
        nombre VARCHAR2(15),
        apellidos VARCHAR2(30),
        titulacion VARCHAR2(15),
        precioMatricula NUMBER(6,2));
-- tabla para los alumnos de informática
        CREATE TABLE AlumnosInf
        (IDMatricula NUMBER(4) PRIMARY KEY,
        nombre_apellidos VARCHAR2(50),
        precio NUMBER(6,2));

Inserte los siguientes datos de prueba en la tabla ALUMNOS:
numMatricula
1
2
3
4

nombre
Juan
José
Maria
Elena

apellidos
Álvarez
Jiménez
Pérez
Martínez

titulacion
Administrativo
Informatica
Administrativo
Informatica

precioMatricula
1000
1200
1000
1200

Construya un procedimiento que inserte solo los alumnos de informática en la tabla
ALUMNOSINF, teniendo en cuenta la estructura de esta tabla, así por ejemplo, debe tener en
cuenta que el atributo nombre_apellidos resulta de la concatenación de los atributos nombre y
apellidos. Antes de la inserción de cada tupla en la tabla ALUMNOSINF debe mostrar por pantalla
el nombre y el apellido que va a insertar.*/

insert into alumnos 
    values(1, 'Juan', ' Álvarez', 'Administrativo', 1000);
insert into alumnos 
    values(2, 'José', ' Jiménez', 'Informatica', 1200);
insert into alumnos 
    values(3, 'Maria', ' Pérez', 'Administrativo', 1000);
insert into alumnos 
    values(4, 'Elena', ' Martínez', 'Informatica', 1200);

create or replace procedure insertar_informatica
as 
    v_id alumnos.numMatricula%type;
    v_nombre alumnos.nombre%type;
    v_apellidos alumnos.apellidos%type;
    v_precio alumnos.precio%type;

    cursor c1 is 
        select numMatricula, nombre, apellidos, precio from alumnos 
            where titulacion like 'Informatica';
begin 
    open c1;

    fetch c1 into v_id, v_nombre, v_apellidos;

    while c1%found loop 
        select v_nombre || v_apellidos as nombre_apellidos from alumnos;
    
        insert into AlumnosInf 
            values(v_id, nombre_apellidos, v_precio);




----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
