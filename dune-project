(lang dune 3.5)

(using menhir 2.1)

(name Interpreters)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name Interpreters)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune z3)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
