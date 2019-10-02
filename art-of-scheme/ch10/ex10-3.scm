(load "test-data.scm")
(load "../util.scm")
(define nat-mergesort
    (lambda (field-name asc?)
        (letrec*
            (
                (assert-field-name-exists (lambda ()
                    (or
                        (string-ci=? field-name "name")
                        (string-ci=? field-name "id")
                        (string-ci=? field-name "age")
                        (string-ci=? field-name "yr. emp")
                        (string-ci=? field-name "year employed")
                        (string-ci=? field-name "supervisor")
                        (string-ci=? field-name "salary")
                        (throw (string-append "field-name " field-name " does not exist in the list"))

                    )
                ))
                (get-rel (lambda ()
                    (cond
                        ((or
                            (string-ci=? field-name "name")
                            (string-ci=? field-name "supervisor")
                        )
                            (if asc? string<? string>?)
                        )
                        ((or
                            (string-ci=? field-name "id")
                            (string-ci=? field-name "yr. emp")
                            (string-ci=? field-name "year employed")
                            (string-ci=? field-name "salary")
                        )
                            (if asc? < >)
                        )
                    )
                ))
                (get-field-index (lambda ()
                    (cond
                        ((string-ci=? field-name "name") 0)
                        ((string-ci=? field-name "id") 1)
                        ((string-ci=? field-name "age") 2)
                        ((or
                            (string-ci=? field-name "yr. emp")
                            (string-ci=? field-name "year employed")
                        ) 3)
                        ((string-ci=? field-name "supervisor") 4)
                        ((string-ci=? field-name "salary") 5)
                    )
                ))
                (rel-help (lambda ()
                    (let
                        (
                            (rel (get-rel))
                            (index (get-field-index))
                        )
                        (lambda (a b)
                            (rel (list-ref a index) (list-ref b index))
                        )
                    )
                ))
            )

            (assert-field-name-exists)

            (lambda (ls)
                (if (null? ls)
                    '()
                    (letrec
                        ((sort (lambda (gps rel)
                            (if (null? (cdr gps))
                                (car gps)
                                (sort (pair-merge gps rel))
                            )
                        )))

                        (sort (make-groups ls (rel-help)))
                    )
                )
            )
        )
    )
)
