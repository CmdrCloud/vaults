create procedure sp_md_pais

  @idpais int,
  @pais varchar(50),
  @o int

as
begin

  set nocount on;
  if (@o=1)
    insert into pais values(@pais)

  if (@o=2)
    update pais set pais=@pais where idpais=@idpais

  if(@o=3)
    delete from pais where idpais=@idpais

end
go
