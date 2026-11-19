create procedure dbo.buscar_ciudad

  @contenido_ciudad varchar(100),
  @contenido_pais varchar(100)

as
begin

    set nocount on;
    select Pais, Ciudad from Pais inner join Ciudad on Pais.IDPais = Ciudad.IDPais
    where Ciudad.ciudad like '%' + @contenido_ciudad + '%' or Pais.pais like '%' + @contenido_ciudad + '%'
end
