;; define a custom version of `first' and `rest' for a list

#lang pie

;; claim the type of first
(claim first
	   (Pi ((E U)
			(l Nat))
		   (-> (Vec E (add1 l))
			   E)))
;; define it
(define first
  (lambda (E l)
	(lambda (es)
	  (head es))))

;; test
(first (vec:: 'one
			  (vec:: 'two
					 (vec:: 'three vecnil))))       ; => one

;; claim the type of rest
(claim rest
	   (Pi ((E U)
			(l Nat))
		   (-> (Vec E (add1 l))
			   (Vec E l))))
;; define it
(define rest
  (lambda (E l)
	(lambda (es)
	  (tail es))))

;; test
(rest (vec:: 'one
			 (vec:: 'two
					(vec:: 'three vecnil))))        ; => '(two three vecnil)
