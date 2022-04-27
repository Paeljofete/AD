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
    nombre_apellidos varchar2(20);

    cursor c1 is 
        select numMatricula, nombre || apellidos nombre_apellidos, precioMatricula from alumnos 
            where titulacion like 'Informatica';
begin 
    for v1 in c1 loop 
        dbms_output.put_line(v1.nombre_apellidos);
    
        insert into AlumnosInf 
            values(v1.numMatricula, v1.nombre_apellidos, v1.precioMatricula);
    end loop;
end;

execute insertar_informatica;
/*José Jiménez
Elena Martínez
Procedimiento PL/SQL terminado correctamente.*/

select * from alumnosinf
/*IDMATRICULA NOMBRE_APELLIDOS                                     PRECIO
----------- -------------------------------------------------- ----------
          2 José Jiménez                                             1200
          4 Elena Martínez                                           1200*/

----------------------------------------------------------------------------------

/*3. Dadas las siguientes tablas:
    CREATE TABLE Tabla_Departamento (
    Num_Depart Number(2) PRIMARY KEY,
    Nombre_Depart VARCHAR2(15),
    Ubicación VARCHAR2(15),
    Presupuesto NUMBER(10,2),
    Media_Salarios NUMBER(10,2),
    Total_Salarios NUMBER(10,2));

    CREATE TABLE Tabla_Empleado(
    Num_Empleado Number(4) PRIMARY KEY,
    Nombre_Empleado VARCHAR(25),
    Categoría VARCHAR(10), -- Gerente, Comercial, ...
    Jefe Number(4),
    Fecha_Contratacion DATE,
    Salario Number(7),
    Comision Number(7),
    Num_Depart NUMBER(2),
    FOREIGN KEY (Jefe) REFERENCES Tabla_Empleado,
    FOREIGN KEY (Num_Depart) REFERENCES Tabla_Departamento);

* Construya un procedimiento que pase los datos de la tabla emp a la tabla Tabla_Empleado, y los
datos de la tabla dept a Tabla_Departamento (dejando a 0 los dos últimos campos).*/

/*
 Nombre                                                                              ¿Nulo?   Tipo
 ----------------------------------------------------------------------------------- -------- --------------------------------------------------------
 EMP_NO                                                                              NOT NULL NUMBER(4)
 APELLIDO                                                                                     VARCHAR2(10)
 OFICIO                                                                                       VARCHAR2(10)
 DIR                                                                                          NUMBER(4)
 FECHA_ALT                                                                                    DATE
 SALARIO                                                                                      NUMBER(7)
 COMISION                                                                                     NUMBER(7)
 DEPT_NO                                                                             NOT NULL NUMBER(2)

 
 Nombre                                                                              ¿Nulo?   Tipo
 ----------------------------------------------------------------------------------- -------- --------------------------------------------------------
 DEPT_NO                                                                             NOT NULL NUMBER(2)
 DNOMBRE                                                                                      VARCHAR2(14)
 LOC                                                                                          VARCHAR2(14)
*/
create or replace procedure pasa_datos
as 
    cursor c1 is    
        select dept_no, dnombre, loc from depart;

    cursor c2 is    
        select emp_no, apellido, oficio, dir, fecha_alt, salario, comision, dept_no from emple;
begin 
    for v1 in c1 loop 
        insert into Tabla_Departamento 
            values(v1.dept_no, v1.dnombre, v1.loc, 0, 0, 0);       
    end loop;

    for v2 in c2 loop 
        insert into Tabla_Empleado
            values(v2.emp_no, v2.apellido, v2.oficio, v2.dir, v2.fecha_alt, v2.salario, v2.comision, v2.dept_no);
    end loop;

    dbms_output.put_line('Datos insertados en las nuevas tablas.');
end;

execute pasa_datos;
/*Datos insertados en las nuevas tablas.*/

select * from Tabla_Departamento;
/*NUM_DEPART NOMBRE_DEPART UBICACIÓN       PRESUPUESTO MEDIA_SALARIOS TOTAL_SALARIOS
---------- --------------- --------------- ----------- -------------- --------------
        10 CONTABILIDAD    SEVILLA                   0              0              0
        20 INVESTIGACION   MADRID                    0              0              0
        30 VENTAS          BARCELONA                 0              0              0
        40 PRODUCCION      BILBAO                    0              0              0*/

select * from Tabla_Empleado;
/*NUM_EMPLEADO NOMBRE_EMPLEADO         CATEGORÍA        JEFE FECHA_CO    SALARIO   COMISION NUM_DEPART
------------ ------------------------- ---------- ---------- -------- ---------- ---------- ----------
        7369 SANCHEZ                   EMPLEADO         7902 17/12/80     104000                    20
        7499 ARROYO                    VENDEDOR         7698 20/02/80     208000      39000         30
        7521 SALA                      VENDEDOR         7698 22/02/81     162500      65000         30
        7566 JIMENEZ                   DIRECTOR         7839 02/04/81     386750                    20
        7654 MARTIN                    VENDEDOR         7698 29/09/81     162500     182000         30
        7698 NEGRO                     DIRECTOR         7839 01/05/81     370500                    30
        7782 CEREZO                    DIRECTOR         7839 09/06/81     318500                    10
        7788 GIL                       ANALISTA         7566 09/11/81     390000                    20
        7839 REY                       PRESIDENTE            17/11/81     650000                    10
        7844 TOVAR                     VENDEDOR         7698 08/09/81     195000          0         30
        7876 ALONSO                    EMPLEADO         7788 23/09/81     143000                    20
        7900 JIMENO                    EMPLEADO         7698 03/12/81     123500                    30
        7902 FERNANDEZ                 ANALISTA         7566 03/12/81     390000                    20
        7934 MUÑOZ                     EMPLEADO         7782 23/01/82     169000                    10*/

/*
* Construya un procedimiento que calcule el presupuesto del departamento para el año próximo. Se
almacenará el mismo en la tabla Tabla_Departamento en la columna Presupuesto. Hay que tener en
cuenta las siguientes subidas de sueldo:
    Gerente + 20%
    Comercial + 15%
    Los demás empleados que no estén en ninguna de las categorías anteriores se les subirá el sueldo un
    10%.

* Construya un procedimiento que actualice el campo Total_Salarios y el campo Media_Salarios de
la tabla Tabla_Departamento, siendo el total la suma del salario de todos los empleados, igualmente
con la media.
    Para ello:
    − Cree un cursor C1, que devuelva todos los departamentos
    − Cree un cursor C2, que devuelva el salario y el código de todos los empleados de su
    departamento.*/

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
