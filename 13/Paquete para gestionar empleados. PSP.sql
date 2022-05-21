/*Escribir un paquete completo para gestionar los empleados.

El paquete se llamará gest_emple e incluirá, al menos los siguientes subprogramas:

-insertar_nuevo_emple
-borrar_emple: Cuando se borra un empleado todos los empleados que
dependían de él pasarán a depender del director del empleado borrado.
-modificar_oficio_emple
-modificar_dept_emple
-modificar_dir_emple
-modificar_salario_emple
-modificar_comision_emple
-visualizar_datos_emple: También se incluirá una versión sobrecargada del
procedimiento que recibirá el apellido del empleado.
-buscar_emple_por_apellido. Función local que recibe el apellido y devuelve
el número.

Todos los procedimientos recibirán el número del empleado seguido de los demás
datos necesarios.
También se incluirá en el paquete un cursor, que será utilizado en los
siguientes procedimientos que afectarán a todos los empleados:

-subida_salario_pct: incrementará el salario de todos los empleados el
porcentaje indicado en la llamada que no podrá ser superior al 25%.
-subida_salario_imp: sumará al salario de todos los empleados el importe
indicado en la llamada. Antes de proceder a incrementar los salarios se
comprobará que el importe indicado no supera el 25% del salario medio.*/