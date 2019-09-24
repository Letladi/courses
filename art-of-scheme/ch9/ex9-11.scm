(load "sec9-1.scm")
(load "../ch8/quant.scm")
(load "../ch8/set.scm")

(define matrix-tag "matrix-tag")

(define matrix?
    (lambda (mat)
        (and
            (pair? mat)
            (eq? matrix-tag (car mat))
            (vector? (cdr mat))
        )
    )
)

(define num-cols
    (lambda (mat)
        (let*
            (
                (vec (cdr mat))
                (size (1- (vector-length vec)))
            )
            (vector-ref vec size)
        )
    )
)

(define num-rows
    (lambda (mat)
        (let*
            (
                (vec (cdr mat))
                (size (1- (vector-length vec)))
            )
            (/ size (vector-ref vec size))
        )
    )
)

(define matrix-ref
    (lambda (mat)
        (letrec*
            (
                (ncols (num-cols mat))
                (index-check-builder (lambda (min-val max-index-proc)
                    (lambda (i)
                        (and (>= i min-val) (< i (max-index-proc mat)))
                    )
                ))
                (row-index-in-range? (index-check-builder 0 (lambda (mat) (num-rows mat))))
                (col-index-in-range? (index-check-builder 0 (lambda (mat) (num-cols mat))))
                (assert-index (lambda (in-range? prop-name)
                    (if (not in-range?)
                        (throw (string-append "the matrix " prop-name " index is out of range"))
                    )
                ))
                (vec (cdr mat))
            )

            (lambda (i j)
                (begin
                    (assert-index (row-index-in-range? i) "row")
                    (assert-index (col-index-in-range? j) "column")
                    (vector-ref vec (+ (* i ncols) j))
                )
            )
        )
    )
)

(define matrix-generator
    (lambda (gen-proc)
        (lambda (nrows ncols)
            (let
                ((size (* nrows ncols)))
                (let
                    ((vec-gen-proc (lambda (k)
                        (if (< k size)
                            (gen-proc (quotient k ncols) (remainder k ncols))
                            ncols
                        )
                    )))

                    (cons
                        matrix-tag
                        ((vector-generator vec-gen-proc) (1+ size))
                    )
                )
            )
        )
    )
)

(define row-of
    (lambda (mat)
        (let*
            (
                (mat-ref (matrix-ref mat))
                (number-of-columns (num-cols mat))
            )
            (lambda (i)
                (let
                    ((gen-proc (lambda (j) (mat-ref i j))))
                    ((vector-generator gen-proc) number-of-columns)
                )
            )

        )
    )
)

(define column-of
    (lambda (mat)
        (let
            (
                (mat-ref (matrix-ref mat))
                (number-of-rows (num-rows mat))
            )
            (lambda (j)
                (let
                    ((gen-proc (lambda (i) (mat-ref i j))))
                    ((vector-generator gen-proc) number-of-rows)
                )
            )
        )
    )
)

(define matrix-tranpose
    (lambda (mat)
        (let
            ((mat-ref (matrix-ref mat)))
            (let
                ((gen-proc (lambda (i j) (mat-ref j i))))
                ((matrix-generator gen-proc)
                    (num-cols mat)
                    (num-rows mat)
                )
            )
        )
    )
)

(define matrix-product
    (lambda (mat-a mat-b)
        (let
            (
                (ncols-a (num-cols mat-a))
                (nrows-b (num-rows mat-b))
                (a-ref (matrix-ref mat-a))
                (b-ref (matrix-ref mat-b))
            )
            (if (not (= ncols-a nrows-b))
                (throw "matrix-product: The matrices are not compatible.")
                (let
                    ((gen-proc (lambda (i j)
                        (letrec
                            ((loop (lambda (r acc)
                                (if (= r ncols-a)
                                    acc
                                    (loop
                                        (1+ r)
                                        (+ acc (* (a-ref i r) (b-ref r j)))
                                    )
                                )
                            )))

                            (loop 0 0)
                        )
                    )))

                    ((matrix-generator gen-proc)
                        (num-rows mat-a)
                        (num-cols mat-b)
                    )
                )
            )
        )
    )
)

(define matrix-set!
    (lambda (mat)
        (lambda (i j obj)
            (let*
                (
                    (ncols (num-cols mat))
                    (vec-index (+ (* i ncols) j))
                    (vec (cdr mat))
                )
                (vector-set! vec vec-index obj)
            )
        )
    )
)

(define matrix
    (lambda (m n)
        (lambda args
            (let
                (
                    (size (* m n))
                    (args-len (length args))

                )
                (cond
                    ((= size args-len)
                        (letrec*
                            (
                                (len (1+ size))
                                (vec (make-vector len))
                                (loop (lambda (i ls v)
                                    (if (null? ls)
                                        (vector-update! v i n)
                                        (loop
                                            (1+ i)
                                            (cdr ls)
                                            (vector-update! v i (car ls))
                                        )
                                    )
                                ))
                            )
                            (cons
                                matrix-tag
                                (loop 0 args vec)
                            )
                        )
                    )
                    (else
                        (throw "the number of elements must fill the matrix")
                    )
                )
            )
        )
    )
)

(define mat+
    (lambda (mat-a mat-b)
        (let
            (
                (assert-equal-dimension (lambda (dim1 dim2 dim-name)
                    (if (not (= dim1 dim2))
                        (throw (string-append "matrices must have equal " dim-name))
                    )
                ))
                (ncols-a (num-cols mat-a))
                (ncols-b (num-cols mat-b))
                (nrows-a (num-rows mat-a))
                (nrows-b (num-rows mat-b))
            )

            (begin
                (assert-equal-dimension ncols-a ncols-b "columns")
                (assert-equal-dimension nrows-a nrows-b "rows")
                (letrec*
                    (
                        (ref-a (matrix-ref mat-a))
                        (ref-b (matrix-ref mat-b))
                        (gen-proc (lambda (i j)
                            (+ (ref-a i j) (ref-b i j))
                        ))
                    )
                    ((matrix-generator gen-proc) nrows-a ncols-a)
                )
            )
        )
    )
)

(define matrix-multiply-by-scalar
    (lambda (c mat-a)
        (letrec*
            (
                (ref-a (matrix-ref mat-a))
                (gen-proc (lambda (i j)
                    (* c (ref-a i j))
                ))
                (ncols-a (num-cols mat-a))
                (nrows-a (num-rows mat-a))
            )
            ((matrix-generator gen-proc) nrows-a ncols-a)
        )
    )
)

(define matrix-view
    (lambda (mat)
        (letrec*
            (
                (ncols (num-cols mat))
                (nrows (num-rows mat))
                (size (* ncols nrows))
                (ref-mat (matrix-ref mat))
                (loop (lambda (k)
                    (let*
                        (
                            (i (quotient k ncols))
                            (j (remainder k ncols))
                            (end-of-column? (= j (1- ncols)))
                        )
                        (if (< k size)
                            (begin
                                (display (ref-mat i j))
                                (display " ")
                                (if end-of-column?
                                    (newline)
                                )
                                (loop (1+ k))
                            )
                        )
                    )
                ))
            )
            (loop 0)
        )
    )
)

(define view
    (lambda (collection)
        (cond
            ((matrix? collection) (matrix-view collection))
            ((vector? collection) (vector-view collection))
            ((set? collection) (view-set collection))
            (else
                (throw "the given collection does not have a view function")
            )
        )
    )
)

(define a ((matrix 3 3) 1 1 1
    1 1 1
    1 1 1
))
(define b a)
(define c ((matrix 3 2) 1 2
    3 4
    5 6
))
(define d ((matrix 2 3) 1 2 1 1 2 1))
