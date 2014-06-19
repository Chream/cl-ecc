(in-package :mod)

(defmethod add-mod (&rest args)
  "Returns: a + b + ... + z (mod n)"
  (let ((lastindex (1- (length args))))
    (mod (apply '+ (subseq args 0 lastindex)) (nth lastindex args))))

(defmethod sub-mod (&rest args)
  "Returns: a - b - ... - z (mod n)"
  (let ((lastindex (1- (length args))))
    (mod (apply '- (subseq args 0 lastindex)) (nth lastindex args))))

(defmethod mul-mod (&rest args)
  "Returns: a * b * ... * z (mod n)"
  (let ((lastindex (1- (length args))))
    (mod (apply '* (subseq args 0 lastindex)) (nth lastindex args))))

(defmethod egcd (a b)
  "Returns: (gcd(a, b), s, t) where gcd(a, b) = s*a + t*b"
  (let (quotient)
    (do ((s-i 0)
         (s-i-minus-1 1)
         (t-i 1)
         (t-i-minus-1 0)
         (r-i (min a b))
         (r-i-minus-1 (max a b)))

        ((= r-i 0) (values r-i-minus-1 s-i-minus-1 t-i-minus-1))

        (setf quotient (truncate (/ r-i-minus-1 r-i)))
        (shiftf r-i-minus-1 r-i (- r-i-minus-1 (* quotient r-i)))
        (shiftf s-i-minus-1 s-i (- s-i-minus-1 (* quotient s-i)))
        (shiftf t-i-minus-1 t-i (- t-i-minus-1 (* quotient t-i))))))

(defmethod inv-mod (a n)
  "Returns: a^-1 (mod n)
   Signals: 'invalid-operation-error if gcd(a, n) != 1"
  (unless (= (gcd a n) 1)
    (error 'invalid-operation-error :msg "gcd(a, n) != 1"))

  (multiple-value-bind (g a b) (egcd a n)
    (declare (ignore g a))
    (mod b n)))

(defmethod div-mod (a b n)
  "Returns: a / b (mod n)"
  (mul-mod a (inv-mod b n) n))

(defun expt-mod (x e n)
  (loop with result = x
        for i from (- (integer-length e) 2) downto 0
        do
          (setf result (mul-mod result result n))
          (when (logbitp i e)
            (setf result (mul-mod result x n)))
        finally
          (return-from expt-mod result)))

(defmethod legendre-symbol (a p)
  "Returns: 1 if a has a square root module p, otherwise -1"
  (let (pow ls)
    (setf pow (truncate (/ (1- p) 2)))
    (setf ls (expt-mod a pow p))
    (when (= ls (1- p)) (return-from legendre-symbol -1))
    ls))

(defmethod sqrt-mod (a p)
  "Returns: x where x^2 = a (mod p)"
  (let (ls s e n x b g r tt m gs)
    (setf ls (legendre-symbol a p))
    (cond
      ((not (= ls 1)) (error 'invalid-operation-error :msg (format nil "sqrt of ~a does not exist mod ~a" a p)))
      ((= a 0) (return-from sqrt-mod 0))
      ((= p 2) (return-from sqrt-mod p))
      ((= (mod p 4) 3) (return-from sqrt-mod (expt-mod a (/ (1+ p) 4) p))))

    (setf s (1- p))
    (setf e 0)

    (loop do
      (setf s (truncate (/ s 2)))
      (setf e (1+ e))
      while (= (mod s 2) 0))

    (setf n 2)
    (loop do
      (setf n (1+ n))
      until (= (legendre-symbol n p) -1))

    (setf x (expt-mod a (truncate (/ (1+ s) 2)) p))
    (setf b (expt-mod a s p))
    (setf g (expt-mod n s p))
    (setf r e)

    (loop do
      (setf tt b)
      (setf m 0)

      (loop repeat r
        until (= tt 1)
        do
          (setf tt (expt-mod tt 2 p))
          (setf m (1+ m)))

      (when (= m 0) (return-from sqrt-mod x))

      (setf gs (expt-mod g (expt 2 (- r m 1)) p))
      (setf g (mul-mod gs gs p))
      (setf x (mul-mod x gs p))
      (setf b (mul-mod b g p))
      (setf r m))))
