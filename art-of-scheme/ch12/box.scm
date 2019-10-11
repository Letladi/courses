(load "util.scm")

(define box-maker
    (lambda (init-value)
        (let
            ((contents init-value))
            (lambda msg
                (case (1st msg)
                    ((type) "box")
                    ((show) contents)
                    ((update!) (for-effect-only (set! contents (2nd msg))))
                    ((swap!) (let
                        ((ans contents))
                        (set! contents (2nd msg))
                        ans
                    ))
                    ((reset!) (for-effect-only (set! contents init-value)))
                    (else (delegate base-object msg))
                )
            )
        )
    )
)

(define delegate
    (lambda (obj msg)
        (apply obj msg)
    )
)

(define invalid-method-name-indicator "unknown")

(define base-object
    (lambda msg
        (case (1st msg)
            ((type) "base-object")
            (else invalid-method-name-indicator)
        )
    )
)

(define send
    (lambda args
        (let
            ((object (car args)) (message (cdr args)))
            (let
                ((try (apply object message)))
                (if (eq? invalid-method-name-indicator try)
                    (throw (string-append
                        "Bad method name: "
                        (car message)
                            " send to object of "
                            (object 'type)
                            " type."
                    ))
                    try
                )
            )
        )
    )
)
