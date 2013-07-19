## About

This is a webapp for an interactive map/timeline of latin american
history.

## Technical

The application is written with the web framework Ur/Web, and is
backed with an SQLite database, for simplicity / portability.

## Building

In addition to Ur/Web, which documents how to get it built, you need
static versions of libssl, which should be in the libssl-dev packages
on debian/derivatives. You also need mhash (libmhash-dev). Then you
should be able to, at least on Linux, make static to build a static
version of the app, suitable for deployment. (Note that on Macs you
can't do this - you can almost by trying with the -debug flag and then
manually replacing -lssl and company with paths to the .a files, but
libSystem is not provided statically, so it will always be dynamic.)

## Deployment

Copy la.exe to your host, changing any paths in la.ur[p] as needed for
the static files, and start it up. Put it behind a proxy to have
static files work.