# Maintaining the Microkit tutorial

The tutorial is largely 'done' and has been for quite some time, but it could
of course be extended and improved as more and more features get introduced
into Microkit.

The tutorial is really only touched in two cases:

* Someone uses a new Linux distro or something that causes someone to need
  help with the setup instructions.
* A new Microkit SDK version is released.

There is unfortunately no CI for the Microkit tutorial which is really annoying and
means you have to check everything works manually.

## Updating the SDK version

The best thing is to look at the previous time the SDK has been updated and follow that.
If it's a minor version update (e.g 2.1.0 -> 2.2.0) then the job is pretty easy and you
just have to update a bunch of numbers.

If it's a major version update (e.g 2.2.0 -> 3.0.0) then you have to actually update
the tutorial code and possibly the website.

I would recommend in either case, having a quick skim of the tutorial website and see if
there's any Microkit output or error messages that are referenced and need to be
updated.

## Updating the website

The website is part of the [seL4 docssite](https://github.com/sel4/docs).

## Updating the tutorial and solution code

Unlike the website, these live on the Trustworthy Systems website, this could be
changed so it is more official though.

Make sure you run `diff -bur tutorial solutions` to see if anything weird has snuck in.

To generate tarballs:
```sh
$ ./package.sh
$ ls dist
$ solutions.tar.gz tutorial.tar.gz
```

To transfer
```sh
scp dist/solutions.tar.gz dist/tutorial.tar.gz stage.trustworthy.systems:/home/ts/downloads/public/microkit_tutorial/`
```

Note that the downloads have to be updated manually on the stage interface unfortunately. This is definitely an
area for improvement.
