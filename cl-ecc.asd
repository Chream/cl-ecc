;;;; cl-ecc.asd

(asdf:defsystem #:cl-ecc
  :version "0.1.0"
  :description "Describe cl-ecc here"
  :author "krkhan"
  :license "Specify license here"
  :depends-on (#:ironclad
               #:iterate
               #:nibbles
               #:com.gigamonkeys.binary-data
               #:com.gigamonkeys.macro-utilities
               #:helper-library)
  :components ((:module "common"
                        :pathname ""
                        :serial t
                        :components
                        ((:file "package")
                         (:file "common")))
               (:module "ecc"
                        :serial t
                        :components
                        ((:file "common")
                         (:file "model")
                         (:file "math-mod" :depends-on ("model"))
                         (:file "curve" :depends-on ("model"
                                                     "common"
                                                     "math-mod"))
                         (:file "ecdh" :depends-on ("curve"))
                         (:file "elgamal" :depends-on ("curve" "ecdh"))
                         (:file "ecdsa" :depends-on ("curve" "math-mod"))
                         (:file "curve-parameters" :depends-on ("model"))
                         (:file "ecc" :depends-on ("curve"
                                                   "ecdh"
                                                   "elgamal"
                                                   "ecdsa"))))

               (:module "bitcoin"
                        :serial t
                        :depends-on (ecc)
                        :components
                        ((:file "model")
                         (:file "common"))))
  :description "A library for use with eliptic curve cryptography.
               NOT TESTET OR SECURE")
