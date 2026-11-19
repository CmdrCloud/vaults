/* =========================================================================
   Cinco procedimientos almacenados con buscador (base de datos ledger)

   Cada procedimiento usa INNER JOIN entre tablas del proyecto y recibe un
   texto de búsqueda (@buscar). Devuelve las filas que contienen ese texto.
   Si @buscar es NULL o vacío, devuelve todas las filas.
   Los montos se guardan en centavos; las columnas *_bs los muestran en Bs.

   Se puede ejecutar varias veces (CREATE OR ALTER).
   ========================================================================= */

USE ledger;
GO

/* 1. Gastos compartidos: SharedExpense + Expense + ExpenseCategory
      + Agreement + Person (inquilino). Busca por descripción, categoría
      o nombre del inquilino. */
CREATE OR ALTER PROCEDURE dbo.buscar_gasto_compartido
    @buscar NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        e.id_expense,
        e.[date] AS fecha,
        e.description AS descripcion,
        c.name AS categoria,
        p.name AS inquilino,
        CAST(e.amount / 100.0 AS DECIMAL(18,2)) AS monto_bs,
        CAST(s.tenant_amount / 100.0 AS DECIMAL(18,2)) AS monto_inquilino_bs,
        s.repaid_date AS fecha_pagado
    FROM dbo.SharedExpense s
    INNER JOIN dbo.Expense e ON e.id_expense = s.id_expense
    INNER JOIN dbo.ExpenseCategory c ON c.id_category = e.id_category
    INNER JOIN dbo.Agreement a ON a.id_agreement = s.id_agreement
    INNER JOIN dbo.Person p ON p.id_person = a.id_tenant
    WHERE ISNULL(@buscar, N'') = N''
       OR e.description LIKE N'%' + @buscar + N'%'
       OR c.name LIKE N'%' + @buscar + N'%'
       OR p.name LIKE N'%' + @buscar + N'%'
    ORDER BY e.[date];
END;
GO

/* 2. Gastos pagados: PaidExpense + Expense + ExpenseCategory.
      Busca por descripción, categoría o referencia de pago. */
CREATE OR ALTER PROCEDURE dbo.buscar_gasto_pagado
    @buscar NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        e.id_expense,
        e.[date] AS fecha,
        e.description AS descripcion,
        c.name AS categoria,
        pe.payment_reference AS referencia,
        CAST(e.amount / 100.0 AS DECIMAL(18,2)) AS monto_bs
    FROM dbo.PaidExpense pe
    INNER JOIN dbo.Expense e ON e.id_expense = pe.id_expense
    INNER JOIN dbo.ExpenseCategory c ON c.id_category = e.id_category
    WHERE ISNULL(@buscar, N'') = N''
       OR e.description LIKE N'%' + @buscar + N'%'
       OR c.name LIKE N'%' + @buscar + N'%'
       OR pe.payment_reference LIKE N'%' + @buscar + N'%'
    ORDER BY e.[date];
END;
GO

/* 3. Inquilinos y sus acuerdos: Tenant + Person + Agreement.
      Busca por nombre o número de documento del inquilino. */
CREATE OR ALTER PROCEDURE dbo.buscar_inquilino
    @buscar NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.id_person AS id_inquilino,
        p.name AS inquilino,
        p.phone AS telefono,
        t.document_number AS documento,
        a.tenant_percentage AS porcentaje,
        a.start_date AS inicio,
        a.end_date AS fin
    FROM dbo.Tenant t
    INNER JOIN dbo.Person p ON p.id_person = t.id_person
    INNER JOIN dbo.Agreement a ON a.id_tenant = t.id_person
    WHERE ISNULL(@buscar, N'') = N''
       OR p.name LIKE N'%' + @buscar + N'%'
       OR t.document_number LIKE N'%' + @buscar + N'%'
    ORDER BY p.name;
END;
GO

/* 4. Miembros de cada propiedad: PropertyMember + Property + Person.
      Busca por nombre de la propiedad, dirección, persona o relación. */
CREATE OR ALTER PROCEDURE dbo.buscar_miembro_propiedad
    @buscar NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        pr.name AS propiedad,
        pr.address AS direccion,
        p.name AS persona,
        pm.relationship AS relacion,
        pm.move_in_date AS fecha_ingreso
    FROM dbo.PropertyMember pm
    INNER JOIN dbo.Property pr ON pr.id_property = pm.id_property
    INNER JOIN dbo.Person p ON p.id_person = pm.id_person
    WHERE ISNULL(@buscar, N'') = N''
       OR pr.name LIKE N'%' + @buscar + N'%'
       OR pr.address LIKE N'%' + @buscar + N'%'
       OR p.name LIKE N'%' + @buscar + N'%'
       OR pm.relationship LIKE N'%' + @buscar + N'%'
    ORDER BY pr.name, p.name;
END;
GO

/* 5. Presupuesto por categoría: BudgetCategory + Budget + ExpenseCategory
      + Person (usuario). Busca por categoría o nombre del usuario. */
CREATE OR ALTER PROCEDURE dbo.buscar_presupuesto_categoria
    @buscar NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        b.id_budget,
        p.name AS usuario,
        b.[year] AS anio,
        b.[month] AS mes,
        c.name AS categoria,
        CAST(bc.amount / 100.0 AS DECIMAL(18,2)) AS presupuestado_bs
    FROM dbo.BudgetCategory bc
    INNER JOIN dbo.Budget b ON b.id_budget = bc.id_budget
    INNER JOIN dbo.ExpenseCategory c ON c.id_category = bc.id_category
    INNER JOIN dbo.Person p ON p.id_person = b.id_user
    WHERE ISNULL(@buscar, N'') = N''
       OR c.name LIKE N'%' + @buscar + N'%'
       OR p.name LIKE N'%' + @buscar + N'%'
    ORDER BY b.[year], b.[month], c.name;
END;
GO

/* Pruebas */
EXEC dbo.buscar_gasto_compartido @buscar = N'Carlos';
EXEC dbo.buscar_gasto_pagado @buscar = N'shop';
EXEC dbo.buscar_inquilino @buscar = N'SEED';
EXEC dbo.buscar_miembro_propiedad @buscar = N'Family';
EXEC dbo.buscar_presupuesto_categoria @buscar = N'Groc';
GO
