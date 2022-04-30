REM ############### SCRIPT CREACION TABLAS DE EJEMPLO ###################

REM ######################################################################
REM                        DEPART Y EMPLE 
REM ######################################################################

REM ### ELIMINACIÓN TABLA DEPART ANTIGUA (SI EXISTE)

DROP TABLE DEPART cascade constraints;

REM ### CREACIÓN TABLA DEPART

CREATE TABLE DEPART (
 DEPT_NO  NUMBER(2) NOT NULL,
 DNOMBRE  VARCHAR2(14), 
 LOC      VARCHAR2(14), 
CONSTRAINT PK_DEPT_NO PRIMARY KEY (DEPT_NO)
);


REM ### ELIMINACIÓN TABLA EMPLE ANTIGUA (SI EXISTE)

DROP TABLE EMPLE cascade constraints; 

REM ### CREACIÓN TABLA EMPLE

CREATE TABLE EMPLE (
 EMP_NO    NUMBER(4) NOT NULL,
 APELLIDO  VARCHAR2(10),
 OFICIO    VARCHAR2(10),
 DIR       NUMBER(4) ,
 FECHA_ALT DATE      ,
 SALARIO   NUMBER(10),
 COMISION  NUMBER(10),
 DEPT_NO   NUMBER(2) NOT NULL,
CONSTRAINT PK_EMP_NO PRIMARY KEY (EMP_NO)
);


REM ## INSERCIÓN DE FILAS EN LA TABLA DEPART

INSERT INTO DEPART VALUES (10,'CONTABILIDAD','SEVILLA');
INSERT INTO DEPART VALUES (20,'INVESTIGACION','MADRID');
INSERT INTO DEPART VALUES (30,'VENTAS','BARCELONA');
INSERT INTO DEPART VALUES (40,'PRODUCCION','BILBAO');
COMMIT;


REM ## INSERCIÓN DE FILAS EN LA TABLA EMPLE

INSERT INTO EMPLE VALUES (7369,'SANCHEZ','EMPLEADO',7902,'17/12/1980',104000,NULL,20);                            
INSERT INTO EMPLE VALUES (7499,'ARROYO','VENDEDOR',7698,'20/02/1980', 208000,39000,30);
INSERT INTO EMPLE VALUES (7521,'SALA','VENDEDOR',7698,'22/02/1981', 162500,65000,30);
INSERT INTO EMPLE VALUES (7566,'JIMENEZ','DIRECTOR',7839,'02/04/1981', 386750,NULL,20);
INSERT INTO EMPLE VALUES (7654,'MARTIN','VENDEDOR',7698,'29/09/1981', 162500,182000,30);
INSERT INTO EMPLE VALUES (7698,'NEGRO','DIRECTOR',7839,'01/05/1981', 370500,NULL,30);
INSERT INTO EMPLE VALUES (7782,'CEREZO','DIRECTOR',7839,'09/06/1981', 318500,NULL,10);
INSERT INTO EMPLE VALUES (7788,'GIL','ANALISTA',7566,'09/11/1981', 390000,NULL,20);
INSERT INTO EMPLE VALUES (7839,'REY','PRESIDENTE',NULL,'17/11/1981', 650000,NULL,10);
INSERT INTO EMPLE VALUES (7844,'TOVAR','VENDEDOR',7698,'08/09/1981', 195000,0,30);
INSERT INTO EMPLE VALUES (7876,'ALONSO','EMPLEADO',7788,'23/09/1981', 143000,NULL,20);
INSERT INTO EMPLE VALUES (7900,'JIMENO','EMPLEADO',7698,'03/12/1981', 123500,NULL,30);
INSERT INTO EMPLE VALUES (7902,'FERNANDEZ','ANALISTA',7566,'03/12/1981',390000, NULL,20);                       
INSERT INTO EMPLE VALUES (7934,'MUÑOZ','EMPLEADO',7782,'23/01/1982', 169000,NULL,10);                      
COMMIT;


REM ############################################################################
REM                       CLIENTES, PRODUCTOS Y VENTAS
REM ############################################################################


REM ### ELIMINACIÓN TABLA CLIENTES ANTIGUA (SI EXISTE).

DROP TABLE clientes CASCADE CONSTRAINTS;

REM ### CREACIÓN TABLA CLIENTES

CREATE TABLE clientes
	(nif		VARCHAR2(10) NOT NULL,
	nombre		VARCHAR2(15) NOT NULL,
	domicilio	VARCHAR2(15),
     CONSTRAINT pk_clientes
	PRIMARY KEY (nif)
	);


REM ### ELIMINACIÓN TABLA PRODUCTOS ANTIGUA (SI EXISTE).

DROP TABLE productos CASCADE CONSTRAINTS;

REM ### CREACIÓN TABLA PRODUCTOS


CREATE TABLE productos
	(cod_producto	NUMBER(4) 	NOT NULL,
	descripcion	VARCHAR2(15) 	NOT NULL,
	linea_producto	VARCHAR2(6) 	NOT NULL,
 	precio_uni	NUMBER(6) 	NOT NULL,
	stock		NUMBER(5)	NOT NULL,	
  CONSTRAINT pk_productos	
	PRIMARY KEY (cod_producto),
  CONSTRAINT ck_precio
	CHECK (precio_uni > 0)	
	);

REM ### ELIMINACIÓN TABLA VENTAS ANTIGUA (SI EXISTE).

DROP TABLE ventas CASCADE CONSTRAINTS;

REM ### CREACIÓN TABLA VENTAS


CREATE TABLE ventas
	(nif		VARCHAR2(10) NOT NULL,
	cod_producto	NUMBER(4)	NOT NULL,
	fecha		DATE		NOT NULL,
	unidades	NUMBER(3)	DEFAULT 1 NOT NULL,
    CONSTRAINT pk_ventas
	PRIMARY KEY (nif, cod_producto, fecha),
    CONSTRAINT fk_ventas_cliente
	FOREIGN KEY (nif)
	REFERENCES Clientes(nif) 
	ON DELETE CASCADE,
    CONSTRAINT fk_ventas_producto
	FOREIGN KEY (cod_producto)
	REFERENCES Productos(cod_producto)
	ON DELETE CASCADE,
    CONSTRAINT ck_unidades
	CHECK (unidades > 0)
	);


REM ### INSERCIÓN DE FILAS EN LA TABLA  Productos

insert into Productos values(1, 'PROCESADOR P133', 'PROCES', 15000, 0);
insert into Productos values(2, 'PLACA BASE VX', 'PB', 10000, 0);
insert into Productos values(3, 'SIMM EDO 16MB', 'MEM', 7000, 0);
insert into Productos values(4, 'DISCO SCSI 4MB', 'DISCOS', 40000, 0);  
insert into Productos values(5, 'PROCESADOR K6', 'PROCES', 20000, 0);
insert into Productos values(6, 'DISCO IDE 2.5MB', 'DISCOS', 25000, 0);
insert into Productos values(7, 'PROCESADOR MMX', 'PROCES', 20000, 0);
insert into Productos values(8, 'PLACA BASE ATLA', 'PB', 50000, 0);
insert into Productos values(9, 'DIMM SDRAM 32MB', 'MEM', 22000, 0);
COMMIT;


REM ### INSERCIÓN DE FILAS EN LA TABLA Clientes

insert into Clientes values('111A', 'ANDRES', 'POZUELO' ); 
insert into Clientes values('222B', 'JAIME', 'ARAVACA'); 
insert into Clientes values('333C', 'TERESA', 'LAS ROZAS'); 
insert into Clientes values('444D', 'VICENTE', 'MADRID');
insert into Clientes values('555E', 'SANDRA', 'MADRID');
insert into Clientes values('666F', 'ALBERTO', 'POZUELO');
insert into Clientes values('777G', 'MIGUEL', 'POZUELO');
insert into Clientes values('888H', 'MARINA','ARAVACA');
insert into Clientes values('999I', 'ANTONIO', 'LAS ROZAS');
COMMIT;


REM ### INSERCIÓN DE FILAS EN LA TABLA  Ventas

insert into Ventas values('333C', 2, '22/09/1997', 2);
insert into Ventas values('888H', 4, '22/09/1997', 1);
insert into Ventas values('555E', 6, '23/09/1997', 3);
insert into Ventas values('222B', 5, '26/09/1997', 5);
insert into Ventas values('111A', 9, '28/09/1997', 3);
insert into Ventas values('222B', 4, '28/09/1997', 1);
insert into Ventas values('444D', 6, '02/10/1997', 2);
insert into Ventas values('555E', 6, '02/10/1997', 1);
insert into Ventas values('888H', 2, '04/10/1997', 4);
insert into Ventas values('333C', 9, '04/10/1997', 4);
insert into Ventas values('222B', 6, '05/10/1997', 2);
insert into Ventas values('666F', 7, '07/10/1997', 1);
insert into Ventas values('555E', 4, '10/10/1997', 3);
insert into Ventas values('222B', 4, '16/10/1997', 2);
insert into Ventas values('111A', 3, '18/10/1997', 3);
insert into Ventas values('222B', 4, '18/10/1997', 5);
insert into Ventas values('444D', 6, '22/10/1997', 2);
insert into Ventas values('555E', 6, '02/11/1997', 2);
insert into Ventas values('888H', 2, '04/11/1997', 3);
insert into Ventas values('333C', 9, '04/12/1997', 3);
insert into Ventas values('222B', 2, '05/12/1997', 2);
COMMIT;


REM ########################### FIN DEL SCRIPT #########################


