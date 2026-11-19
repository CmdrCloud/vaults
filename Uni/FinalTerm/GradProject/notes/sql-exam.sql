USE DBPedidosYa;

@idpedido int;
@coste smallint;

AS
BEGIN

ON TABLE Pedidos
SET nocount ON;

ALTER TABLE Pedidos
  UPDATE Pedidos where @idpedido = IDPedido,
    SET @coste = coste;

END
GO
