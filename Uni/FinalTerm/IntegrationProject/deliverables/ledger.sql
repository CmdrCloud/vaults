/* =========================================================================
   Ledger database (SQL Server): schema, constraints, seed data, demo queries.

   Idempotent and non-destructive: safe to run repeatedly. Existing tables and
   rows are kept. Views, procedures and triggers are refreshed on every run.
   Money is BIGINT centavos of BOB (150000 = Bs 1,500.00).

   Design rules
   - An attribute lives in exactly one place. What every expense has
     (user, date, amount, description, category) is in Expense; the subclass
     tables hold only what is specific to them.
   - Nothing derivable is stored. Totals and balances come from views, and an
     income belongs to the budget of its user and month, so it needs no
     id_budget column.
   - NVARCHAR only for human-language text (names, addresses, descriptions).
     Codes, e-mail, phone numbers and hashes are VARCHAR.
   - created_at on every table except SharedExpense and PaidExpense, which
     are always created together with their Expense row.

   Run from a terminal:
     sqlcmd -S 127.0.0.1,1433 -U sa -C -I -b -i ledger.sql
   Or in DBeaver: open the file and run the whole script (Option+X).
   ========================================================================= */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;   -- required by the filtered indexes
GO

IF DB_ID(N'ledger') IS NULL
    CREATE DATABASE ledger;
GO

USE ledger;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================================
   Tables
   ========================================================================= */

IF OBJECT_ID(N'dbo.Person', N'U') IS NULL
CREATE TABLE dbo.Person (
    id_person   INT IDENTITY(1,1) NOT NULL,
    name        NVARCHAR(100) NOT NULL,
    phone       VARCHAR(20) NULL,
    created_at  DATETIME2 NOT NULL CONSTRAINT DF_Person_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Person PRIMARY KEY (id_person)
);

IF OBJECT_ID(N'dbo.AppUser', N'U') IS NULL
CREATE TABLE dbo.AppUser (
    id_person     INT NOT NULL,
    email         VARCHAR(254) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at    DATETIME2 NOT NULL CONSTRAINT DF_AppUser_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AppUser PRIMARY KEY (id_person),
    CONSTRAINT UQ_AppUser_email UNIQUE (email),
    CONSTRAINT FK_AppUser_Person FOREIGN KEY (id_person)
        REFERENCES dbo.Person (id_person) ON DELETE NO ACTION
);

IF OBJECT_ID(N'dbo.Tenant', N'U') IS NULL
CREATE TABLE dbo.Tenant (
    id_person       INT NOT NULL,
    document_number VARCHAR(20) NULL,   -- unique when present: see UX_Tenant_document_number
    created_at      DATETIME2 NOT NULL CONSTRAINT DF_Tenant_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Tenant PRIMARY KEY (id_person),
    CONSTRAINT FK_Tenant_Person FOREIGN KEY (id_person)
        REFERENCES dbo.Person (id_person) ON DELETE NO ACTION
);

IF OBJECT_ID(N'dbo.Property', N'U') IS NULL
CREATE TABLE dbo.Property (
    id_property INT IDENTITY(1,1) NOT NULL,
    name        NVARCHAR(100) NOT NULL,
    address     NVARCHAR(255) NULL,
    created_at  DATETIME2 NOT NULL CONSTRAINT DF_Property_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Property PRIMARY KEY (id_property)
);

IF OBJECT_ID(N'dbo.PropertyMember', N'U') IS NULL
CREATE TABLE dbo.PropertyMember (
    id_property  INT NOT NULL,
    id_person    INT NOT NULL,
    relationship NVARCHAR(30) NOT NULL,
    move_in_date DATE NULL,
    created_at   DATETIME2 NOT NULL CONSTRAINT DF_PropertyMember_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PropertyMember PRIMARY KEY (id_property, id_person),
    CONSTRAINT FK_PropertyMember_Property FOREIGN KEY (id_property)
        REFERENCES dbo.Property (id_property) ON DELETE CASCADE,
    CONSTRAINT FK_PropertyMember_Person FOREIGN KEY (id_person)
        REFERENCES dbo.Person (id_person) ON DELETE NO ACTION
);

IF OBJECT_ID(N'dbo.Agreement', N'U') IS NULL
CREATE TABLE dbo.Agreement (
    id_agreement      INT IDENTITY(1,1) NOT NULL,
    id_user           INT NOT NULL,
    id_tenant         INT NOT NULL,
    tenant_percentage DECIMAL(5,2) NOT NULL,
    start_date        DATE NOT NULL,
    end_date          DATE NULL,
    created_at        DATETIME2 NOT NULL CONSTRAINT DF_Agreement_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Agreement PRIMARY KEY (id_agreement),
    CONSTRAINT FK_Agreement_AppUser FOREIGN KEY (id_user)
        REFERENCES dbo.AppUser (id_person) ON DELETE NO ACTION,
    CONSTRAINT FK_Agreement_Tenant FOREIGN KEY (id_tenant)
        REFERENCES dbo.Tenant (id_person) ON DELETE NO ACTION,
    CONSTRAINT CK_Agreement_tenant_percentage CHECK (tenant_percentage BETWEEN 0 AND 100),
    CONSTRAINT CK_Agreement_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT CK_Agreement_two_people CHECK (id_user <> id_tenant)
);

IF OBJECT_ID(N'dbo.ExpenseCategory', N'U') IS NULL
CREATE TABLE dbo.ExpenseCategory (
    id_category INT IDENTITY(1,1) NOT NULL,
    name        NVARCHAR(60) NOT NULL,
    created_at  DATETIME2 NOT NULL CONSTRAINT DF_ExpenseCategory_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ExpenseCategory PRIMARY KEY (id_category),
    CONSTRAINT UQ_ExpenseCategory_name UNIQUE (name)
);

IF OBJECT_ID(N'dbo.Expense', N'U') IS NULL
CREATE TABLE dbo.Expense (
    id_expense  INT IDENTITY(1,1) NOT NULL,
    id_user     INT NOT NULL,
    id_category INT NOT NULL,
    [date]      DATE NOT NULL,
    amount      BIGINT NOT NULL,
    description NVARCHAR(255) NULL,
    created_at  DATETIME2 NOT NULL CONSTRAINT DF_Expense_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Expense PRIMARY KEY (id_expense),
    CONSTRAINT FK_Expense_AppUser FOREIGN KEY (id_user)
        REFERENCES dbo.AppUser (id_person) ON DELETE NO ACTION,
    CONSTRAINT FK_Expense_ExpenseCategory FOREIGN KEY (id_category)
        REFERENCES dbo.ExpenseCategory (id_category) ON DELETE NO ACTION,
    CONSTRAINT CK_Expense_amount CHECK (amount > 0)
);

IF OBJECT_ID(N'dbo.SharedExpense', N'U') IS NULL
CREATE TABLE dbo.SharedExpense (
    id_expense    INT NOT NULL,
    id_agreement  INT NOT NULL,
    tenant_amount BIGINT NOT NULL,   -- the tenant's share, fixed when the expense is recorded
    repaid_date   DATE NULL,
    CONSTRAINT PK_SharedExpense PRIMARY KEY (id_expense),
    CONSTRAINT FK_SharedExpense_Expense FOREIGN KEY (id_expense)
        REFERENCES dbo.Expense (id_expense) ON DELETE NO ACTION,
    CONSTRAINT FK_SharedExpense_Agreement FOREIGN KEY (id_agreement)
        REFERENCES dbo.Agreement (id_agreement) ON DELETE NO ACTION,
    CONSTRAINT CK_SharedExpense_tenant_amount CHECK (tenant_amount >= 0)
);

IF OBJECT_ID(N'dbo.PaidExpense', N'U') IS NULL
CREATE TABLE dbo.PaidExpense (
    id_expense        INT NOT NULL,
    payment_reference VARCHAR(50) NULL,
    CONSTRAINT PK_PaidExpense PRIMARY KEY (id_expense),
    CONSTRAINT FK_PaidExpense_Expense FOREIGN KEY (id_expense)
        REFERENCES dbo.Expense (id_expense) ON DELETE NO ACTION
);

IF OBJECT_ID(N'dbo.Budget', N'U') IS NULL
CREATE TABLE dbo.Budget (
    id_budget  INT IDENTITY(1,1) NOT NULL,
    id_user    INT NOT NULL,
    [year]     SMALLINT NOT NULL,
    [month]    TINYINT NOT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_Budget_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Budget PRIMARY KEY (id_budget),
    CONSTRAINT UQ_Budget_user_year_month UNIQUE (id_user, [year], [month]),
    CONSTRAINT FK_Budget_AppUser FOREIGN KEY (id_user)
        REFERENCES dbo.AppUser (id_person) ON DELETE NO ACTION,
    CONSTRAINT CK_Budget_year CHECK ([year] BETWEEN 2000 AND 9999),
    CONSTRAINT CK_Budget_month CHECK ([month] BETWEEN 1 AND 12)
);

IF OBJECT_ID(N'dbo.Income', N'U') IS NULL
CREATE TABLE dbo.Income (
    id_income  INT IDENTITY(1,1) NOT NULL,
    id_user    INT NOT NULL,
    [date]     DATE NOT NULL,
    amount     BIGINT NOT NULL,
    source     NVARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_Income_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Income PRIMARY KEY (id_income),
    CONSTRAINT FK_Income_AppUser FOREIGN KEY (id_user)
        REFERENCES dbo.AppUser (id_person) ON DELETE NO ACTION,
    CONSTRAINT CK_Income_amount CHECK (amount > 0)
);

IF OBJECT_ID(N'dbo.BudgetCategory', N'U') IS NULL
CREATE TABLE dbo.BudgetCategory (
    id_budget   INT NOT NULL,
    id_category INT NOT NULL,
    amount      BIGINT NOT NULL,
    created_at  DATETIME2 NOT NULL CONSTRAINT DF_BudgetCategory_created_at DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_BudgetCategory PRIMARY KEY (id_budget, id_category),
    CONSTRAINT FK_BudgetCategory_Budget FOREIGN KEY (id_budget)
        REFERENCES dbo.Budget (id_budget) ON DELETE CASCADE,
    CONSTRAINT FK_BudgetCategory_ExpenseCategory FOREIGN KEY (id_category)
        REFERENCES dbo.ExpenseCategory (id_category) ON DELETE NO ACTION,
    CONSTRAINT CK_BudgetCategory_amount CHECK (amount >= 0)
);
GO

/* =========================================================================
   Indexes
   FK columns that lead a primary key or UNIQUE constraint are already indexed
   (subclass PKs, PropertyMember.id_property, BudgetCategory.id_budget,
   Budget.id_user). Expense.id_user and Income.id_user lead the composite
   indexes below. Every other FK column gets its own index here.
   ========================================================================= */

IF INDEXPROPERTY(OBJECT_ID(N'dbo.PropertyMember'), N'IX_PropertyMember_id_person', N'IndexID') IS NULL
    CREATE INDEX IX_PropertyMember_id_person ON dbo.PropertyMember (id_person);
IF INDEXPROPERTY(OBJECT_ID(N'dbo.Agreement'), N'IX_Agreement_id_user', N'IndexID') IS NULL
    CREATE INDEX IX_Agreement_id_user ON dbo.Agreement (id_user);
IF INDEXPROPERTY(OBJECT_ID(N'dbo.Agreement'), N'IX_Agreement_id_tenant', N'IndexID') IS NULL
    CREATE INDEX IX_Agreement_id_tenant ON dbo.Agreement (id_tenant);
IF INDEXPROPERTY(OBJECT_ID(N'dbo.Expense'), N'IX_Expense_id_user_date', N'IndexID') IS NULL
    CREATE INDEX IX_Expense_id_user_date ON dbo.Expense (id_user, [date]);
IF INDEXPROPERTY(OBJECT_ID(N'dbo.Expense'), N'IX_Expense_id_category', N'IndexID') IS NULL
    CREATE INDEX IX_Expense_id_category ON dbo.Expense (id_category);
IF INDEXPROPERTY(OBJECT_ID(N'dbo.SharedExpense'), N'IX_SharedExpense_id_agreement', N'IndexID') IS NULL
    CREATE INDEX IX_SharedExpense_id_agreement ON dbo.SharedExpense (id_agreement);
IF INDEXPROPERTY(OBJECT_ID(N'dbo.SharedExpense'), N'IX_SharedExpense_unrepaid', N'IndexID') IS NULL
    CREATE INDEX IX_SharedExpense_unrepaid ON dbo.SharedExpense (id_agreement)
        WHERE repaid_date IS NULL;
IF INDEXPROPERTY(OBJECT_ID(N'dbo.Income'), N'IX_Income_id_user_date', N'IndexID') IS NULL
    CREATE INDEX IX_Income_id_user_date ON dbo.Income (id_user, [date]);
IF INDEXPROPERTY(OBJECT_ID(N'dbo.BudgetCategory'), N'IX_BudgetCategory_id_category', N'IndexID') IS NULL
    CREATE INDEX IX_BudgetCategory_id_category ON dbo.BudgetCategory (id_category);

-- A UNIQUE constraint would allow only one tenant without a document number,
-- so uniqueness is enforced only on the rows that have one.
IF INDEXPROPERTY(OBJECT_ID(N'dbo.Tenant'), N'UX_Tenant_document_number', N'IndexID') IS NULL
    CREATE UNIQUE INDEX UX_Tenant_document_number ON dbo.Tenant (document_number)
        WHERE document_number IS NOT NULL;
GO

/* =========================================================================
   Triggers
   SQL Server has no deferred constraints, so "every Expense has exactly one
   subclass row" is enforced like this:
     - Only the stored procedures may insert into Expense. They set the
       session key 'ledger.expense_write' and add the subclass row in the same
       transaction.
     - The subclass triggers reject a second subclass row, and reject removing
       a subclass row while its Expense remains.
   This guards against mistakes; it is not a security boundary.
   To delete an expense on purpose, set the key, delete the subclass row, then
   delete the Expense row, all in one transaction.
   ========================================================================= */

CREATE OR ALTER TRIGGER dbo.trg_Expense_rules ON dbo.Expense
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    IF NOT EXISTS (SELECT 1 FROM deleted)
       AND ISNULL(CAST(SESSION_CONTEXT(N'ledger.expense_write') AS INT), 0) <> 1
        THROW 50001, N'Add expenses with sp_add_paid_expense or sp_add_shared_expense.', 1;

    -- Changing an Expense must not break the rules of its SharedExpense row.
    IF EXISTS (SELECT 1 FROM inserted i JOIN dbo.SharedExpense s ON s.id_expense = i.id_expense
               WHERE s.tenant_amount > i.amount)
        THROW 50002, N'tenant_amount cannot exceed Expense.amount.', 1;

    IF EXISTS (SELECT 1 FROM inserted i JOIN dbo.SharedExpense s ON s.id_expense = i.id_expense
               WHERE s.repaid_date < i.[date])
        THROW 50003, N'repaid_date cannot be earlier than Expense.date.', 1;

    IF EXISTS (SELECT 1 FROM inserted i
               JOIN dbo.SharedExpense s ON s.id_expense = i.id_expense
               JOIN dbo.Agreement a ON a.id_agreement = s.id_agreement
               WHERE a.id_user <> i.id_user)
        THROW 50004, N'The agreement belongs to a different user than the expense.', 1;

    IF EXISTS (SELECT 1 FROM inserted i
               JOIN dbo.SharedExpense s ON s.id_expense = i.id_expense
               JOIN dbo.Agreement a ON a.id_agreement = s.id_agreement
               WHERE i.[date] < a.start_date OR i.[date] > a.end_date)
        THROW 50010, N'The expense date is outside the agreement period.', 1;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_SharedExpense_rules ON dbo.SharedExpense
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    IF EXISTS (SELECT 1 FROM inserted i JOIN dbo.PaidExpense p ON p.id_expense = i.id_expense)
        THROW 50005, N'An expense cannot be both shared and paid.', 1;

    IF EXISTS (SELECT 1 FROM inserted i JOIN dbo.Expense e ON e.id_expense = i.id_expense
               WHERE i.tenant_amount > e.amount)
        THROW 50002, N'tenant_amount cannot exceed Expense.amount.', 1;

    IF EXISTS (SELECT 1 FROM inserted i JOIN dbo.Expense e ON e.id_expense = i.id_expense
               WHERE i.repaid_date < e.[date])
        THROW 50003, N'repaid_date cannot be earlier than Expense.date.', 1;

    IF EXISTS (SELECT 1 FROM inserted i
               JOIN dbo.Expense e ON e.id_expense = i.id_expense
               JOIN dbo.Agreement a ON a.id_agreement = i.id_agreement
               WHERE a.id_user <> e.id_user)
        THROW 50004, N'The agreement belongs to a different user than the expense.', 1;

    IF EXISTS (SELECT 1 FROM inserted i
               JOIN dbo.Expense e ON e.id_expense = i.id_expense
               JOIN dbo.Agreement a ON a.id_agreement = i.id_agreement
               WHERE e.[date] < a.start_date OR e.[date] > a.end_date)
        THROW 50010, N'The expense date is outside the agreement period.', 1;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_PaidExpense_rules ON dbo.PaidExpense
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    IF EXISTS (SELECT 1 FROM inserted i JOIN dbo.SharedExpense s ON s.id_expense = i.id_expense)
        THROW 50005, N'An expense cannot be both shared and paid.', 1;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_SharedExpense_delete ON dbo.SharedExpense
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF ISNULL(CAST(SESSION_CONTEXT(N'ledger.expense_write') AS INT), 0) <> 1
       AND EXISTS (SELECT 1 FROM deleted d JOIN dbo.Expense e ON e.id_expense = d.id_expense)
        THROW 50006, N'An Expense must keep its subclass row.', 1;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_PaidExpense_delete ON dbo.PaidExpense
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF ISNULL(CAST(SESSION_CONTEXT(N'ledger.expense_write') AS INT), 0) <> 1
       AND EXISTS (SELECT 1 FROM deleted d JOIN dbo.Expense e ON e.id_expense = d.id_expense)
        THROW 50006, N'An Expense must keep its subclass row.', 1;
END;
GO

/* =========================================================================
   Views
   Totals are aggregated before joining so that one side's rows can't multiply
   the other's.
   ========================================================================= */

CREATE OR ALTER VIEW dbo.v_balance
AS
SELECT
    u.id_person AS id_user,
    p.name,
    ISNULL(i.total, 0) AS total_income,
    ISNULL(e.total, 0) AS total_expense,
    ISNULL(i.total, 0) - ISNULL(e.total, 0) AS balance
FROM dbo.AppUser u
JOIN dbo.Person p ON p.id_person = u.id_person
LEFT JOIN (SELECT id_user, SUM(amount) AS total FROM dbo.Income GROUP BY id_user) i
    ON i.id_user = u.id_person
LEFT JOIN (SELECT id_user, SUM(amount) AS total FROM dbo.Expense GROUP BY id_user) e
    ON e.id_user = u.id_person;
GO

CREATE OR ALTER VIEW dbo.v_expense_by_category
AS
SELECT
    c.id_category,
    c.name AS category,
    YEAR(e.[date]) AS [year],
    MONTH(e.[date]) AS [month],
    SUM(e.amount) AS total
FROM dbo.Expense e
JOIN dbo.ExpenseCategory c ON c.id_category = e.id_category
GROUP BY c.id_category, c.name, YEAR(e.[date]), MONTH(e.[date]);
GO

CREATE OR ALTER VIEW dbo.v_tenant_owed
AS
SELECT
    t.id_person AS id_tenant,
    p.name,
    ISNULL(SUM(s.tenant_amount), 0) AS total_owed
FROM dbo.Tenant t
JOIN dbo.Person p ON p.id_person = t.id_person
LEFT JOIN dbo.Agreement a ON a.id_tenant = t.id_person
LEFT JOIN dbo.SharedExpense s
    ON s.id_agreement = a.id_agreement AND s.repaid_date IS NULL
GROUP BY t.id_person, p.name;
GO

-- One row per budget and category. A budget covers its user's income and
-- expenses dated in its month. total_income, total_budgeted and unallocated
-- describe the whole budget and repeat on each row, so don't SUM them.
CREATE OR ALTER VIEW dbo.v_budget_status
AS
SELECT
    b.id_budget,
    b.id_user,
    b.[year],
    b.[month],
    bc.id_category,
    c.name AS category,
    bc.amount AS budgeted,
    ISNULL(sp.spent, 0) AS spent,
    bc.amount - ISNULL(sp.spent, 0) AS remaining,
    ISNULL(inc.total_income, 0) AS total_income,
    ISNULL(tot.total_budgeted, 0) AS total_budgeted,
    ISNULL(inc.total_income, 0) - ISNULL(tot.total_budgeted, 0) AS unallocated
FROM dbo.Budget b
CROSS APPLY (SELECT DATEFROMPARTS(b.[year], b.[month], 1) AS month_start) m
LEFT JOIN dbo.BudgetCategory bc ON bc.id_budget = b.id_budget
LEFT JOIN dbo.ExpenseCategory c ON c.id_category = bc.id_category
OUTER APPLY (
    SELECT SUM(e.amount) AS spent
    FROM dbo.Expense e
    WHERE e.id_user = b.id_user
      AND e.id_category = bc.id_category
      AND e.[date] >= m.month_start
      AND e.[date] <  DATEADD(MONTH, 1, m.month_start)
) sp
OUTER APPLY (
    SELECT SUM(i.amount) AS total_income
    FROM dbo.Income i
    WHERE i.id_user = b.id_user
      AND i.[date] >= m.month_start
      AND i.[date] <  DATEADD(MONTH, 1, m.month_start)
) inc
OUTER APPLY (SELECT SUM(t.amount) AS total_budgeted
             FROM dbo.BudgetCategory t WHERE t.id_budget = b.id_budget) tot;
GO

/* =========================================================================
   Stored procedures
   ========================================================================= */

CREATE OR ALTER PROCEDURE dbo.sp_add_paid_expense
    @id_user           INT,
    @date              DATE,
    @amount            BIGINT,
    @description       NVARCHAR(255),
    @id_category       INT,
    @payment_reference VARCHAR(50),
    @id_expense        INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        EXEC sys.sp_set_session_context @key = N'ledger.expense_write', @value = 1;
        BEGIN TRANSACTION;

        INSERT INTO dbo.Expense (id_user, id_category, [date], amount, description)
        VALUES (@id_user, @id_category, @date, @amount, @description);
        SET @id_expense = SCOPE_IDENTITY();

        INSERT INTO dbo.PaidExpense (id_expense, payment_reference)
        VALUES (@id_expense, @payment_reference);

        COMMIT TRANSACTION;
        EXEC sys.sp_set_session_context @key = N'ledger.expense_write', @value = NULL;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC sys.sp_set_session_context @key = N'ledger.expense_write', @value = NULL;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_add_shared_expense
    @id_user      INT,
    @date         DATE,
    @amount       BIGINT,
    @description  NVARCHAR(255),
    @id_category  INT,
    @id_agreement INT,
    @id_expense   INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        EXEC sys.sp_set_session_context @key = N'ledger.expense_write', @value = 1;
        BEGIN TRANSACTION;

        DECLARE @percentage DECIMAL(5,2) =
            (SELECT tenant_percentage FROM dbo.Agreement WHERE id_agreement = @id_agreement);
        IF @percentage IS NULL
            THROW 50007, N'Agreement not found.', 1;

        -- Integer arithmetic: percentage in hundredths, +5000 rounds half-up.
        DECLARE @tenant_amount BIGINT =
            (@amount * CAST(@percentage * 100 AS BIGINT) + 5000) / 10000;

        INSERT INTO dbo.Expense (id_user, id_category, [date], amount, description)
        VALUES (@id_user, @id_category, @date, @amount, @description);
        SET @id_expense = SCOPE_IDENTITY();

        INSERT INTO dbo.SharedExpense (id_expense, id_agreement, tenant_amount)
        VALUES (@id_expense, @id_agreement, @tenant_amount);

        COMMIT TRANSACTION;
        EXEC sys.sp_set_session_context @key = N'ledger.expense_write', @value = NULL;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC sys.sp_set_session_context @key = N'ledger.expense_write', @value = NULL;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_mark_repaid
    @id_expense  INT,
    @repaid_date DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @repaid_date IS NULL
            THROW 50008, N'repaid_date is required.', 1;

        UPDATE dbo.SharedExpense
        SET repaid_date = @repaid_date
        WHERE id_expense = @id_expense AND repaid_date IS NULL;

        IF @@ROWCOUNT = 0
            THROW 50009, N'No unrepaid shared expense has that id.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/* =========================================================================
   Seed data (skipped if the seed user already exists)
   ========================================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE email = 'marcela.rojas@example.com')
BEGIN
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;

    DECLARE @user INT, @child INT, @tenant INT,
            @home INT, @rental INT, @agreement INT, @budget INT,
            @housing INT, @utilities INT, @groceries INT, @transport INT, @internet INT,
            @repaid INT, @unrepaid INT;

    INSERT INTO dbo.Person (name, phone) VALUES (N'Marcela Rojas', '70000001');
    SET @user = SCOPE_IDENTITY();
    -- Fake value for demo data only; never a real password hash.
    INSERT INTO dbo.AppUser (id_person, email, password_hash)
    VALUES (@user, 'marcela.rojas@example.com', 'seed-placeholder-not-a-real-hash');

    INSERT INTO dbo.Person (name, phone) VALUES (N'Lucía Rojas', NULL);
    SET @child = SCOPE_IDENTITY();

    INSERT INTO dbo.Person (name, phone) VALUES (N'Carlos Mamani', '70000002');
    SET @tenant = SCOPE_IDENTITY();
    INSERT INTO dbo.Tenant (id_person, document_number) VALUES (@tenant, 'SEED-0001');

    INSERT INTO dbo.Property (name, address) VALUES (N'Family home', N'Calle Ficticia 123, Cochabamba');
    SET @home = SCOPE_IDENTITY();
    INSERT INTO dbo.Property (name, address) VALUES (N'Rental apartment', N'Avenida Ejemplo 456, Cochabamba');
    SET @rental = SCOPE_IDENTITY();

    INSERT INTO dbo.PropertyMember (id_property, id_person, relationship, move_in_date)
    VALUES (@home, @user, N'Owner', '2020-01-15'),
           (@home, @child, N'Child', '2020-01-15'),
           (@rental, @tenant, N'Tenant', '2026-01-01');

    INSERT INTO dbo.Agreement (id_user, id_tenant, tenant_percentage, start_date, end_date)
    VALUES (@user, @tenant, 40.00, '2026-01-01', NULL);
    SET @agreement = SCOPE_IDENTITY();

    INSERT INTO dbo.ExpenseCategory (name) VALUES (N'Housing');
    SET @housing = SCOPE_IDENTITY();
    INSERT INTO dbo.ExpenseCategory (name) VALUES (N'Utilities');
    SET @utilities = SCOPE_IDENTITY();
    INSERT INTO dbo.ExpenseCategory (name) VALUES (N'Groceries');
    SET @groceries = SCOPE_IDENTITY();
    INSERT INTO dbo.ExpenseCategory (name) VALUES (N'Transport');
    SET @transport = SCOPE_IDENTITY();
    INSERT INTO dbo.ExpenseCategory (name) VALUES (N'Internet');
    SET @internet = SCOPE_IDENTITY();

    INSERT INTO dbo.Budget (id_user, [year], [month]) VALUES (@user, 2026, 10);
    SET @budget = SCOPE_IDENTITY();

    INSERT INTO dbo.BudgetCategory (id_budget, id_category, amount)
    VALUES (@budget, @groceries, 200000),
           (@budget, @utilities, 80000),
           (@budget, @transport, 50000);

    INSERT INTO dbo.Income (id_user, [date], amount, source)
    VALUES (@user, '2026-10-01', 850000, N'Salary'),
           (@user, '2026-10-05', 150000, N'Rent');

    EXEC dbo.sp_add_paid_expense @user, '2026-10-03', 65050, N'Weekly shop', @groceries, 'REC-1001';
    EXEC dbo.sp_add_paid_expense @user, '2026-10-10', 72025, N'Weekly shop', @groceries, 'REC-1002';
    EXEC dbo.sp_add_paid_expense @user, '2026-10-12', 12000, N'Bus pass', @transport, NULL;
    EXEC dbo.sp_add_shared_expense @user, '2026-10-08', 30000, N'Electricity bill', @utilities,
        @agreement, @repaid OUTPUT;
    EXEC dbo.sp_add_shared_expense @user, '2026-10-15', 25075, N'Internet plan', @internet,
        @agreement, @unrepaid OUTPUT;
    EXEC dbo.sp_mark_repaid @repaid, '2026-10-20';

    COMMIT TRANSACTION;
END;
GO

/* =========================================================================
   Demo queries
   ========================================================================= */

SELECT * FROM dbo.v_balance ORDER BY id_user;
SELECT * FROM dbo.v_expense_by_category ORDER BY [year], [month], category;
SELECT * FROM dbo.v_tenant_owed ORDER BY id_tenant;
SELECT * FROM dbo.v_budget_status ORDER BY id_budget, category;
GO
