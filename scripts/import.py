import sqlite3
import json
import sys

if len(sys.argv) != 3:
    print("usage: python import.py data.db file.json")
    exit(1)

entries = json.load(open(sys.argv[2]))    
db = sqlite3.connect(sys.argv[1])
c = db.cursor()

for e in entries:
    c.execute("insert into uw_La_entries_s default values")
    c.execute("select id from uw_La_entries_s order by id desc limit 1")
    id = c.fetchone()[0]
    
    c.execute("insert into uw_La_entries values (?,?,?,?,?,?,?,?,?,?)",
              (id, e["title"], e["start"], e["end"], e["loc"], e["type"],
               e["source"], e["entry"], "medium", 0))

c.execute("delete from uw_La_entries_s")

db.commit()
db.close()

