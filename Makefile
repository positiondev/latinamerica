all: app

libunsafe.a: libunsafe.o
	ar rcs $@ $<

libunsafe.o: unsafe.c
	gcc -I/usr/local/include/urweb -g -c -o $@ $<

librandom.a: librandom.o
	ar rcs $@ $<

librandom.o: random.c
	gcc -I/usr/local/include/urweb -g -c -o $@ $<

libhash.a: libhash.o
	ar rcs $@ $<

libhash.o: hash.c
	gcc -I/usr/local/include/urweb -g -c -o $@ $<

app: librandom.a libhash.a libunsafe.a
	urweb -dbms sqlite -db la.db la

static: librandom.a libhash.a libunsafe.a
	urweb -static -dbms sqlite -db la.db la

run: app
	./la.exe -db ../la.db

deploy: static deploy-static
	rsync --checksum -ave 'ssh ' la.exe  hiaw@map.historyisaweapon.com:/var/www/latinamerica

deploy-static:
	rsync --checksum -ave 'ssh ' img site.js hiaw@map.historyisaweapon.com:/var/www/latinamerica/static
	rsync --checksum -ave 'ssh ' css/* hiaw@map.historyisaweapon.com:/var/www/latinamerica/static/css

restart:
	ssh map.historyisaweapon.com /var/www/latinamerica/restart.sh
