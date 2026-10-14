import os
import getpass
import oracledb

oracledb.init_oracle_client(
    lib_dir=r"D:\mes\instantclient-basic-windows.x64-23.26.3.0.0\instantclient_23_26"
)

HOST = "10.2.14.194"
PORT = 1522
SID = "KNRAMES"
USER = "KNRAMES"
OWNER = "KNRAMES"

OUTPUT_DIR = "./procedures"

os.makedirs(OUTPUT_DIR, exist_ok=True)

password = "knrames321$"

dsn = oracledb.makedsn(
    HOST,
    PORT,
    sid=SID
)

conn = oracledb.connect(
    user=USER,
    password=password,
    dsn=dsn
)

cursor = conn.cursor()

# 프로시저 목록 조회
cursor.execute("""
    SELECT OBJECT_NAME
    FROM ALL_OBJECTS
    WHERE OWNER = :owner
      AND OBJECT_TYPE = 'PROCEDURE'
    ORDER BY OBJECT_NAME
""", owner=OWNER.upper())

procedures = [row[0] for row in cursor.fetchall()]

print(f"총 {len(procedures)}개 프로시저 발견")

for i, procedure_name in enumerate(procedures, 1):

    cursor.execute("""
        SELECT DBMS_METADATA.GET_DDL(
            'PROCEDURE',
            :procedure_name,
            :owner
        )
        FROM DUAL
    """,
    procedure_name=procedure_name,
    owner=OWNER.upper())

    ddl = cursor.fetchone()[0]

    # CLOB 처리
    if hasattr(ddl, "read"):
        ddl = ddl.read()

    file_path = os.path.join(
        OUTPUT_DIR,
        f"{procedure_name}.sql"
    )

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(ddl.rstrip())
        f.write("\n/\n")

    print(f"[{i}/{len(procedures)}] {procedure_name}.sql")

cursor.close()
conn.close()

print("완료")