(load "util.scm")
(load "ch11/memoize.scm")
(load "ch12/box.scm")

(define bucket-maker
    (lambda ()
        (let
            ((table '()))
            (lambda msg
                (case (1st msg)
                    ((type) "bucket")
                    ((lookup)
                        (let
                            ((key (2nd msg)) (succ (3rd msg)) (fail (4th msg)))
                            (lookup key table (lambda (pr) (succ (cdr pr))) fail)
                        )
                    )
                    ((update!)
                        (for-effect-only
                            (let ((key (2nd msg)) (updater (3rd msg)) (initializer (4th msg)))
                                (lookup key table
                                    (lambda (pr) (set-cdr! pr (updater (cdr pr))))
                                    (lambda ()
                                        (let ((pr (cons key (initializer key))))
                                            (set! table (cons pr table))
                                        )
                                    )
                                )
                            )
                        )
                    )
                    ((update!-lookup)
                        (let ((key (2nd msg)) (updater (3rd msg)) (initializer (4th msg)))
                            (lookup key table
                                (lambda (pr)
                                    (set-cdr! pr (updater (cdr pr)))
                                    (cdr pr)
                                )
                                (lambda ())
                            )
                        )
                    )
                    (else (delegate base-object msg))
                )
            )
        )
    )
)
