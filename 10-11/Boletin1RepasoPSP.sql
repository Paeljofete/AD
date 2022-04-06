--BOLETÍN 1. PL/SQL.

/*1. Hacer un procedimiento que muestre el nombre y el salario del empleado cuyo código es 7782.*/
create or replace procedure datos_emple
as 
    v_nombre emple.apellido%type;
    v_salario emple.salario%type;
begin 
    select apellido, salario into v_nombre, v_salario from emple 
        where emp_no = 7782;
    
    dbms_output.put_line('Empleado: ' || v_nombre || ' - ' || v_salario || '€.');
end;

execute datos_emple;
/*Empleado: CEREZO - 2885€.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*2. Hacer un procedimiento que reciba como parámetro un nombre de departamento y devuelva su localidad.*/
create or replace procedure loc_depart(nombre_depart depart.dnombre%type)
as 
    v_loc depart.loc%type;
begin 
    select loc into v_loc from depart 
        where dnombre = nombre_depart;
    
    dbms_output.put_line(v_loc);
end;

execute loc_depart('VENTAS');
/*BARCELONA
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*3. Crear un procedimiento que cuente el número de filas que hay en la tabla EMP (de
Scott), deposita el resultado en una variable y visualiza su contenido.*/
create or replace procedure filas_emple
as 
    v_filas number;
begin 
    select count(*) into v_filas from emple;

    dbms_output.put_line('Número de filas de la tabla EMPLE: ' || v_filas || '.');
end;

execute filas_emple;
/*Número de filas de la tabla EMPLE: 14.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*4. Codificar un procedimiento que reciba una cadena y la visualice sin vocales.*/
create or replace procedure sin_vocales(cadena varchar2)
as 
    v_cadena varchar2(50);
begin 
    for i in 1..length(cadena) loop 
        if(ascii(substr(cadena, i, 1)) = 65 or ascii(substr(cadena, i, 1)) = 69 or 
        ascii(substr(cadena, i, 1)) = 73 or ascii(substr(cadena, i, 1)) = 79 or 
        ascii(substr(cadena, i, 1)) = 85
        or ascii(substr(cadena, i, 1)) = 97 or ascii(substr(cadena, i, 1)) = 101 or 
        ascii(substr(cadena, i, 1)) = 105 or ascii(substr(cadena, i, 1)) = 111 or ascii(substr(cadena, i, 1)) = 117) then 
            v_cadena := v_cadena || ' ';
                else
            v_cadena := v_cadena || substr(cadena, i, 1);
        end if;
    end loop;

    dbms_output.put_line(v_cadena);
end;

execute sin_vocales('Murcielago, ALBARICOQUE');
/*M rc  l g ,  LB R C Q
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*5. Escribir un procedimiento que reciba una fecha y escriba el nombre del día de la
semana y el nombre del mes correspondientes.*/
create or replace procedure mostrar_fecha(fecha date)
as 
    v_dia varchar2(10);
    v_mes varchar2(10);
begin 
    v_dia := to_char(fecha, 'day');
    v_mes := to_char(fecha, 'month');

    dbms_output.put_line(v_dia || ' * ' || v_mes);
end;

execute mostrar_fecha(sysdate);

----------------------------------------------------------------------------------

/*6. Codificar un procedimiento que reciba una lista de hasta 4 números y visualice su producto.*/
create or replace procedure producto(
    num1 number default 1,
    num2 number default 1,
    num3 number default 1,
    num4 number default 1)
as 
    multiplicacion number;
begin
    multiplicacion := num1 * num2 * num3 * num4;

    dbms_output.put_line(num1 || ' x ' || num2 || ' x ' || num3 || ' x ' || num4 || ' = ' || multiplicacion);
end;

execute producto(10, 63);
/*10 x 63 x 1 x 1 = 630
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*7. Implementar un procedimiento que reciba un importe y visualice el desglose del
cambio en unidades monetarias de 0.01, 0.02, 0.05, 0.10, 0.20, 0.50, 1, 2, 5, 10,
20, 50, 100, 200, 500 y 1000€ en orden inverso al que aparecen aquí
enumeradas.*/
create or replace procedure cambio(importe number)
as 
    v_cambio number := importe;
    v_moneda number;
    v_cantidad number;
begin 
    dbms_output.put_line('Desglose de ' || importe || ' en unidades monetarias:');

    while v_cambio > 0 loop 
        if v_cambio >= 1000 then 
            v_moneda := 1000;
        elsif v_cambio >= 500 then 
            v_moneda := 500;
        elsif v_cambio >= 200 then 
            v_moneda := 200;
        elsif v_cambio >= 100 then 
            v_moneda := 100;
        elsif v_cambio >= 50 then
            v_moneda := 50;
        elsif v_cambio >= 20 then
            v_moneda := 20;
        elsif v_cambio >= 10 then
            v_moneda := 10;
        elsif v_cambio >= 5 then 
            v_moneda := 5;
        elsif v_cambio >= 2 then
            v_moneda := 2;
        elsif v_cambio >= 1 then 
            v_moneda := 1;
        elsif v_cambio >= 0.5 then 
            v_moneda := 0.5;
        elsif v_cambio >= 0.2 then 
            v_moneda := 0.2;
        elsif v_cambio >= 0.1 then 
            v_moneda := 0.1;
        elsif v_cambio >= 0.05 then 
            v_moneda := 0.05;
        elsif v_cambio >= 0.02 then 
            v_moneda := 0.02;
        else
            v_moneda := 0.01;
        end if;
    
    v_cantidad := trunc(v_cambio / v_moneda);
    v_cambio := mod(v_cambio, v_moneda);

    dbms_output.put_line(chr(9) || v_cantidad || ' de ' || v_moneda || '€.');
    end loop;
end;

execute cambio(2889.38);
/*Desglose de 2889,38 en unidades monetarias:
	2 de 1000€.
	1 de 500€.
	1 de 200€.
	1 de 100€.
	1 de 50€.
	1 de 20€.
	1 de 10€.
	1 de 5€.
	2 de 2€.
	1 de ,2€.
	1 de ,1€.
	1 de ,05€.
	1 de ,02€.
	1 de ,01€.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*8. Codificar un procedimiento que permita borrar un empleado cuyo número se pasará
en la llamada.*/
create or replace procedure borra_empleado (codemp emple.emp_no%TYPE)
as
begin 
    delete emple 
        where emp_no = codemp;
end;

execute borra_empleado(7934);
/*Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*9. Escribir un procedimiento que modifique el oficio de un empleado. El
procedimiento recibirá como parámetros el número del empleado y el oficio
nuevo.*/ 
create or replace procedure mod_oficio(
    num_emple emple.emp_no%type,
    nuevo_oficio emple.oficio%type)
as 
begin 
    update emple set oficio = nuevo_oficio 
        where emp_no = num_emple;
end;

/*    EMP_NO APELLIDO   OFICIO            DIR FECHA_AL    SALARIO   COMISION    DEPT_NO
---------- ---------- ---------- ---------- -------- ---------- ---------- ----------
      7934 MUÑOZ      EMPLEADO         7782 23/01/92       1690                    10*/

execute mod_oficio(7934, 'ANALISTA');
/*    EMP_NO APELLIDO   OFICIO            DIR FECHA_AL    SALARIO   COMISION    DEPT_NO
---------- ---------- ---------- ---------- -------- ---------- ---------- ----------
      7934 MUÑOZ      ANALISTA         7782 23/01/92       1690                    10*/

----------------------------------------------------------------------------------

/*10. Visualizar todos los procedimientos de usuarios almacenados en la base de
datos cuya situación sea ‘valid’.*/ 
select object_name, object_type, status from user_objects
    where object_type in('PROCEDURE', 'FUNCTION')
    and status = 'VALID';

/*OBJECT_NAME                                                                                                                    OBJECT_TYPE        STATUS
-------------------------------------------------------------------------------------------------------------------------------- ------------------ -------
ALFABET                                                                                                                          FUNCTION           VALID
BORRAR                                                                                                                           PROCEDURE          VALID
BORRA_EMPLE                                                                                                                      PROCEDURE          VALID
BORRA_EMPLEADO                                                                                                                   PROCEDURE          VALID
CADENA_AL_REVES                                                                                                                  PROCEDURE          VALID
CADENA_AL_REVES_FUN                                                                                                              FUNCTION           VALID
CAMBIAR_DIVISAS                                                                                                                  PROCEDURE          VALID
CAMBIO                                                                                                                           PROCEDURE          VALID
CON_IVA                                                                                                                          FUNCTION           VALID
CREAR_DEPART                                                                                                                     PROCEDURE          VALID
DATOS_EMPLE                                                                                                                      PROCEDURE          VALID
EJSQLDIN                                                                                                                         PROCEDURE          VALID
ENTRE_FECHAS                                                                                                                     FUNCTION           VALID
FECHA_DEV_ANIO                                                                                                                   FUNCTION           VALID
FILAS_EMPLE                                                                                                                      PROCEDURE          VALID
LOC_DEPART                                                                                                                       PROCEDURE          VALID
MODIFICAR_LOC                                                                                                                    PROCEDURE          VALID
MODIFICAR_PRECIO_PRODUCTO                                                                                                        PROCEDURE          VALID
MOD_OFICIO                                                                                                                       PROCEDURE          VALID
MOFICAR_LOC                                                                                                                      PROCEDURE          VALID
MOSTRAR_CAMBIO_DIVISAS                                                                                                           PROCEDURE          VALID
MOSTRAR_FECHA                                                                                                                    PROCEDURE          VALID
PRODUCTO                                                                                                                         PROCEDURE          VALID
SIN_VOCALES                                                                                                                      PROCEDURE          VALID
SUMA                                                                                                                             PROCEDURE          VALID
SUMAFUN                                                                                                                          FUNCTION           VALID
TRIENIOS                                                                                                                         FUNCTION           VALID
VER_PRECIO                                                                                                                       PROCEDURE          VALID
28 filas seleccionadas.
*/

----------------------------------------------------------------------------------

/*11. Realizar un procedimiento que reciba un número y muestre su tabla de
multiplicar.*/
create or replace procedure tabla_multiplicar(num number)
as 
begin 
    for i in 0..10 loop 
        dbms_output.put_line(num || ' x ' || i || ' = ' || num * i);
    end loop;
end;

execute tabla_multiplicar(2);
/*2 x 0 = 0
2 x 1 = 2
2 x 2 = 4
2 x 3 = 6
2 x 4 = 8
2 x 5 = 10
2 x 6 = 12
2 x 7 = 14
2 x 8 = 16
2 x 9 = 18
2 x 10 = 20
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*12. Realizar un procedimiento que reciba dos números 'nota' y 'edad' y un carácter
'sexo' y muestre el mensaje 'ACEPTADA' si la nota es mayor o igual a cinco, la edad
es mayor o igual a dieciocho y el sexo es 'M'. En caso de que se cumpla lo mismo,
pero el sexo sea 'V', debe imprimir 'POSIBLE'.*/
create or replace procedure posible(
    nota number,
    edad number,
    sexo char)
as 
begin 
    if nota >= 5 and edad >=18 then
        if sexo = 'M' then 
            dbms_output.put_line('ACEPTADA.');
        elsif sexo = 'V' then 
            dbms_output.put_line('POSIBLE.');
        end if;
    else 
        dbms_output.put_line('No cumple.');
    end if;
end;

execute posible(7, 20, 'M');
/*ACEPTADA.
Procedimiento PL/SQL terminado correctamente.*/

execute posible(5, 18, 'M');
/*ACEPTADA.
Procedimiento PL/SQL terminado correctamente.*/

execute posible(4, 18, 'M');
/*No cumple.
Procedimiento PL/SQL terminado correctamente.*/

execute posible(5, 18, 'V');
/*POSIBLE.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*13. Procedimiento que recibe una letra e imprima si es vocal o consonante.*/
create or replace procedure vocal_consonante(letra char)
as 
    v_letra varchar2(10) := 'consonante';
begin 
    if letra in ('A','E','I','O','U', 'a', 'e', 'i', 'o', 'u') then 
        v_letra := 'vocal';
    end if;

    dbms_output.put_line(letra || ' es una ' || v_letra || '.');
end;

execute vocal_consonante('a');
/*a es una vocal.
Procedimiento PL/SQL terminado correctamente.*/

execute vocal_consonante('U');
/*U es una vocal.
Procedimiento PL/SQL terminado correctamente.*/

execute vocal_consonante('c');
/*c es una consonante.
Procedimiento PL/SQL terminado correctamente.*/

execute vocal_consonante('H');
/*H es una consonante.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*14. Procedimiento que reciba un número y escribe la cantidad de números pares
que hay entre el 1 y el número indicado.*/
create or replace procedure par(num number)
as 
    contador number default 0;
begin 
    dbms_output.put_line('Pares:');

    for i in 1..num loop 
        if mod(i, 2) = 0 then 
            dbms_output.put_line(chr(9) || i);
            contador := contador + 1;
        end if;        
    end loop;

    dbms_output.put_line('Hay ' || contador || ' números pares desde el 1 hasta el ' || num || '.');
end;

execute par(3);
/*Pares:
	2
Hay 1 números pares desde el 1 hasta el 3.*/

execute par(8);
/*Pares:
	2
	4
	6
	8
Hay 4 números pares desde el 1 hasta el 8.*/

----------------------------------------------------------------------------------

/*15. Diseñar un procedimiento que muestre la suma de los números impares
comprendidos entre dos valores numéricos enteros y positivos recibidos por
parámetros.*/
create or replace procedure suma_impares(
    num1 integer,
    num2 integer)
as 
    suma integer default 0;
    resultado integer default 0;
begin 
    if num1 < 0 or num2 < 0 then 
        dbms_output.put_line('Número no soportado. Solo números positivos.');
    else 
        for i in num1..num2 loop 
            if mod(i, 2) <> 0 then 
                resultado := suma + i;
                dbms_output.put_line(chr(9) || suma || ' + ' || i || ' = ' || resultado);
                suma := suma + i;
            end if;        
        end loop;
    end if;
end;

execute suma_impares(-3, 9);
/*Número no soportado. Solo números positivos.
Procedimiento PL/SQL terminado correctamente.*/

execute suma_impares(2, 15);
/*  0 + 3 = 3
	3 + 5 = 8
	8 + 7 = 15
	15 + 9 = 24
	24 + 11 = 35
	35 + 13 = 48
	48 + 15 = 63
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*16. Diseñar un procedimiento que recibe por parámetros dos valores numéricos
que representan la base y el exponente de una potencia donde el exponente es un
número entero positivo o negativo. El procedimiento visualiza el valor de la potencia,
teniendo en cuenta las siguientes consideraciones:
    - Si la base y el exponente son cero, se mostrará un mensaje de error que diga
        "Datos erróneos".
    - Si el exponente es cero la potencia es 1.
    - Si el exponente es negativo la fórmula matemática de la potencia es pot =
        1/base^exp. En este caso, si la base es cero escribir un mensaje de "Datos
        erróneos".
    - Nota: No utilizar ninguna función que calcule la potencia.*/
create or replace procedure potencia(
    base number, 
    exponente number)
as 
    resultado float default 1;
begin   
    if base = 0 and exponente = 0 then 
        dbms_output.put_line('Datos erróneos.');
    elsif exponente = 0 then 
        dbms_output.put_line(base || '^' || exponente || ' = ' || 1);
    elsif base = 0 and exponente < 0 then 
        dbms_output.put_line('Datos erróneos.');
    elsif exponente < 0 then 
        for i in 1..abs(exponente) loop 
            resultado := resultado * base;
        end loop;
        resultado := 1 / resultado;

        dbms_output.put_line(1 || '/' || base || '^' || exponente || ' = ' || resultado);
    else 
        for i in 1..exponente loop 
            resultado := resultado * base;
        end loop;

        dbms_output.put_line(base || '^' || exponente || ' = ' || resultado);
    end if;
end;

execute potencia(5, 4);
/*5^4 = 625
Procedimiento PL/SQL terminado correctamente.*/

execute potencia(0, 0);
/*Datos erróneos.
Procedimiento PL/SQL terminado correctamente*/

execute potencia(5, 0);
/*5^0 = 1
Procedimiento PL/SQL terminado correctamente.*/

execute potencia(5, -2);
/*1/5^-2 = ,04
Procedimiento PL/SQL terminado correctamente.*/

execute potencia(0, -2);
/*Datos erróneos.
Procedimiento PL/SQL terminado correctamente.*/

----------------------------------------------------------------------------------

/*17. Cree una tabla Tabla_Numeros con un atributo valor de tipo NUMBER.
Cree un procedimientoque inserte números del 1 al 50. Compruebe los datos
insertados en la tabla Tabla_Numeros.*/
create table Tabla_Numeros(
    valor number
);

create or replace procedure inserta_numeros
as 
begin 
    for i in 1..50 loop
        insert into Tabla_Numeros
            values(i);
    end loop;
end;

execute inserta_numeros;

select * from Tabla_Numeros;
/* VALOR
----------
         1
         2
         3
         4
         5
         6
         7
         8
         9
        10
        11
        12
        13
        14
        15
        16
        17
        18
        19
        20
        21
        22
        23
        24
        25
        26
        27
        28
        29
        30
        31
        32
        33
        34
        35
        36
        37
        38
        39
        40
        41
        42
        43
        44
        45
        46
        47
        48
        49
        50
50 filas seleccionadas.*/

----------------------------------------------------------------------------------

/*18. Borre el contenido de la tabla Tabla_Numeros utilizando la sentencia
DELETE. Cree un procedimiento que inserte del 10 al 1, excepto el 4 y el 5.
Compruebe, de nuevo, los datos que contiene la tabla Tabla_Numeros.*/
delete from Tabla_Numeros;

create or replace procedure insertar1_10
as 
begin 
    for i in reverse 1..10 loop
        if i <> 4 and i <> 5 then
            insert into Tabla_Numeros
                values(i);
        end if;
    end loop;
end;

execute insertar1_10;

select * from Tabla_Numeros;
/*     VALOR
----------
        10
         9
         8
         7
         6
         3
         2
         1*/

----------------------------------------------------------------------------------

/*19. Cree una tabla Tabla_Articulos con los siguientes atributos: código,nombre,
precio e IVA. Introduzca datos de prueba utilizando la sentencia INSERT.
    CREATE TABLE Tabla_Articulos
        (codigo VARCHAR(5) PRIMARY KEY,
        nombre VARCHAR(20),
        precio NUMBER,
        IVA NUMBER);*/
insert into Tabla_Articulos 
    values('A001', 'Camiseta', 19.95, 0.21);
insert into Tabla_Articulos 
    values('A002', 'Blusa', 27.35, 0.21);
insert into Tabla_Articulos 
    values('A003', 'Pantalón', 52.13, 0.21);
insert into Tabla_Articulos 
    values('A004', 'Pajarita', 12, 0.21);
insert into Tabla_Articulos 
    values('A005', 'Bolso', 45.60, 0.21);
insert into Tabla_Articulos 
    values('A006', 'Pendientes', 20, 0.21);
insert into Tabla_Articulos 
    values('A007', 'Chaqueta', 70.80, 0.21);

select * from Tabla_Articulos;
/*CODIG NOMBRE                 PRECIO        IVA
----- -------------------- ---------- ----------
A001  Camiseta                  19,95        ,21
A002  Blusa                     27,35        ,21
A003  Pantalón                  52,13        ,21
A004  Pajarita                     12        ,21
A005  Bolso                      45,6        ,21
A006  Pendientes                   20        ,21
A007  Chaqueta                   70,8        ,21*/

/*a)Construya un procedimiento que compruebe si el precio del artículo cuyo código es
‘A001’ es mayor que 10 euros y en caso afirmativo, imprima el nombre y el precio del
artículo por pantalla.*/
create or replace procedure precio_mayor10
as 
    v_precio Tabla_Articulos.precio%type;
    v_nombre Tabla_Articulos.nombre%type;
begin 
    select precio, nombre into v_precio, v_nombre from Tabla_Articulos
        where codigo = 'A001';

    if v_precio > 10 then 
        dbms_output.put_line(v_nombre || ' - ' || v_precio || '€.');
    else 
        dbms_output.put_line('Precio del artículo menor a 10€.');
    end if;
end;

execute precio_mayor10;
/*Camiseta - 19,95€.
Procedimiento PL/SQL terminado correctamente.*/

update Tabla_Articulos set precio = 9.95 
    where codigo = 'A001';

execute precio_mayor10;
/*Precio del artículo menor a 10€.
Procedimiento PL/SQL terminado correctamente.*/

/*b)Construya un procedimiento que seleccione el artículo de mayor precio que esté
almacenado en la tabla, almacene su valor en una variable y luego imprímalo.*/
create or replace procedure precio_mayor 
as 
    v_precio Tabla_Articulos.precio%type;
    v_nombre Tabla_Articulos.nombre%type;
    v_codigo Tabla_Articulos.codigo%type;
begin 
    select max(precio) precio into v_precio from Tabla_Articulos;
        
    select nombre, codigo into v_nombre, v_codigo from Tabla_Articulos
        where precio = v_precio;

    dbms_output.put_line(v_codigo || ' - ' || v_nombre || ' - ' || v_precio || '€.');
end;

execute precio_mayor;
/*A007 - Chaqueta - 70,8€.
Procedimiento PL/SQL terminado correctamente.*/

/*c)Construya un procedimiento que actualice el precio del artículo cuyo código es
‘A005’ según las siguientes indicaciones:
−Si el artículo tiene un precio menor de 1 euro, su precio debe ser aumentado en
25 céntimos.
−Si está comprendido entre 1 euro y 10 euros su precio aumentará un 10
% .Si excede los 10 euros su precio aumentará en un 20 %.
− Si el precio es NULL, el aumento es 0.*/
create or replace procedure actualiza_precio
as 
    v_precio Tabla_Articulos.precio%type;
begin 
    select precio into v_precio from Tabla_Articulos 
        where codigo = 'A005';
    
    if v_precio < 1 then 
        update Tabla_Articulos set precio = precio + 0.25 
            where codigo = 'A005';
    elsif v_precio > 1 and v_precio < 10 then 
        update Tabla_Articulos set precio = precio * 1.10
            where codigo = 'A005';
    elsif v_precio > 10 then 
        update Tabla_Articulos set precio = precio * 1.20
            where codigo = 'A005';
    else 
        update Tabla_Articulos set precio = 0
            where codigo = 'A005';
    end if;
end;

-- Mayor de 10.
select * from tabla_articulos where codigo = 'A005';
/*CODIG NOMBRE                 PRECIO        IVA
----- -------------------- ---------- ----------
A005  Bolso                      45,6        ,21*/
execute actualiza_precio;
/*CODIG NOMBRE                 PRECIO        IVA
----- -------------------- ---------- ----------
A005  Bolso                     54,72        ,21*/

-- Null
update Tabla_Articulos set precio = null 
    where codigo = 'A005';
/*CODIG NOMBRE                   PRECIO        IVA
----- -------------------- ---------- ----------
A005  Bolso                                  ,21*/
execute actualiza_precio;
/*CODIG NOMBRE                 PRECIO        IVA
----- -------------------- ---------- ----------
A005  Bolso                         0        ,21*/

--El precio ahora es 0, menor que 1 por tanto, ejecuto de nuevo sin modificar nada.
execute actualiza_precio;
/*ODIG NOMBRE                 PRECIO        IVA
----- -------------------- ---------- ----------
A005  Bolso                       ,25        ,21*/

-- Entre 1 y 10.
update Tabla_Articulos set precio = 2 
    where codigo = 'A005';
/*CODIG NOMBRE                 PRECIO        IVA
----- -------------------- ---------- ----------
A005  Bolso                         2        ,21*/
execute actualiza_precio;
/*CODIG NOMBRE                   PRECIO        IVA
----- -------------------- ---------- ----------
A005  Bolso                       2,2        ,21*/

/*d) Construya un procedimiento similar al del apartado c donde el usuario
introduzca como parámetro el código del artículo que desee modificar su
precio.*/
create or replace procedure actualiza_precio(cod Tabla_Articulos.codigo%type)
as 
    v_precio Tabla_Articulos.precio%type;
begin 
    select precio into v_precio from Tabla_Articulos 
        where codigo = cod;
    
    if v_precio < 1 then 
        update Tabla_Articulos set precio = precio + 0.25 
            where codigo = cod;
    elsif v_precio > 1 and v_precio < 10 then 
        update Tabla_Articulos set precio = precio * 1.10
            where codigo = cod;
    elsif v_precio > 10 then 
        update Tabla_Articulos set precio = precio * 1.20
            where codigo = cod;
    else 
        update Tabla_Articulos set precio = 0
            where codigo = cod;
    end if;
end;

execute actualiza_precio('A004');

----------------------------------------------------------------------------------

/*20. Crear un procedimiento que en la tabla emp incremente el salario el 3% a
los empleados que tengan una comisión superior al 5% del salario.*/
create or replace procedure incrementa_salario
as 
begin 
    update emple set salario = salario * 1.03
        where salario * 0.05 < nvl(comision, 0);
end;

execute incrementa_salario;

----------------------------------------------------------------------------------

/*21. Crear un procedimiento que inserte un empleado en la tabla EMP. Su número
será superior a los existentes y la fecha de incorporación a la empresa será la
actual.*/
create or replace procedure inserta_emple
as 
    v_emp_no emple.emp_no%type;
begin
    select max(emp_no) into v_emp_no from emple;

    insert into emple (emp_no, apellido, fecha_alt, dept_no)
        values(v_emp_no + 1, 'TENA', sysdate, 10);
end;

execute inserta_emple;
--Número de departamento insertado porque en la tabla emple no puede ser null.

----------------------------------------------------------------------------------