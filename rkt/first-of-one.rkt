;; this snippet takes the first element
;; from a list which contains only one (i.e. of type (Vec E 1))
;; then only two
#lang pie

;; claim the type
(claim first-of-one
	   (Pi ((E U))
		   (-> (Vec E 1)
			   E)))
;; define the function
(define first-of-one
  (lambda (E)
	(lambda (es)
	  (head es))))          ; head is built in

;; test
(first-of-one Atom
			  (vec:: 'shiitake vecnil))     ; => 'shiitake

;; for lists of 2 elements
;; claim the type
(claim first-of-two
	   (Pi ((E U))
		   (-> (Vec E 2)
			   E)))
;; define the function
(define first-of-two
  (lambda (E)
	(lambda (es)
	  (head es))))

;; test
(first-of-two Atom
			  (vec:: 'matsutake
					 (vec:: 'morel
							(vec:: 'truffle vecnil)))) ; => error
(first-of-two Atom
			  (vec:: 'hribi
					 (vec:: 'bureti vecnil)))          ; => 'hribi
