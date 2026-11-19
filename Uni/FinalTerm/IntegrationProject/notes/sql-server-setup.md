# SQL Server on Mac

SQL Server 2022 Developer Edition runs in Docker (x86 image under Rosetta).
SSMS is Windows-only, so DBeaver and `sqlcmd` replace it.

- Config: `~/sqlserver/compose.yaml`
- Password: `~/sqlserver/.env` (kept outside this vault so it never reaches git)
- Data: Docker volume `sqlserver_mssql-data` (survives restarts and `down`; `down -v` deletes it)
- Database created: `IntegrationProject`

## Start / stop

Docker Desktop must be open. The server does not start on its own.

```bash
docker compose -f ~/sqlserver/compose.yaml up -d
```

```bash
docker compose -f ~/sqlserver/compose.yaml stop
```

## Connect with DBeaver

New Database Connection → SQL Server:

| Field | Value |
| --- | --- |
| Host | `127.0.0.1` |
| Port | `1433` |
| Database | `IntegrationProject` |
| Authentication | SQL Server Authentication |
| Username | `sa` |
| Password | see below |

In Driver properties, set `trustServerCertificate` to `true`.

```bash
grep MSSQL_SA_PASSWORD ~/sqlserver/.env
```

## Connect with sqlcmd

```bash
sqlcmd -S 127.0.0.1,1433 -U sa -C -d IntegrationProject
```
