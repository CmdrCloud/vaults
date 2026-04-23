# Listado de Requerimientos y Documentacion

## Requerimientos

1. Menu de Productos
2. Carrito
3. Generacion de facturacion
4. Pagos

## Documentacion

1. Agregar tabla de cuentas de administradores en la base de datos con datos username, password. (hecho)
2. Agregar un boton en activity_login para que el administrador pueda hacer login. Al dar click en el boton, debe aparecer dos campos de texto, uno para el nombre de usuario del administrador, y otro para la clave del administrador.
3. Agregar un nombre de usuario y password para el administrador en la BD, "admin" y "cl4v3"
4. Crear activity_menuproductos para el cliente.
5. Crear activity_carrito para el cliente.
6. Crear activity_pago para el cliente.
7. En activity_login, redirigir el cliente a activity_menuproductos en vez de el que esta ahora configurado que es para el administrador.
8. En activity_menuproductos, agregar un buscador de productos en la parte de arriba de la pantalla, y abajo del buscador, agregar un area que muestra un listado de productos con el nombre y precio de los productos. Adicionalmente, permitir que se puede hacer scroll si hay muchos productos en este area.
9. Despues de agregar el area de los productos disponibles en activity_menuproductos, permitir que el cliente pueda seleccionar uno o muchos productos. Siguiente, agregar un boton "+" para que el cliente pueda agregar los productos seleccionados a su carrito. Al dar click en el boton "+", debe mostrar mensaje de exito de agregar productos al carrito. En caso de que el cliente no selecciono ningun producto, al dar click en el "+", mostrar mensaje de "no hay productos seleccionados."
10. Una vez agregado el boton "+", agregar otro boton para que el cliente pueda ver su carrito.
11. Si el usuario le da click al boton de carrito, redirigirlo al activity_carrito.
12. En activity_carrito, agregar un titulo que dice "Carrito", agregar un boton que dice "volver" para que el cliente pueda volver a activity_menuproductos, y agregar un listado de los productos que el cliente selecciono con los detalles del nombre de producto, cantidad de productos seleccionados con dos botones a la derecha del numero de cantidad para que el usuario pueda ajustar la cantidad de productos "ej. + 1x -", y el precio del producto. Abajo de la lista de los productos seleccionados, mostrar un subtotal del costo de los productos. Finalmente, agregar un boton abajo de todo para pagar.
13. Al dar click en pagar en activity_carrito, el cliente se redirige al activity_pago.
14. Crear una tabla en la base de datos para el registro del pago (venta).
15. En activity_pago, agregar un titulo "Ultimo paso", agregar un boton "Volver" a la derecha de ese titulo que permite al cliente volver a su carrito, y agregar un titulo (SOLO TEXTO, QUE NO TENGA FUNCIONALIDAD) que dice "$ Efectivo", siguiente agregar un area que muestra la lista de los productos que el cliente escogio con los nombres de los productos, sus cantidades, y sus precios. Abajo de ese area, mostrar un subtotal del costo de los productos, tarifa de servicio (2Bs. por producto), y el total de todos los costos (tarifa + costo de productos). A la derecha de el total de los productos, agregar un boton "Pagar" que finaliza el pago (PERO NO TIENE FUNCIONALIDAD DE PAGO) que solamente termina (finish o finishaffinity, lo que sea mas apropiado) esa pagina y devuelve el cliente al activity_menuproductos. Finalmente, registrar la venta en la base de datos.
16. Verificar si el administrador todavia tiene acceso a administrar los productos y categorias.
17. Verificar que los productos que agrega el administrador los puede ver el cliente.
18. En activity_menu_productos, agregar un boton que permite volver a activity_login, para que funciona como un logout.
19. Acomodar la barra de arriba en activity_menu_productos que dice "LabInventario" y en otras activities.xml para que se acomode con el contenido de los activities ya que ahora se ven overlapped.
20. No mostrar stock en actividad_menu_productos, ya que al cliente no le interesa si hay en stock ese producto. 