# The bountyhill clerk a.k.a. worker

This package implements 

- the bountyhill resque runner
- the bountyhill resque control server

This implementation was inspired by https://github.com/phoet/freemium. Check its README.md for more details.

## Download (for development purposes)

    mkdir bountyclerk
    ~/bountyclerk/ > git clone git@github.com:bountyhill/bountyclerk.git
    Cloning into 'bountyclerk'...
    remote: Counting objects: 21, done.
    remote: Compressing objects: 100% (12/12), done.
    remote: Total 21 (delta 2), reused 21 (delta 2)
    Receiving objects: 100% (21/21), done.
    Resolving deltas: 100% (2/2), done.
    ~/bountyclerk/ > cd bountyclerk/
    ~/bountyclerk/bountyclerk[master] > git submodule init
    Submodule 'vendor/bountybase' (https://bh-deployment:eadbcef59d7a40310b576cc2a453ccba@github.com/bountyhill/bountybase.git) registered for path 'vendor/bountybase'
    ~/bountyclerk/bountyclerk[master] > git submodule update
    Cloning into 'vendor/bountybase'...
    remote: Counting objects: 69, done.
    remote: Compressing objects: 100% (42/42), done.
    remote: Total 69 (delta 25), reused 68 (delta 24)
    Unpacking objects: 100% (69/69), done.
    Submodule path 'vendor/bountybase': checked out '4805b24170f936ffee5825e0469ef2abfaed9663'
    ~/bountyclerk/bountyclerk[master] > 

## Use a local bountybase repository

A developer may link a local bountybase repository into the target project in `vendor/bountybased` (Note the trailing "d"). The `vendor/bountybase/setup` script is built to prefer the "vendor/bountybased" path instead of "vendor/bountybase"; in which case
the "vendor/bountybase" submodule is ignored completely, and the code in vendor/bountybased is used instead. E.g.

    ln -sf /Users/eno/projects/bountyhill/bountybase/ vendor/bountybased

## Deployment

TODO

## Configuration

See bountyhill's configuration guide.
